extends "res://street.gd"
# Native 3D environment study from photographed old-city lanes. No reference photo
# is displayed as a backdrop: all architecture and nearby props are modeled.
var rng := RandomNumberGenerator.new()
# When embedded in the world, the +z end stays open so the lane joins the main road.
var open_end := false

func make_materials() -> void:
	super.make_materials()
	var palette := {"plaster":"c99582", "rose":"c38573", "ochre":"c4ad92", "trim":"d8c7af", "stone":"a59782", "wood":"574333", "metal":"393a36", "cloth":"c39067", "green":"596f67", "dark":"292c2a", "red":"9c4e43", "yellow":"bca260", "paper":"d1bb95"}
	for key in palette:
		mats[key].albedo_color = Color(palette[key])
		mats[key].roughness = 0.93
	for key in ["plaster", "rose", "ochre"]:
		mats[key].albedo_texture = preload("res://assets/textures/plaster_Diffuse.jpg")
		mats[key].normal_texture = preload("res://assets/textures/plaster_nor_gl.jpg")
		mats[key].roughness_texture = preload("res://assets/textures/plaster_Rough.jpg")
		mats[key].uv1_scale = Vector3.ONE * 0.65
		mats[key].normal_scale = 0.4
	mats["stone"].albedo_texture = preload("res://assets/textures/plaster_Diffuse.jpg")
	mats["stone"].uv1_scale = Vector3.ONE * 0.7
	for i in range(7):
		var mat: StandardMaterial3D = mats["stone"].duplicate()
		mat.albedo_color = Color("b1a18b") * (0.88 + i * 0.026)
		mats["paver" + str(i)] = mat
	for key in ["blue", "maroon", "saffron", "ivory", "teal", "pink"]:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color({"blue":"526777", "maroon":"813f40", "saffron":"c28e4d", "ivory":"cdbc9d", "teal":"537c70", "pink":"a46475"}[key])
		mat.roughness = 0.95
		mats[key] = mat

func lighting() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-54, -25, 0)
	sun.light_color = Color("fff1df")
	sun.light_energy = 0.43
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 42
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.shadow_bias = 0.06
	sun.shadow_normal_bias = 1.5
	add_child(sun)
	var world := WorldEnvironment.new()
	var env := Environment.new()
	var sky := Sky.new()
	var material := ProceduralSkyMaterial.new()
	material.sky_top_color = Color("869fa5")
	material.sky_horizon_color = Color("d7cdc0")
	material.ground_bottom_color = Color("8d7866")
	material.ground_horizon_color = Color("d7cdc0")
	sky.sky_material = material
	env.sky = sky
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c2ccd0")
	env.ambient_light_energy = 0.48
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.0
	world.environment = env
	add_child(world)

func build_street() -> void:
	rng.seed = 4603
	# Physical boundaries preserve the cross-lane view without a fake opaque gate.
	for z in ([-27.0] if open_end else [-27.0, 27.0]):
		var limit := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3(20, 5, 0.3)
		limit.shape = shape
		limit.position = Vector3(0, 2, z)
		collision_root.add_child(limit)
	for x in [-8.5, 8.5]:
		var limit := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3(0.3, 5, 55)
		limit.shape = shape
		limit.position = Vector3(x, 2, 0)
		collision_root.add_child(limit)
	box(Vector3(0, -0.15, 0), Vector3(19, 0.3, 54), "stone", true)
	# A walkable 5.2 m lane: irregular stone slabs and a shallow side drain.
	for row in range(78):
		for col in range(8):
			var pos := Vector3(-2.27 + col * 0.65 + (0.15 if row % 2 else 0.0), 0.008 + rng.randf_range(-0.003, 0.003), -25.8 + row * 0.67)
			box(pos, Vector3(0.636, 0.025, 0.652), "paver" + str(rng.randi_range(0, 6)))
	for side in [-1, 1]:
		box(Vector3(side * 2.65, 0.035, 0), Vector3(0.22, 0.055, 52), "dark")
		box(Vector3(side * 2.88, 0.11, 0), Vector3(0.28, 0.22, 52), "stone", true)
		for i in range(7):
			lane_building(side, -23.0 + i * 7.3, i)
		# Continuous service line with real sagging cross wires below the roofs.
		cable(Vector3(side * 2.9, 5.25, -25), Vector3(side * 2.9, 5.15, 25), 0.35, 0.015)
	for z in [-17.0, -6.0, 4.5]:
		market_tarp(z)
	for z in [-19.0, -8.0, 3.0, 14.0, 23.0]:
		for wire in range(3):
			cable(Vector3(-2.95, 5.7 + wire * 0.17, z), Vector3(2.95, 5.35 + wire * 0.13, z + 1.2), 0.55, 0.009)
	# Narrow cross-lane beyond the shops keeps the view from ending in a blank wall.
	for side in [-1, 1]:
		box(Vector3(side * 4.2, 3.65, -28), Vector3(6.0, 7.3, 2.0), "rose", true)
		for y in [2.8, 5.6, 7.25]:
			box(Vector3(side * 4.2, y, -26.95), Vector3(6.1, 0.14, 0.18), "trim")
		for x in [side * 2.2, side * 4.7]:
			box(Vector3(x, 4.3, -26.9), Vector3(1.1, 1.6, 0.07), "dark")
	# Detail at the player's feet: leaves, folded packing paper, drain gratings.
	for i in range(45):
		var x := rng.randf_range(1.7, 2.65) * (-1 if i % 2 else 1)
		box(Vector3(x, 0.038, rng.randf_range(-25, 25)), Vector3(rng.randf_range(0.025, 0.12), 0.003, rng.randf_range(0.04, 0.18)), "sack" if i % 3 else "paper", false, Vector3(0, rng.randf() * TAU, 0))
	for z in [-18, -4, 8, 20]:
		for side in [-1, 1]:
			for i in range(8):
				box(Vector3(side * 2.65, 0.077, z + i * 0.065), Vector3(0.24, 0.025, 0.025), "metal")

