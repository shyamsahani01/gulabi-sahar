extends Node3D
# Street animals built from the same box/sphere language as the world: cows, dogs,
# goats, monkeys, pigeons, peacocks and a camel. Simple leg swing plus wander/idle.

var player: Node3D
var world: Node3D
var creatures: Array[Dictionary] = []
var mats: Dictionary = {}
var cube := BoxMesh.new()
var sphere := SphereMesh.new()

const KINDS := {
	"cow": {"body": Vector3(0.7, 0.8, 1.7), "head": Vector3(0.38, 0.4, 0.55), "leg": 0.85, "speed": 0.7, "idle": 0.7, "horns": true, "tail": true, "hump": true},
	"dog": {"body": Vector3(0.3, 0.32, 0.8), "head": Vector3(0.22, 0.22, 0.3), "leg": 0.42, "speed": 1.6, "idle": 0.5, "ears": true, "tail": true},
	"goat": {"body": Vector3(0.36, 0.45, 0.9), "head": Vector3(0.22, 0.3, 0.36), "leg": 0.55, "speed": 1.1, "idle": 0.55, "horns": true, "ears": true},
	"monkey": {"body": Vector3(0.3, 0.4, 0.45), "head": Vector3(0.24, 0.24, 0.24), "leg": 0.35, "speed": 1.9, "idle": 0.45, "tail": true, "sits": true},
	"pigeon": {"body": Vector3(0.14, 0.14, 0.3), "head": Vector3(0.09, 0.09, 0.1), "leg": 0.09, "speed": 0.6, "idle": 0.4, "bird": true},
	"peacock": {"body": Vector3(0.3, 0.35, 0.65), "head": Vector3(0.12, 0.14, 0.18), "leg": 0.45, "speed": 0.9, "idle": 0.6, "bird": true, "fan": true},
	"camel": {"body": Vector3(0.75, 1.0, 2.4), "head": Vector3(0.3, 0.32, 0.6), "leg": 1.4, "speed": 0.9, "idle": 0.6, "hump": true, "tail": true, "neck": true},
}
const COLORS := {"cow": ["e8e2d6", "7a4a2f", "c9b9a4"], "dog": ["a68a63", "4d4036", "d9cdb8"], "goat": ["e2dccf", "3a3330", "9c7a55"], "monkey": ["8f7b66", "b09c86"], "pigeon": ["6d6f7a", "9aa0ad"], "peacock": ["1f6f8f", "1e8a63"], "camel": ["c9a56e"]}
# Rigged CC0 models (Quaternius farm pack) replace the box builds where one exists.
const MODELS := {"cow": {"scene": "res://assets/animals/cow.glb", "scale": 0.24, "tints": ["ffffff", "c9a98a", "8a7a6a"]}, "dog": {"scene": "res://assets/animals/pug.glb", "scale": 0.22, "tints": ["ffffff", "b8a58a", "7a6a5a"]}, "goat": {"scene": "res://assets/animals/sheep.glb", "scale": 0.2, "tints": ["ffffff", "d9cdb8", "9c8a70"]}}

func _ready() -> void:
	name = "Animals"
	cube.size = Vector3.ONE
	sphere.radius = 0.5
	sphere.height = 1.0
	sphere.radial_segments = 10
	sphere.rings = 5

func material(hex: String) -> StandardMaterial3D:
	if not mats.has(hex):
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(hex)
		mat.roughness = 0.95
		mats[hex] = mat
	return mats[hex]

func part(parent: Node3D, at: Vector3, size: Vector3, hex: String, round := false) -> MeshInstance3D:
	var piece := MeshInstance3D.new()
	piece.mesh = sphere if round else cube
	piece.position = at
	piece.scale = size
	piece.material_override = material(hex)
	piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(piece)
	return piece

