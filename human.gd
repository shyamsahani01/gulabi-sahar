extends Node3D

var skeleton: Skeleton3D
var model: Node3D
var hero_scene: PackedScene = preload("res://assets/characters/shyam_hero_v06.glb")
var time := 0.0
var movement_speed := 0.0
var grounded := true
var talking := false
var variant := 0
var crowd := false
var animator: AnimationPlayer
static var shared_library: AnimationLibrary
var bones: Dictionary = {}
var face: MeshInstance3D
var expression := "Neutral"
var expression_time := 0.0
var blink_clock := 1.8
var blink_phase := -1.0
const EXPRESSIONS := ["Neutral", "Smile", "Serious", "Surprised"]

func set_expression(value: String, duration: float = 5.0) -> void:
	if value in EXPRESSIONS:
		expression = value
		expression_time = duration

func cycle_expression() -> void:
	set_expression(EXPRESSIONS[(EXPRESSIONS.find(expression) + 1) % EXPRESSIONS.size()], 3600.0)

func update_face(delta: float) -> void:
	if face == null:
		return
	expression_time = maxf(0, expression_time - delta)
	if expression_time == 0:
		expression = "Serious" if movement_speed > 4 else "Neutral"
	blink_clock -= delta
	if blink_clock <= 0 and blink_phase < 0:
		blink_phase = 0
		blink_clock = randf_range(2.8, 5.5)
	var blink := 0.0
	if blink_phase >= 0:
		blink_phase += delta
		blink = sin(clampf(blink_phase / 0.18, 0, 1) * PI)
		if blink_phase >= 0.18:
			blink_phase = -1
	for i in range(face.mesh.get_blend_shape_count()):
		var shape := str(face.mesh.get_blend_shape_name(i))
		var target := blink if shape.begins_with("Blink") else (1.0 if shape == expression else 0.0)
		face.set_blend_shape_value(i, move_toward(face.get_blend_shape_value(i), target, delta * 10))

func _ready() -> void:
	model = (preload("res://assets/characters/crowd_walk.glb") if crowd else hero_scene).instantiate()
	model.rotation.y = PI
	add_child(model)
	skeleton = model.find_children("*", "Skeleton3D", true, false)[0]
	for i in range(skeleton.get_bone_count()):
		var name_key := skeleton.get_bone_name(i)
		bones[name_key] = i
	var shirts := [Color("b5a482"), Color("759591"), Color("b57965"), Color("657b97"), Color("d0bfa2"), Color("8f857b")]
	var trousers := [Color("29383f"), Color("4c4540"), Color("343a4e")]
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		if not crowd and mesh.mesh.get_blend_shape_count() > 0 and (face == null or mesh.name.begins_with("HeroFace")):
			face = mesh
		mesh.visibility_range_end = 55
		mesh.visibility_range_end_margin = 3
		for surface in range(mesh.mesh.get_surface_count()):
			var original = mesh.get_active_material(surface)
			if not original is StandardMaterial3D:
				continue
			var mat: StandardMaterial3D = original.duplicate()
			mat.metallic = 0.0
			mat.metallic_specular = 0.15
			mat.roughness = 0.85
			if mesh.name.begins_with("HeroEye"):
				mat.roughness = 0.22
				mat.metallic_specular = 0.45
			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			if "eyebrow" in mesh.name or "short01" in mesh.name:
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				mat.alpha_scissor_threshold = 0.35
				mat.albedo_texture = preload("res://assets/characters/shyam_eyebrow003.png") if "eyebrow" in mesh.name else preload("res://assets/characters/shyam_short01_diffuse.png")
				mat.albedo_color = Color.WHITE
			if "t-shirt" in mesh.name:
				mat.albedo_color = shirts[variant % shirts.size()] if crowd else Color("eee8d9")
			elif "pants" in mesh.name:
				mat.albedo_color = trousers[variant % trousers.size()] if crowd else Color("34363b")
			elif "low-poly" in mesh.name:
				mat.albedo_texture = preload("res://assets/characters/shyam_brown_eye.png")
				mat.albedo_color = Color.WHITE
			elif mesh.name == "Shyam" or mesh.name == "Shyam_gltf":
				mat.albedo_texture = preload("res://assets/characters/shyam_young_lightskinned_male_diffuse3.png") if crowd else preload("res://assets/characters/shyam_approved_skin.png")
				mat.albedo_color = (Color(0.77, 0.66, 0.55) if variant % 3 == 0 else Color(0.90, 0.78, 0.66)) if crowd else Color.WHITE
			if not crowd and hero_scene.resource_path != "res://assets/characters/shyam_hero.glb" and ("t-shirt" in mesh.name or "pants" in mesh.name):
				var fabric := ShaderMaterial.new()
				fabric.shader = preload("res://assets/shaders/woven_fabric.gdshader")
				fabric.set_shader_parameter("cloth_color", Color("e6e1d5") if "t-shirt" in mesh.name else Color("36383b"))
				fabric.set_shader_parameter("denim", 1.0 if "pants" in mesh.name else 0.0)
				mesh.set_surface_override_material(surface, fabric)
			else:
				mesh.set_surface_override_material(surface, mat)
	for side in ["l", "r"]:
		var attachment := BoneAttachment3D.new()
		attachment.bone_name = "foot_" + side
		skeleton.add_child(attachment)
		var shoe := MeshInstance3D.new()
		var shape := SphereMesh.new()
		shape.radius = 0.5
		shape.height = 1
		shape.radial_segments = 12
		shape.rings = 6
		shoe.mesh = shape
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("302d29") if crowd else Color("777a7b")
		mat.roughness = 0.95
		shoe.material_override = mat
		var pos := Vector3(0.18 if side == "l" else -0.18, 0.065, 0.11)
		var rest := skeleton.get_bone_global_rest(bones["foot_" + side])
		shoe.transform = rest.affine_inverse() * Transform3D(Basis.IDENTITY.scaled(Vector3(0.15, 0.12, 0.32)), pos)
		attachment.add_child(shoe)
		if not crowd and hero_scene.resource_path != "res://assets/characters/shyam_hero.glb":
			shoe.visible = false
			var sneaker := Node3D.new()
			sneaker.transform = rest.affine_inverse() * Transform3D(Basis.IDENTITY, pos)
			attachment.add_child(sneaker)
			sneaker_part(sneaker, Vector3(0, -0.035, 0), Vector3(0.155, 0.03, 0.325), Color("d0c8b8"))
			sneaker_part(sneaker, Vector3(0, -0.005, -0.015), Vector3(0.145, 0.09, 0.275), Color("4d5050"))
			sneaker_part(sneaker, Vector3(0, -0.012, 0.106), Vector3(0.145, 0.06, 0.11), Color("c9c3b7"))
			for lace in range(5):
				sneaker_part(sneaker, Vector3(0, 0.037, -0.063 + lace * 0.024), Vector3(0.078, 0.005, 0.007), Color("d7d2c5"))

	configure_animations()

