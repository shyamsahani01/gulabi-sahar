extends Node3D

var mats: Dictionary = {}
var batches: Dictionary = {}
var cube := BoxMesh.new()
var collision_root := StaticBody3D.new()
var round_batches: Dictionary = {}
var arch_batches: Dictionary = {}
var hindi_font = preload("res://assets/fonts/NotoSansDevanagari-Regular.ttf")
var skip_lighting := false

func _ready() -> void:
	cube.size = Vector3.ONE
	add_child(collision_root)
	make_materials()
	if not skip_lighting:
		lighting()
	build_street()
	flush_batches()
	flush_rounds()
	flush_arches()

func make_materials() -> void:
	var colors := {"plaster": Color("bf7966"), "rose": Color("c88a72"), "ochre": Color("caa17b"), "trim": Color("b9a58d"), "stone": Color("9c8e79"), "road": Color("66615a"), "dark": Color("293637"), "wood": Color("534232"), "metal": Color("303c3c"), "cloth": Color("84634d"), "green": Color("4e6450"), "brick": Color("9c6654"), "gold": Color("b78b54"), "red": Color("b64e36"), "yellow": Color("d6a84f"), "sack": Color("a5916e"), "leaves": Color("405c3f"), "leaves_light": Color("657952"), "poster": Color("bdb194"), "paper": Color("d6c4a1")}
	for key in colors:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = colors[key]
		mat.roughness = 0.9
		mat.metallic_specular = 0.2
		if key in ["plaster", "rose", "ochre", "stone", "road", "brick"]:
			var noise := FastNoiseLite.new()
			noise.seed = 71
			noise.frequency = 0.08
			var tex := NoiseTexture2D.new()
			tex.width = 128
			tex.height = 128
			tex.noise = noise
			tex.seamless = true
			var ramp := Gradient.new()
			ramp.set_color(0, Color(0.63, 0.61, 0.57))
			ramp.set_color(1, Color(1.0, 0.97, 0.92))
			tex.color_ramp = ramp
			mat.albedo_texture = tex
			mat.uv1_triplanar = true
			mat.uv1_world_triplanar = true
			mat.uv1_scale = Vector3(1.2, 1.2, 1.2)
		if key in ["plaster", "rose", "ochre", "road"]:
			var source := "asphalt" if key == "road" else "weathered"
			mat.albedo_texture = load("res://assets/textures/" + source + "_Diffuse.jpg")
			mat.normal_enabled = true
			mat.normal_texture = load("res://assets/textures/" + source + "_nor_gl.jpg")
			mat.normal_scale = 0.25
			mat.roughness_texture = load("res://assets/textures/" + source + "_Rough.jpg")
			mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
			mat.uv1_scale = Vector3.ONE * (0.25 if key == "road" else 0.45)
			if key == "road":
				mat.albedo_color = Color(0.80, 0.78, 0.74)
			else:
				mat.albedo_color = Color(0.76, 0.71, 0.67) if key == "plaster" else Color(0.85, 0.79, 0.72)
		mats[key] = mat

func box(pos: Vector3, size: Vector3, key: String, solid := false, rot := Vector3.ZERO) -> void:
	var transform := Transform3D(Basis.from_euler(rot).scaled(size), pos)
	if not batches.has(key):
		batches[key] = []
	batches[key].append(transform)
	if solid:
		var collision := CollisionShape3D.new()
		var bounds := BoxShape3D.new()
		bounds.size = size
		collision.shape = bounds
		collision.position = pos
		collision.rotation = rot
		collision_root.add_child(collision)

func flush_batches() -> void:
	for key in batches:
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = cube
		multimesh.instance_count = batches[key].size()
		for i in range(batches[key].size()):
			multimesh.set_instance_transform(i, batches[key][i])
		var instance := MultiMeshInstance3D.new()
		instance.multimesh = multimesh
		instance.material_override = mats[key]
		add_child(instance)

