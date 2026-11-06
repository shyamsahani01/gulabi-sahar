extends RefCounted
## Physical body behaviour on top of the animation: a ragdoll for knockdowns (Godot's answer to
## Euphoria-style reactions), two-leg foot IK so feet sit on steps and slopes, and pendulum
## secondary motion for dangling wardrobe pieces (chain, hood).  Everything is built at runtime
## on the existing rig; nothing here changes the imported assets.

# bone: (capsule radius, mass, joint type)
const RAGDOLL_BONES := {
	"pelvis": [0.13, 9.0, PhysicalBone3D.JOINT_TYPE_NONE],
	"spine_02": [0.13, 7.0, PhysicalBone3D.JOINT_TYPE_CONE],
	"neck_01": [0.055, 1.0, PhysicalBone3D.JOINT_TYPE_CONE],
	"head": [0.1, 4.0, PhysicalBone3D.JOINT_TYPE_CONE],
	"upperarm_l": [0.05, 2.0, PhysicalBone3D.JOINT_TYPE_CONE],
	"lowerarm_l": [0.04, 1.4, PhysicalBone3D.JOINT_TYPE_HINGE],
	"upperarm_r": [0.05, 2.0, PhysicalBone3D.JOINT_TYPE_CONE],
	"lowerarm_r": [0.04, 1.4, PhysicalBone3D.JOINT_TYPE_HINGE],
	"thigh_l": [0.08, 6.0, PhysicalBone3D.JOINT_TYPE_CONE],
	"calf_l": [0.06, 3.5, PhysicalBone3D.JOINT_TYPE_HINGE],
	"thigh_r": [0.08, 6.0, PhysicalBone3D.JOINT_TYPE_CONE],
	"calf_r": [0.06, 3.5, PhysicalBone3D.JOINT_TYPE_HINGE],
}
const RAGDOLL_LAYER := 8

static func bone_length(skeleton: Skeleton3D, bone: int) -> float:
	var rest := skeleton.get_bone_global_rest(bone).origin
	var best := 0.0
	for child in skeleton.get_bone_children(bone):
		best = maxf(best, rest.distance_to(skeleton.get_bone_global_rest(child).origin))
	return best if best > 0.02 else 0.12

static func setup_ragdoll(human: Node3D) -> PhysicalBoneSimulator3D:
	var skeleton: Skeleton3D = human.skeleton
	var sim := PhysicalBoneSimulator3D.new()
	sim.name = "Ragdoll"
	skeleton.add_child(sim)
	for bone_name in RAGDOLL_BONES:
		var bone := skeleton.find_bone(bone_name)
		if bone < 0:
			continue
		var spec: Array = RAGDOLL_BONES[bone_name]
		var body := PhysicalBone3D.new()
		body.name = "PB_" + bone_name
		body.bone_name = bone_name
		body.mass = spec[1]
		body.joint_type = spec[2]
		body.collision_layer = RAGDOLL_LAYER
		body.collision_mask = 1
		body.linear_damp = 0.4
		body.angular_damp = 2.0
		body.friction = 0.9
		var length := bone_length(skeleton, bone)
		var shape := CollisionShape3D.new()
		var capsule := CapsuleShape3D.new()
		capsule.radius = spec[0]
		capsule.height = maxf(length, spec[0] * 2.2)
		shape.shape = capsule
		# Bones run along their local +Y; a capsule is Y-aligned by default, so only offset to the middle.
		shape.position = Vector3(0, length * 0.5, 0)
		body.add_child(shape)
		body.body_offset = Transform3D.IDENTITY
		if spec[2] == PhysicalBone3D.JOINT_TYPE_CONE:
			body.set("joint_constraints/swing_span", deg_to_rad(40 if bone_name != "head" else 25))
			body.set("joint_constraints/twist_span", deg_to_rad(30))
			body.set("joint_constraints/softness", 0.6)
		elif spec[2] == PhysicalBone3D.JOINT_TYPE_HINGE:
			body.set("joint_constraints/angular_limit_enabled", true)
			body.set("joint_constraints/angular_limit_lower", deg_to_rad(-5))
			body.set("joint_constraints/angular_limit_upper", deg_to_rad(120))
		sim.add_child(body)
	sim.active = true
	# The limbs must not rest on the character's own capsule (the CharacterBody3D above the rig).
	var owner_body: Node = human.get_parent()
	while owner_body != null and not owner_body is PhysicsBody3D:
		owner_body = owner_body.get_parent()
	if owner_body != null:
		for body in sim.get_children():
			if body is PhysicalBone3D:
				body.add_collision_exception_with(owner_body)
	return sim

static func start_ragdoll(human: Node3D, impulse: Vector3) -> void:
	if human.ragdoll == null:
		return
	human.animation_tree.active = false
	human.animator.pause()
	human.ragdoll.physical_bones_start_simulation()
	human.ragdoll_time = 0.0
	human.ragdolling = true
	for body in human.ragdoll.get_children():
		if body is PhysicalBone3D:
			body.apply_central_impulse(impulse * body.mass * 0.12)