func spawn(kind: String, at: Vector3, area: Rect2, variant := 0, ground_y := 0.0) -> Node3D:
	var spec: Dictionary = KINDS[kind]
	var hex: String = COLORS[kind][variant % COLORS[kind].size()]
	var dark := "2b2622"
	var root := Node3D.new()
	root.name = kind.capitalize() + "_%02d" % creatures.size()
	root.position = at
	add_child(root)
	var body := Node3D.new()
	root.add_child(body)
	if MODELS.has(kind):
		var model_spec: Dictionary = MODELS[kind]
		var model: Node3D = load(model_spec.scene).instantiate()
		model.scale = Vector3.ONE * model_spec.scale
		model.rotation.y = PI
		body.add_child(model)
		var tint := Color(model_spec.tints[variant % model_spec.tints.size()])
		for mesh in model.find_children("*", "MeshInstance3D", true, false):
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			for surface in range(mesh.mesh.get_surface_count()):
				var original = mesh.get_active_material(surface)
				if original is StandardMaterial3D:
					var mat: StandardMaterial3D = original.duplicate()
					mat.albedo_color = mat.albedo_color * tint
					mat.roughness = 0.9
					mesh.set_surface_override_material(surface, mat)
		var players := model.find_children("*", "AnimationPlayer", true, false)
		var animator: AnimationPlayer = players[0] if players.size() > 0 else null
		var clips := {}
		if animator != null:
			for clip_name in animator.get_animation_list():
				var short := str(clip_name).get_slice("|", str(clip_name).count("|"))
				clips[short] = clip_name
				animator.get_animation(clip_name).loop_mode = Animation.LOOP_LINEAR
			if clips.has("Idle"):
				animator.play(clips["Idle"])
				animator.seek(randf() * 2.0, true)
		creatures.append({"root": root, "body": body, "legs": [], "wings": [], "kind": kind, "spec": spec, "area": area, "target": at, "wait": randf_range(0.5, 3.0), "phase": randf() * TAU, "speed": spec.speed * randf_range(0.8, 1.2), "ground": ground_y, "resting": false, "rest_timer": 0.0, "animator": animator, "clips": clips, "current": "Idle"})
		return root
	var leg_h: float = spec.leg
	var body_size: Vector3 = spec.body
	body.position.y = leg_h
	part(body, Vector3(0, body_size.y / 2, 0), body_size, hex, spec.has("bird"))
	if spec.has("hump"):
		part(body, Vector3(0, body_size.y * 0.95, -body_size.z * 0.1), Vector3(body_size.x * 0.8, body_size.y * 0.5, body_size.z * 0.4), hex, true)
	var head_at := Vector3(0, body_size.y * 0.9, -body_size.z / 2 - spec.head.z * 0.4)
	if spec.has("neck"):
		part(body, Vector3(0, body_size.y * 1.2, -body_size.z / 2 - 0.2), Vector3(0.3, 1.0, 0.35), hex)
		head_at = Vector3(0, body_size.y * 1.7, -body_size.z / 2 - 0.45)
	var head := part(body, head_at, spec.head, hex)
	part(head, Vector3(-0.3, 0.25, -0.35), Vector3(0.18, 0.18, 0.18), dark)
	part(head, Vector3(0.3, 0.25, -0.35), Vector3(0.18, 0.18, 0.18), dark)
	if spec.has("bird"):
		part(head, Vector3(0, 0, -0.6), Vector3(0.25, 0.2, 0.5), "d9a441")
	else:
		part(head, Vector3(0, -0.2, -0.45), Vector3(0.7, 0.4, 0.25), "d8b6a3" if kind != "monkey" else "e0c5b0")
	if spec.has("horns"):
		for s in [-1, 1]:
			part(head, Vector3(s * 0.4, 0.6, 0.1), Vector3(0.16, 0.6, 0.16), "d9cdb8")
	if spec.has("ears"):
		for s in [-1, 1]:
			part(head, Vector3(s * 0.6, 0.35, 0.1), Vector3(0.15, 0.4, 0.35), hex)
	if spec.has("tail"):
		part(body, Vector3(0, body_size.y * 0.8, body_size.z / 2 + 0.1), Vector3(0.05, body_size.y * 0.6, 0.06), hex if kind != "cow" else dark)
	if spec.has("fan"):
		for i in range(9):
			var a := -0.9 + i * 0.225
			var feather := part(body, Vector3(sin(a) * 0.7, body_size.y * 0.6 + cos(a) * 0.7, body_size.z / 2 + 0.1), Vector3(0.12, 1.5, 0.03), "1e8a63" if i % 2 else "2d7fb0")
			feather.rotation.z = -a
			part(feather, Vector3(0, 0.35, 0), Vector3(1.6, 0.14, 1.5), "d9a441", true)
	var legs: Array[Node3D] = []
	var leg_positions := [Vector3(-body_size.x * 0.35, 0, -body_size.z * 0.35), Vector3(body_size.x * 0.35, 0, -body_size.z * 0.35), Vector3(-body_size.x * 0.35, 0, body_size.z * 0.35), Vector3(body_size.x * 0.35, 0, body_size.z * 0.35)]
	var leg_count := 2 if spec.has("bird") else 4
	for i in range(leg_count):
		var pivot := Node3D.new()
		pivot.position = leg_positions[i] + Vector3(0, body_size.y * 0.3, 0)
		body.add_child(pivot)
		part(pivot, Vector3(0, -(leg_h + body_size.y * 0.3) / 2, 0), Vector3(body_size.x * 0.22 if not spec.has("bird") else 0.03, leg_h + body_size.y * 0.3, body_size.x * 0.22 if not spec.has("bird") else 0.03), hex if kind != "pigeon" else "c76a4e")
		legs.append(pivot)
	if kind == "cow":
		part(body, Vector3(0, body_size.y * 0.15, body_size.z * 0.2), Vector3(0.35, 0.3, 0.4), "e6b8a2", true)
	var wings: Array[Node3D] = []
	if kind == "pigeon":
		for s in [-1, 1]:
			var wing := part(body, Vector3(s * 0.12, body_size.y * 0.7, 0), Vector3(0.28, 0.03, 0.28), hex)
			wings.append(wing)
	creatures.append({"root": root, "body": body, "legs": legs, "wings": wings, "kind": kind, "spec": spec, "area": area, "target": at, "wait": randf_range(0.5, 3.0), "phase": randf() * TAU, "speed": spec.speed * randf_range(0.8, 1.2), "ground": ground_y, "resting": false, "rest_timer": 0.0, "animator": null, "clips": {}, "current": "Idle"})
	return root