func sneaker_part(parent: Node3D, at: Vector3, dimensions: Vector3, color: Color) -> void:
	var piece := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	sphere.radial_segments = 20
	sphere.rings = 10
	piece.mesh = sphere
	piece.position = at
	piece.scale = dimensions
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	piece.material_override = material
	parent.add_child(piece)

func configure_animations() -> void:
	animator = model.find_children("*", "AnimationPlayer", true, false)[0]
	if shared_library == null:
		shared_library = AnimationLibrary.new()
		var idle_model = preload("res://assets/characters/shyam_idle.glb").instantiate()
		var idle_player: AnimationPlayer = idle_model.find_children("*", "AnimationPlayer", true, false)[0]
		var run_model = preload("res://assets/characters/shyam_run.glb").instantiate()
		var run_player: AnimationPlayer = run_model.find_children("*", "AnimationPlayer", true, false)[0]
		for clip_name in ["Walk", "Idle", "Run"]:
			var source: Animation = animator.get_animation(clip_name) if clip_name == "Walk" else (idle_player.get_animation(clip_name) if clip_name == "Idle" else run_player.get_animation(clip_name))
			var clip: Animation = source.duplicate(true)
			clip.loop_mode = Animation.LOOP_LINEAR
			# Keep the motion capture in place: physics controls world movement.
			for track in range(clip.get_track_count()):
				if clip.track_get_type(track) == Animation.TYPE_POSITION_3D and str(clip.track_get_path(track)) == "Shyam_rig":
					for key in range(clip.track_get_key_count(track)):
						var pos: Vector3 = clip.track_get_key_value(track, key)
						pos.x = 0
						pos.z = 0
						clip.track_set_key_value(track, key, pos)
			shared_library.add_animation(clip_name, clip)
		idle_model.free()
		run_model.free()
	for library in animator.get_animation_library_list():
		animator.remove_animation_library(library)
	animator.add_animation_library("", shared_library)
	animator.play("Idle")
	animator.seek(fmod(variant * 1.23, 8.0), true)

func _process(delta: float) -> void:
	time += delta
	update_face(delta)
	var clip := "Run" if movement_speed > 4.0 and grounded else ("Walk" if movement_speed > 0.15 and grounded else "Idle")
	if animator.current_animation != clip:
		animator.play(clip, 0.2)
	animator.speed_scale = clampf(movement_speed / 1.7, 0.5, 1.6) if clip == "Walk" else (clampf(movement_speed / 4.8, 0.8, 1.4) if clip == "Run" else 1.0)