static func stop_ragdoll(human: Node3D) -> void:
	if human.ragdoll == null or not human.ragdolling:
		return
	human.ragdoll.physical_bones_stop_simulation()
	human.ragdolling = false
	human.animator.play("Idle")
	human.animation_tree.active = true

# ---------------------------------------------------------------- foot IK
static func setup_foot_ik(human: Node3D) -> Dictionary:
	var skeleton: Skeleton3D = human.skeleton
	var legs := {}
	for side in ["l", "r"]:
		if skeleton.find_bone("foot_" + side) < 0 or skeleton.find_bone("thigh_" + side) < 0:
			continue
		var target := Node3D.new()
		target.name = "FootTarget_" + side
		human.add_child(target)
		var ik := SkeletonIK3D.new()
		ik.name = "FootIK_" + side
		ik.root_bone = "thigh_" + side
		ik.tip_bone = "foot_" + side
		ik.use_magnet = true
		ik.magnet = Vector3(0.1 if side == "l" else -0.1, 0.5, 0.6)
		ik.override_tip_basis = false
		ik.interpolation = 0.0
		ik.min_distance = 0.005
		ik.max_iterations = 8
		skeleton.add_child(ik)
		ik.target_node = ik.get_path_to(target)
		ik.start()
		legs[side] = {"ik": ik, "target": target, "weight": 0.0, "lift": 0.0}
	return legs

## Each frame: probe the ground under each foot; when a foot would hang above or dig into a
## step, slide it to the surface.  `allowed` is false in the air, when seated, or in actions.
static func update_foot_ik(human: Node3D, delta: float, allowed: bool) -> void:
	if human.foot_ik.is_empty():
		return
	var skeleton: Skeleton3D = human.skeleton
	var space := human.get_world_3d().direct_space_state
	var base_y: float = human.global_position.y
	for side in human.foot_ik:
		var leg: Dictionary = human.foot_ik[side]
		var ik: SkeletonIK3D = leg.ik
		var foot := skeleton.find_bone("foot_" + side)
		var foot_world: Vector3 = skeleton.global_transform * skeleton.get_bone_global_pose(foot).origin
		var want := 0.0
		if allowed:
			var query := PhysicsRayQueryParameters3D.create(foot_world + Vector3(0, 0.6, 0), foot_world + Vector3(0, -0.5, 0), 1)
			var hit := space.intersect_ray(query)
			if not hit.is_empty():
				# The animated foot sits at base_y (+ its own height); move only the difference.
				var ground_offset: float = hit.position.y - base_y
				if absf(ground_offset) > 0.015 and absf(ground_offset) < 0.45:
					var anim_height: float = foot_world.y - base_y
					leg.target.global_position = Vector3(foot_world.x, hit.position.y + anim_height, foot_world.z)
					want = 1.0
		leg.weight = move_toward(leg.weight, want, delta * (6.0 if want > leg.weight else 3.0))
		ik.interpolation = leg.weight
		human.foot_ik[side] = leg

# ---------------------------------------------------------------- dangling wardrobe pieces
## A one-link pendulum hung from a bone attachment: swings with the wearer's acceleration and
## settles with damping.  Used for the chain pendant and the hood.
class Pendulum:
	var node: Node3D
	var rest: Basis
	var angle := Vector2.ZERO
	var velocity := Vector2.ZERO
	var last_origin := Vector3.ZERO
	var last_velocity := Vector3.ZERO
	var stiffness := 40.0
	var damping := 5.0
	var gain := 0.9
	var limit := 0.9

static func make_pendulum(node: Node3D, stiffness: float, damping: float, gain: float, limit: float) -> Pendulum:
	var p := Pendulum.new()
	p.node = node
	p.rest = node.transform.basis
	p.stiffness = stiffness
	p.damping = damping
	p.gain = gain
	p.limit = limit
	p.last_origin = node.global_position
	return p

static func update_pendulums(human: Node3D, delta: float) -> void:
	if delta <= 0 or human.pendulums.is_empty():
		return
	for p in human.pendulums:
		if not is_instance_valid(p.node) or not p.node.is_inside_tree():
			continue
		var origin: Vector3 = p.node.global_position
		var vel: Vector3 = (origin - p.last_origin) / delta
		var accel: Vector3 = (vel - p.last_velocity) / delta
		p.last_origin = origin
		p.last_velocity = vel
		# Express the acceleration in the attachment's frame; the piece swings against it.
		var local_accel: Vector3 = p.node.get_parent().global_transform.basis.inverse() * accel
		var drive: Vector2 = Vector2(clampf(-local_accel.z * 0.02, -2, 2), clampf(local_accel.x * 0.02, -2, 2)) * float(p.gain)
		p.velocity += (drive - p.stiffness * p.angle - p.damping * p.velocity) * delta
		p.angle += p.velocity * delta
		p.angle = p.angle.clamp(Vector2(-p.limit, -p.limit), Vector2(p.limit, p.limit))
		p.node.transform.basis = p.rest * Basis.from_euler(Vector3(p.angle.x, 0, p.angle.y))