func play_clip(c: Dictionary, wanted: String) -> void:
	var animator: AnimationPlayer = c.animator
	if animator == null:
		return
	var clips: Dictionary = c.clips
	var choice := wanted if clips.has(wanted) else "Idle"
	if c.current != choice and clips.has(choice):
		animator.play(clips[choice], 0.25)
		c.current = choice

func _process(delta: float) -> void:
	for c in creatures:
		var root: Node3D = c.root
		if player != null and root.position.distance_to(player.position) > 90.0:
			continue
		var spec: Dictionary = c.spec
		var body: Node3D = c.body
		c.phase += delta
		var modelled: bool = c.animator != null
		if c.resting:
			c.rest_timer -= delta
			if modelled:
				play_clip(c, "Idle")
			else:
				body.position.y = spec.leg * 0.55 + sin(c.phase * 1.5) * 0.01
				body.rotation.x = 0.0
			if c.rest_timer <= 0:
				c.resting = false
				c.wait = 0.5
			continue
		c.wait -= delta
		var to_target: Vector3 = c.target - root.position
		to_target.y = 0
		var moving := false
		if c.wait <= 0:
			if to_target.length() < 0.4:
				var area: Rect2 = c.area
				c.target = Vector3(randf_range(area.position.x, area.end.x), root.position.y, randf_range(area.position.y, area.end.y))
				c.wait = randf_range(1.0, 4.0) * spec.idle
				if spec.has("sits") or c.kind in ["cow", "dog"]:
					if randf() < 0.3:
						c.resting = true
						c.rest_timer = randf_range(6.0, 18.0)
			else:
				moving = true
				var direction := to_target.normalized()
				if player != null and c.kind != "cow":
					var away := root.position - player.position
					away.y = 0
					if away.length() < 1.6:
						direction = (direction + away.normalized() * 1.5).normalized()
				var step: float = c.speed * delta
				root.position += direction * step
				if world != null and world.has_method("terrain_height"):
					var ground: float = world.terrain_height(root.position.x, root.position.z)
					root.position.y = maxf(c.ground, ground)
				root.rotation.y = lerp_angle(root.rotation.y, atan2(-direction.x, -direction.z), delta * 5)
		if modelled:
			play_clip(c, "Walk" if moving else "Idle")
			if moving and not c.clips.has("Walk"):
				body.position.y = absf(sin(c.phase * 7.0 * c.speed)) * 0.05
			else:
				body.position.y = 0.0
			continue
		var swing := sin(c.phase * (9.0 if spec.has("bird") else 6.0) * c.speed) * (0.55 if moving else 0.0)
		var legs: Array = c.legs
		for i in range(legs.size()):
			var pivot: Node3D = legs[i]
			pivot.rotation.x = swing * (1 if (i % 2 == 0) == (i < 2) else -1)
		body.position.y = spec.leg + (absf(sin(c.phase * 6.0 * c.speed)) * 0.04 if moving else sin(c.phase * 1.2) * 0.01)
		if c.kind == "pigeon":
			for i in range(c.wings.size()):
				var wing: Node3D = c.wings[i]
				wing.rotation.z = (sin(c.phase * 18.0) * 0.8 if moving else 0.05) * (1 if i == 0 else -1)
		if c.kind == "peacock":
			body.rotation.x = 0.0