func lane_building(side: int, z: float, index: int) -> void:
	var face := side * 3.05
	var height: float = [7.2, 8.1, 6.6, 8.6, 7.5, 6.9, 8.2][(index + (1 if side < 0 else 0)) % 7]
	var wall: String = ["rose", "plaster", "ochre", "plaster"][index % 4]
	box(Vector3(side * 5.1, (height + 3) / 2, z), Vector3(4.1, height - 3, 7.2), wall, true)
	box(Vector3(side * 7, 1.5, z), Vector3(0.2, 3, 7.2), wall, true)
	box(Vector3(side * 5.0, 0.12, z), Vector3(4.2, 0.24, 7.2), "stone", true)
	for dz in [-3.5, 0.0, 3.5]:
		box(Vector3(side * 5.1, 1.5, z + dz), Vector3(4.1, 3.0, 0.20), wall, true)
	for y in [3.05, 5.9, height]:
		box(Vector3(face, y, z), Vector3(0.22, 0.14, 7.25), "trim")
	for dz in [-1.72, 1.72]:
		var shop := index * 2 + int(dz > 0)
		for edge in [-1, 1]:
			box(Vector3(face - side * 0.05, 1.42, z + dz + edge * 1.4), Vector3(0.26, 2.84, 0.18), "trim")
		# Counter and actual stock, with a dark shop interior behind them.
		box(Vector3(side * 5.9, 1.35, z + dz), Vector3(0.13, 2.45, 2.5), "dark")
		for shelf in range(4):
			box(Vector3(side * 5.5, 0.55 + shelf * 0.46, z + dz), Vector3(0.65, 0.055, 2.5), "wood")
			for item in range(9):
				var cloth_color: String = ["maroon", "saffron", "teal", "ivory", "blue", "pink"][(item + shop + shelf) % 6]
				box(Vector3(side * 5.35, 0.68 + shelf * 0.46, z + dz - 1.1 + item * 0.26), Vector3(0.35, 0.19, 0.22), cloth_color)
		box(Vector3(side * 3.45, 0.56, z + dz), Vector3(0.65, 0.9, 2.35), "wood", true)
		box(Vector3(side * 3.45, 1.05, z + dz), Vector3(0.82, 0.08, 2.48), "stone")
		for stack in range(5):
			for layer in range(4):
				box(Vector3(side * 3.42, 1.12 + layer * 0.055, z + dz - 0.85 + stack * 0.43), Vector3(0.53, 0.048, 0.38), ["ivory", "maroon", "teal", "saffron"][(stack + layer + index) % 4])
		# Hanging textiles and narrow gold borders make the shop scale legible.
		var textile: String = ["maroon", "saffron", "teal", "pink"][(index + int(dz > 0)) % 4]
		cloth_panel(Vector3(face - side * 0.32, 1.9, z + dz + 1.05), Vector2(0.64, 1.55), textile, side)
		box(Vector3(face - side * 0.12, 2.77, z + dz), Vector3(0.13, 0.42, 2.7), "dark")
		var names := ["सहर वस्त्र भण्डार", "गुलाबी चाय", "जयपुर चूड़ी घर", "राजस्थानी जूतियाँ", "सांगानेरी प्रिन्ट", "राम राम सा किराना", "हस्तशिल्प"]
		label3d(Vector3(face - side * 0.21, 2.78, z + dz), names[shop % names.size()], side, Color("eee0c8"), 27)
		# Recessed upper windows, carved-style frame, jharokha railing and chajja.
		box(Vector3(face - side * 0.025, 4.47, z + dz), Vector3(0.08, 1.65, 1.18), "dark")
		for edge in [-1, 1]:
			box(Vector3(face - side * 0.14, 4.47, z + dz + edge * 0.68), Vector3(0.22, 1.94, 0.13), "trim")
		arch(face - side * 0.13, 4.97, z + dz, 0.72)
		for bar in range(6):
			box(Vector3(face - side * 0.12, 4.46, z + dz - 0.48 + bar * 0.19), Vector3(0.045, 1.48, 0.035), "wood")
		for y in [4.0, 4.5, 4.95]:
			box(Vector3(face - side * 0.13, y, z + dz), Vector3(0.055, 0.04, 1.08), "wood")
		box(Vector3(face - side * 0.36, 3.63, z + dz), Vector3(0.82, 0.12, 1.75), "trim")
		box(Vector3(face - side * 0.7, 3.95, z + dz), Vector3(0.085, 0.54, 1.68), "rose")
		for j in range(8):
			box(Vector3(face - side * 0.75, 3.97, z + dz - 0.71 + j * 0.20), Vector3(0.09, 0.35, 0.065), "trim")
		box(Vector3(face - side * 0.35, 5.66, z + dz), Vector3(0.80, 0.11, 1.9), "trim")
		for brace in [-0.6, 0.6]:
			box(Vector3(face - side * 0.26, 5.48, z + dz + brace), Vector3(0.42, 0.27, 0.09), "trim", false, Vector3(0, 0, side * 0.45))
	# Sloped fabric awning, not a rigid plank; posts are thin steel tubing.
	canopy(side, z, 7.0, "teal" if index % 2 else "saffron", 3.00)
	for dz in [-3.3, 3.3]:
		box(Vector3(side * 1.96, 1.45, z + dz), Vector3(0.035, 2.9, 0.035), "metal")
	for j in range(11):
		box(Vector3(face, height + 0.25, z - 3.3 + j * 0.65), Vector3(0.22, 0.5, 0.31), wall)
	# Meters, pipes and local repair patches appear where someone can reach them.
	box(Vector3(face - side * 0.18, 1.9, z - 3.15), Vector3(0.18, 0.42, 0.27), "metal")
	box(Vector3(face - side * 0.13, 3.5, z - 3.26), Vector3(0.055, 6.9, 0.055), "metal")
	for j in range(7):
		box(Vector3(face - side * 0.13, 0.4 + (j % 2) * 0.14, z - 3.4 + j * 0.17), Vector3(0.025, 0.12, 0.31), "brick")
	if index % 2 == 0:
		box(Vector3(face - side * 0.30, 6.15, z + 2.7), Vector3(0.50, 0.48, 0.67), "stone")
		for slot in range(6):
			box(Vector3(face - side * 0.57, 6.0 + slot * 0.055, z + 2.7), Vector3(0.018, 0.02, 0.54), "metal")
	if index in [2, 4]:
		chai_stall(side, z - 1)
	# Potted plants in recesses and parcels by the threshold.
	for j in range(2):
		round_prop(Vector3(side * 2.52, 0.29, z - 2.9 + j * 0.5), Vector3(0.30, 0.45, 0.3), "brick")
		for leaf in range(7):
			var a := leaf * 2.4
			round_prop(Vector3(side * 2.52 + cos(a) * 0.14, 0.59 + sin(a) * 0.05, z - 2.9 + j * 0.5 + sin(a) * 0.1), Vector3(0.24, 0.055, 0.15), "leaves")