func lighting() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-32, -38, 0)
	sun.light_color = Color("fff1db")
	sun.light_energy = 0.65
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 48
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.shadow_bias = 0.035
	add_child(sun)
	var world := WorldEnvironment.new()
	var env := Environment.new()
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("799fae")
	sky_mat.sky_horizon_color = Color("d9c9ad")
	sky_mat.ground_bottom_color = Color("82735e")
	sky_mat.ground_horizon_color = Color("d9c9ad")
	sky.sky_material = sky_mat
	env.sky = sky
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("bac9cd")
	env.ambient_light_energy = 0.52
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)

func label3d(pos: Vector3, content: String, side: int, color := Color("ead8b3"), font_size := 54) -> void:
	var label := Label3D.new()
	label.text = content
	label.position = pos
	label.rotation.y = side * -PI / 2
	label.font_size = font_size
	label.font = hindi_font
	label.pixel_size = 0.006
	label.modulate = color
	label.outline_size = 3
	add_child(label)

func arch(x: float, y: float, z: float, radius: float, rot_y := 0.0) -> void:
	if not arch_batches.has(radius):
		arch_batches[radius] = []
	arch_batches[radius].append(Transform3D(Basis.from_euler(Vector3(0, rot_y, 0)), Vector3(x, y, z)))