func populate(player_node: Node3D, world_node: Node3D) -> void:
	player = player_node
	world = world_node
	# Hawa Mahal Road: cows and dogs on the footpath edge, pigeons by the facade, a camel for tourists.
	spawn("cow", Vector3(-9.0, 0, 28.0), Rect2(-9.6, 4.0, 1.6, 30.0), 0)
	spawn("cow", Vector3(8.6, 0, -24.0), Rect2(7.6, -36.0, 2.0, 26.0), 1)
	spawn("dog", Vector3(10.5, 0.2, 10.0), Rect2(9.9, -34.0, 2.6, 68.0), 0, 0.2)
	spawn("dog", Vector3(-10.8, 0.2, -6.0), Rect2(-11.6, -36.0, 2.6, 60.0), 1, 0.2)
	for i in range(6):
		spawn("pigeon", Vector3(-11.0 + randf_range(-0.8, 0.8), 0.2, -30.0 + i * 3.0), Rect2(-12.6, -39.0, 2.6, 36.0), i, 0.2)
	spawn("camel", Vector3(-8.0, 0, 36.0), Rect2(-8.6, 30.0, 1.4, 7.0), 0)
	# Old gali: monkeys on the rooftops, a goat and a dog in the lane.
	spawn("monkey", Vector3(-30.0, 7.4, 23.0), Rect2(-62.0, 22.5, 30.0, 1.0), 0, 7.4)
	spawn("monkey", Vector3(-44.0, 8.2, 17.0), Rect2(-62.0, 16.5, 30.0, 1.0), 1, 8.2)
	spawn("goat", Vector3(-30.0, 0.1, 19.0), Rect2(-62.0, 18.6, 44.0, 2.8), 0, 0.1)
	spawn("dog", Vector3(-50.0, 0.1, 21.0), Rect2(-62.0, 18.6, 44.0, 2.8), 2, 0.1)
	# Chandpole and Sikar Road: a cow at the kerb, dogs, pigeons on the gate.
	spawn("cow", Vector3(-8.5, 0, -78.0), Rect2(-9.5, -96.0, 1.8, 30.0), 2)
	spawn("dog", Vector3(11.0, 0.2, -60.0), Rect2(9.9, -96.0, 2.6, 50.0), 0, 0.2)
	for i in range(4):
		spawn("pigeon", Vector3(-6.0 + i * 4.0, 12.8, -118.0), Rect2(-8.0, -119.0, 16.0, 2.0), i, 12.8)
	spawn("dog", Vector3(-12.0, 0.2, -200.0), Rect2(-13.5, -290.0, 2.5, 140.0), 1, 0.2)
	spawn("cow", Vector3(12.2, 0, -270.0), Rect2(11.3, -295.0, 2.0, 50.0), 0)
	# Vidhyadhar Nagar: cows and dogs in side lanes and the park, pigeons on the temple.
	spawn("cow", Vector3(-20.0, 0, -348.0), Rect2(-38.0, -350.5, 24.0, 5.0), 1)
	spawn("cow", Vector3(20.0, 0, -354.0), Rect2(13.0, -356.5, 24.0, 5.0), 2)
	spawn("dog", Vector3(-9.8, 0.2, -380.0), Rect2(-11.3, -470.0, 2.5, 160.0), 2, 0.2)
	spawn("dog", Vector3(26.0, 0.3, -400.0), Rect2(13.0, -440.0, 26.0, 60.0), 0, 0.3)
	for i in range(4):
		spawn("pigeon", Vector3(-15.0 + i * 1.2, 4.4, -452.0 + (i % 2)), Rect2(-19.0, -454.0, 5.0, 4.0), i, 4.4)
	spawn("goat", Vector3(-20.0, 0, -420.0), Rect2(-38.0, -422.5, 24.0, 5.0), 1)
	# Hills: peacocks, goats and monkeys on the slopes.
	spawn("peacock", Vector3(-20.0, 0, -530.0), Rect2(-40.0, -570.0, 30.0, 40.0), 0)
	spawn("peacock", Vector3(24.0, 0, -545.0), Rect2(12.0, -575.0, 30.0, 40.0), 1)
	spawn("goat", Vector3(-30.0, 0, -560.0), Rect2(-60.0, -600.0, 40.0, 50.0), 2)
	spawn("goat", Vector3(34.0, 0, -556.0), Rect2(14.0, -600.0, 40.0, 50.0), 0)
	spawn("monkey", Vector3(6.0, 0, -596.0), Rect2(-14.0, -612.0, 28.0, 20.0), 1)
	spawn("monkey", Vector3(-6.0, 0, -590.0), Rect2(-14.0, -612.0, 28.0, 20.0), 0)
	for c in creatures:
		if world != null and world.has_method("terrain_height"):
			var root: Node3D = c.root
			root.position.y = maxf(c.ground, world.terrain_height(root.position.x, root.position.z))