func cloth_panel(at: Vector3, dimensions: Vector2, key: String, side: int) -> void:
	var s := SurfaceTool.new()
	s.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(12):
		var u0 := float(i) / 12
		var u1 := float(i + 1) / 12
		var a := Vector3(sin(u0 * TAU * 4) * 0.025, dimensions.y / 2, (u0 - 0.5) * dimensions.x)
		var b := Vector3(sin(u1 * TAU * 4) * 0.025, dimensions.y / 2, (u1 - 0.5) * dimensions.x)
		quad(s, a, b, b - Vector3(0, dimensions.y, 0), a - Vector3(0, dimensions.y, 0))
	s.generate_normals()
	var mesh := MeshInstance3D.new()
	mesh.mesh = s.commit()
	mesh.position = at
	var mat: StandardMaterial3D = mats[key].duplicate()
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = mat
	add_child(mesh)
	for border in [-1, 1]:
		box(at + Vector3(-side * 0.04, 0, border * dimensions.x * 0.42), Vector3(0.012, dimensions.y, 0.018), "gold")
	for motif in range(6):
		for column in [-1, 1]:
			box(at + Vector3(-side * 0.05, dimensions.y * 0.39 - motif * dimensions.y * 0.15, column * dimensions.x * 0.20), Vector3(0.008, 0.027, 0.027), "gold", false, Vector3(PI / 4, 0, 0))