func quad(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	for point in [a, b, c, a, c, d]:
		surface.add_vertex(point)

func flush_arches() -> void:
	for radius in arch_batches:
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		var inner: float = radius - 0.13
		for segment in range(24):
			var a := segment * PI / 24
			var b := (segment + 1) * PI / 24
			var points: Array[Vector3] = []
			for x in [-0.12, 0.12]:
				for r in [inner, radius]:
					for angle in [a, b]:
						points.append(Vector3(x, sin(angle) * r, cos(angle) * r))
			quad(surface, points[0], points[1], points[3], points[2])
			quad(surface, points[4], points[6], points[7], points[5])
			quad(surface, points[2], points[3], points[7], points[6])
			quad(surface, points[0], points[4], points[5], points[1])
		surface.generate_normals()
		var batch := MultiMesh.new()
		batch.transform_format = MultiMesh.TRANSFORM_3D
		batch.mesh = surface.commit()
		batch.instance_count = arch_batches[radius].size()
		for i in range(batch.instance_count):
			batch.set_instance_transform(i, arch_batches[radius][i])
		var instance := MultiMeshInstance3D.new()
		instance.multimesh = batch
		var mat: StandardMaterial3D = mats["trim"].duplicate()
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		instance.material_override = mat
		add_child(instance)

func build_street() -> void:
	box(Vector3(0, -0.35, 0), Vector3(32, 0.7, 68), "stone", true)
	box(Vector3(0, 0.015, 0), Vector3(10, 0.03, 64), "road")
	for side in [-1, 1]:
		# Gradual ramps allow walking onto the sidewalks.
		box(Vector3(side * 5.25, 0.08, 0), Vector3(0.6, 0.16, 64), "stone", true, Vector3(0, 0, side * 0.22))
		box(Vector3(side * 6.5, 0.14, 0), Vector3(2, 0.28, 64), "stone", true)
		for i in range(64):
			box(Vector3(side * 6.5, 0.285, -31.5 + i), Vector3(1.95, 0.01, 0.025), "wood")
		for i in range(6):
			building(side, -25.0 + i * 10.0, i)
		for z in [-22, -2, 18]:
			lamp(side * 5.8, z)
			box(Vector3(side * 6.3, 0.52, z + 3), Vector3(0.65, 0.55, 0.65), "brick", true)
			for offset in [-0.18, 0, 0.18]:
				box(Vector3(side * 6.3 + offset, 1.0, z + 3), Vector3(0.3, 0.65, 0.35), "green")
		box(Vector3(side * 15, 3, 0), Vector3(0.5, 6, 68), "plaster", true)
		# Overhead service cables are thin geometry, with no extra lights.
		for x in [side * 6.8, side * 7.1]:
			box(Vector3(x, 5.9, 0), Vector3(0.025, 0.025, 62), "metal")
	# A closed decorative gateway bounds each end of the walkable block.
	for z in [-32, 32]:
		box(Vector3(0, 1, z), Vector3(30, 2, 0.6), "plaster", true)
		box(Vector3(0, 6.3, z), Vector3(15.8, 1.3, 1.2), "rose")
		box(Vector3(0, 7.1, z), Vector3(16.4, 0.3, 1.5), "trim")
		for x in [-7, 7]:
			box(Vector3(x, 3.2, z), Vector3(1.7, 6.4, 1.7), "rose", true)
			box(Vector3(x, 6.8, z), Vector3(2.2, 0.35, 2.2), "trim")
	for end in [-1, 1]:
		for i in range(7):
			var distant_height := 4.0 + (i % 3) * 1.5
			box(Vector3(-15 + i * 5, distant_height / 2, end * 43), Vector3(4.8, distant_height, 6), "plaster")
			box(Vector3(-15 + i * 5, distant_height, end * 43), Vector3(5.0, 0.2, 6.2), "trim")
	var gate_label := Label3D.new()
	gate_label.text = "GULABI SAHAR"
	gate_label.position = Vector3(0, 6.2, -31.3)
	gate_label.font_size = 76
	gate_label.pixel_size = 0.009
	gate_label.modulate = Color("fff0ce")
	add_child(gate_label)

func building(side: int, z: float, index: int) -> void:
	var height := 7.1 + (index % 3) * 0.6
	var wall: String = ["plaster", "rose", "ochre"][index % 3]
	# Upper storeys, side walls and rear wall leave real ground-floor shop depth.
	box(Vector3(side * 10.6, (height + 3.1) / 2, z), Vector3(6.2, height - 3.1, 9.7), wall, true)
	box(Vector3(side * 13.6, 1.6, z), Vector3(0.25, 3.2, 9.7), wall, true)
	box(Vector3(side * 10.6, 0.18, z), Vector3(6.2, 0.36, 9.7), "stone", true)
	for edge in [-1, 1]:
		box(Vector3(side * 10.6, 1.6, z + edge * 4.7), Vector3(6.2, 3.2, 0.25), wall, true)
	var face := side * 7.43
	# Plinth, string courses and cornice.
	for y in [3.15, 6.1, height]:
		box(Vector3(face, y, z), Vector3(0.26, 0.22, 9.8), "trim")
	for dz in [-4.65, 4.65]:
		box(Vector3(face, height / 2, z + dz), Vector3(0.23, height, 0.26), "trim")
	for dz in [-3.0, 0.0, 3.0]:
		var open_shop := (index + int(dz)) % 3 != 0
		if open_shop:
			box(Vector3(side * 11.2, 1.45, z + dz), Vector3(0.2, 2.1, 2.3), "wood")
			for level in range(3):
				box(Vector3(side * 10.9, 0.7 + level * 0.5, z + dz), Vector3(0.65, 0.07, 2.0), "wood")
				for item in range(6):
					box(Vector3(side * 10.7, 0.88 + level * 0.5, z + dz - 0.8 + item * 0.32), Vector3(0.18, 0.29, 0.22), ["red", "yellow", "green", "paper"][(item + level + index) % 4])
			box(Vector3(face - side * 0.02, 2.62, z + dz), Vector3(0.15, 0.45, 2.2), "metal")
			# A counter, sacks and stocked shelves sit behind the shop opening.
			box(Vector3(side * 8.5, 0.76, z + dz), Vector3(0.65, 0.85, 1.9), "wood", true)
			box(Vector3(side * 8.5, 1.23, z + dz), Vector3(0.8, 0.09, 2.0), "stone")
			for item in range(4):
				round_prop(Vector3(side * 8.45, 1.37, z + dz - 0.65 + item * 0.4), Vector3(0.16, 0.2, 0.16), "gold" if index % 2 else "red")
		else:
			box(Vector3(face - side * 0.03, 1.53, z + dz), Vector3(0.12, 2.0, 2.15), "wood", true)
			for shutter in range(12):
				box(Vector3(face - side * 0.10, 0.6 + shutter * 0.16, z + dz), Vector3(0.08, 0.025, 2.06), "metal")
		for edge in [-1, 1]:
			box(Vector3(face - side * 0.12, 1.55, z + dz + edge * 1.17), Vector3(0.3, 2.25, 0.16), "trim")
		arch(face - side * 0.12, 2.0, z + dz, 1.16)
		# Upper jharokha windows and small projecting balconies.
		box(Vector3(face - side * 0.05, 4.55, z + dz), Vector3(0.15, 1.65, 1.3), "dark")
		arch(face - side * 0.15, 5.2, z + dz, 0.73)
		for edge in [-1, 1]:
			box(Vector3(face - side * 0.19, 4.55, z + dz + edge * 0.75), Vector3(0.22, 1.7, 0.13), "trim")
		for bar in [-0.4, 0.0, 0.4]:
			box(Vector3(face - side * 0.22, 4.55, z + dz + bar), Vector3(0.12, 1.5, 0.04), "wood")
		box(Vector3(face - side * 0.45, 3.75, z + dz), Vector3(0.95, 0.16, 1.9), "trim")
		box(Vector3(face - side * 0.8, 4.0, z + dz), Vector3(0.1, 0.5, 1.8), "rose")
		for bar in range(7):
			box(Vector3(face - side * 0.86, 4.05, z + dz - 0.75 + bar * 0.25), Vector3(0.08, 0.38, 0.06), "trim")
		box(Vector3(face - side * 0.3, 5.95, z + dz), Vector3(0.8, 0.15, 2.1), "trim")
	for dz in range(10):
		box(Vector3(face, height + 0.28, z - 4.5 + dz), Vector3(0.25, 0.4, 0.45), "rose")
	# Shop canopy and signs face inward toward the road.
	box(Vector3(face - side * 0.8, 2.8, z), Vector3(1.65, 0.10, 7.9), "green" if index % 2 else "cloth", false, Vector3(0, 0, side * 0.12))
	box(Vector3(face - side * 0.08, 3.48, z), Vector3(0.15, 0.5, 6.4), "dark")
	var shops := ["गुलाबी वस्त्र भण्डार", "गुलाबी चाय • GULABI CHAI", "जयपुर हस्तशिल्प", "शर्मा किराना स्टोर", "राजस्थान माटी कला", "सहर पुस्तक भण्डार"]
	label3d(Vector3(face - side * 0.18, 3.49, z), shops[index], side, Color("ead8b3"), 42)
	roof_and_details(side, z, index, height, face)
	if index % 2 == 1:
		box(Vector3(side * 6.7, 0.67, z + 1.8), Vector3(0.65, 0.8, 1.5), "wood", true)
		box(Vector3(side * 6.7, 1.13, z + 1.8), Vector3(0.8, 0.12, 1.65), "trim")

func lamp(x: float, z: float) -> void:
	box(Vector3(x, 0.45, z), Vector3(0.32, 0.6, 0.32), "metal", true)
	box(Vector3(x, 2.25, z), Vector3(0.10, 4.2, 0.10), "metal")
	box(Vector3(x, 4.35, z), Vector3(0.65, 0.12, 0.65), "metal")
	box(Vector3(x, 4.05, z), Vector3(0.40, 0.48, 0.40), "gold")
	box(Vector3(x, 3.8, z), Vector3(0.52, 0.10, 0.52), "metal")

func round_prop(pos: Vector3, size: Vector3, key: String) -> void:
	if not round_batches.has(key):
		round_batches[key] = []
	round_batches[key].append(Transform3D(Basis.IDENTITY.scaled(size), pos))

func flush_rounds() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1
	sphere.radial_segments = 10
	sphere.rings = 5
	for key in round_batches:
		var batch := MultiMesh.new()
		batch.transform_format = MultiMesh.TRANSFORM_3D
		batch.mesh = sphere
		batch.instance_count = round_batches[key].size()
		for i in range(batch.instance_count):
			batch.set_instance_transform(i, round_batches[key][i])
		var instance := MultiMeshInstance3D.new()
		instance.multimesh = batch
		instance.material_override = mats[key]
		add_child(instance)

func roof_and_details(side: int, z: float, index: int, height: float, face: float) -> void:
	# Water tanks, drain pipes, air-conditioners and washing break the repeated facade.
	box(Vector3(side * 9.5, height + 0.3, z + 1.8), Vector3(1.4, 0.5, 1.4), "stone")
	round_prop(Vector3(side * 9.5, height + 1.1, z + 1.8), Vector3(1.3, 1.5, 1.3), "metal")
	box(Vector3(face - side * 0.2, height / 2, z - 4.15), Vector3(0.1, height, 0.1), "metal")
	if index % 2 == 0:
		box(Vector3(face - side * 0.4, 4.65, z - 1.5), Vector3(0.7, 0.55, 0.85), "stone")
		for slot in range(6):
			box(Vector3(face - side * 0.77, 4.45 + slot * 0.07, z - 1.5), Vector3(0.02, 0.025, 0.65), "metal")
		box(Vector3(face - side * 0.3, 6.65, z), Vector3(0.06, 0.03, 3.8), "wood")
		for cloth in range(4):
			box(Vector3(face - side * 0.35, 6.3, z - 1.2 + cloth * 0.8), Vector3(0.035, 0.65, 0.5), ["paper", "green", "red", "cloth"][cloth])
	# Worn plaster at human height, exposed brickwork, old notices.
	for patch in range(4):
		var pz := z - 4.4 + patch * 0.18
		box(Vector3(face - side * 0.16, 0.7 + (patch % 2) * 0.17, pz), Vector3(0.025, 0.14, 0.30), "brick")
	box(Vector3(face - side * 0.18, 1.6, z - 4.35), Vector3(0.025, 0.75, 0.48), "poster")
	box(Vector3(face - side * 0.20, 1.67, z - 4.35), Vector3(0.02, 0.12, 0.40), "red")
	if index % 2 == 1:
		# Handcart: wheels, frame, timber slats, crates and a pile of produce.
		var x := side * 6.4
		var pz := z + 2.2
		box(Vector3(x, 0.9, pz), Vector3(1.0, 0.12, 1.6), "wood", true)
		for edge in [-1, 1]:
			round_prop(Vector3(x + edge * 0.55, 0.65, pz), Vector3(0.12, 0.72, 0.72), "metal")
			box(Vector3(x + edge * 0.43, 1.06, pz), Vector3(0.08, 0.28, 1.65), "wood")
		for row in range(5):
			for col in range(3):
				round_prop(Vector3(x - 0.25 + col * 0.23, 1.12, pz - 0.55 + row * 0.25), Vector3(0.22, 0.18, 0.22), "red" if index == 1 else "yellow")
		for i in range(2):
			round_prop(Vector3(side * 7.05, 0.7, z - 1 + i * 0.7), Vector3(0.45, 0.85, 0.5), "sack")
	# Tree: branched trunk and individually shaped crown rather than cube foliage.
	if index == 2 or index == 5:
		var tx := side * 6.8
		box(Vector3(tx, 1.9, z - 2.3), Vector3(0.2, 3.4, 0.2), "wood", true)
		for branch in range(5):
			var angle := branch * TAU / 5
			var branch_center := Vector3(tx + cos(angle) * 0.65, 3.5 + sin(branch * 1.7) * 0.35, z - 2.3 + sin(angle) * 0.65)
			box(branch_center - Vector3(0, 0.3, 0), Vector3(0.06, 1.2, 0.06), "wood", false, Vector3(sin(angle) * 0.5, 0, cos(angle) * 0.5))
			for leaf in range(36):
				var theta := leaf * 2.399963
				var radius := sqrt(float(leaf) / 36) * 0.85
				var offset := Vector3(cos(theta) * radius, sin(leaf * 1.7) * 0.55, sin(theta) * radius)
				round_prop(branch_center + offset, Vector3(0.32, 0.09, 0.45), "leaves_light" if leaf % 3 == 0 else "leaves")