func canopy(side: int, z: float, width: float, key: String, y: float) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(20):
		var a := -width / 2 + width * i / 20
		var b := -width / 2 + width * (i + 1) / 20
		var ripple_a := sin(i * PI) * 0.03
		var ripple_b := sin((i + 1) * PI) * 0.03
		quad(surface, Vector3(side * 3.2, y + 0.15, z + a), Vector3(side * 3.2, y + 0.15, z + b), Vector3(side * 1.9, y - 0.24 + ripple_b, z + b), Vector3(side * 1.9, y - 0.24 + ripple_a, z + a))
	surface.generate_normals()
	var instance := MeshInstance3D.new()
	instance.mesh = surface.commit()
	var mat: StandardMaterial3D = mats[key].duplicate()
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	instance.material_override = mat
	add_child(instance)
	for j in range(30):
		box(Vector3(side * 1.90, y - 0.30, z - width / 2 + width * j / 30), Vector3(0.018, 0.16 + (j % 2) * 0.025, width / 31), key)

func cable(start: Vector3, end: Vector3, sag: float, radius: float) -> void:
	var curve := Curve3D.new()
	for i in range(13):
		var t := float(i) / 12
		curve.add_point(start.lerp(end, t) - Vector3(0, sin(t * PI) * sag, 0))
	var polygon := PackedVector2Array()
	for i in range(5):
		polygon.append(Vector2(cos(i * TAU / 5), sin(i * TAU / 5)) * radius)
	var mesh := CSGPolygon3D.new()
	mesh.polygon = polygon
	mesh.mode = CSGPolygon3D.MODE_PATH
	var path := Path3D.new()
	path.curve = curve
	add_child(path)
	path.add_child(mesh)
	mesh.path_node = NodePath("..")
	mesh.material = mats["metal"]
	mesh.path_interval = 0.5

func chai_stall(side: int, z: float) -> void:
	box(Vector3(side * 2.4, 0.73, z), Vector3(0.75, 0.08, 1.05), "wood", true)
	for x in [-0.28, 0.28]:
		for dz in [-0.4, 0.4]:
			box(Vector3(side * 2.4 + x, 0.38, z + dz), Vector3(0.04, 0.7, 0.04), "metal")
	# Kettle with spout and handle, cups and a cooking cylinder.
	round_prop(Vector3(side * 2.35, 0.95, z), Vector3(0.25, 0.30, 0.25), "metal")
	box(Vector3(side * 2.35, 1.1, z), Vector3(0.15, 0.035, 0.15), "metal")
	box(Vector3(side * 2.22, 0.98, z), Vector3(0.19, 0.05, 0.05), "metal", false, Vector3(0, 0, -side * 0.45))
	for i in range(4):
		round_prop(Vector3(side * 2.4, 0.83, z - 0.35 + i * 0.12), Vector3(0.075, 0.09, 0.075), "brick")
	round_prop(Vector3(side * 2.55, 0.35, z + 0.75), Vector3(0.35, 0.65, 0.35), "red")

func market_tarp(z: float) -> void:
	var s := SurfaceTool.new()
	s.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(24):
		var x0 := -3.1 + i * 6.2 / 24
		var x1 := -3.1 + (i + 1) * 6.2 / 24
		var y0 := 4.85 - sin(float(i) / 24 * PI) * 0.58
		var y1 := 4.85 - sin(float(i + 1) / 24 * PI) * 0.58
		quad(s, Vector3(x0, y0, z - 1.25), Vector3(x1, y1, z - 1.25), Vector3(x1, y1 + 0.11, z + 1.25), Vector3(x0, y0 + 0.11, z + 1.25))
	s.generate_normals()
	var mesh := MeshInstance3D.new()
	mesh.mesh = s.commit()
	var mat: StandardMaterial3D = mats["saffron" if z > 0 else "maroon"].duplicate()
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = mat
	add_child(mesh)
	cable(Vector3(-3.1, 4.85, z - 1.25), Vector3(3.1, 4.85, z - 1.25), 0.58, 0.012)
