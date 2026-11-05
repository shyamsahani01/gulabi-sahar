extends "res://street.gd"
# Gulabi Sahar world: Hawa Mahal Road, an old-city gali, Chandpole gate, Sikar Road,
# Vidhyadhar Nagar and the Nahargarh hills, laid out south to north along -z.
# Zones are compressed picks from the real corridor, not a 1:1 copy of the kilometres.

const ZONES := [
	{"id": "hawa_mahal", "name": "Hawa Mahal Road", "hindi": "हवा महल रोड", "from": 40.0, "to": -40.0},
	{"id": "chandpole", "name": "Chandpole Bazar", "hindi": "चाँदपोल बाज़ार", "from": -40.0, "to": -140.0},
	{"id": "sikar_road", "name": "Sikar Road", "hindi": "सीकर रोड", "from": -140.0, "to": -300.0},
	{"id": "vdn", "name": "Vidhyadhar Nagar", "hindi": "विद्याधर नगर", "from": -300.0, "to": -480.0},
	{"id": "hills", "name": "Nahargarh Hills", "hindi": "नाहरगढ़ की पहाड़ियाँ", "from": -480.0, "to": -780.0},
]
const GALI_ORIGIN := Vector3(-39.0, 0.0, 20.0)
const SOUTH_GATE_Z := 40.0
const WORLD_NORTH_Z := -760.0
const SHOP_NAMES := ["गुलाबी वस्त्र भण्डार", "GULABI GEMS", "जयपुर हस्तशिल्प", "ROOFTOP VIEW CAFE", "शर्मा किराना स्टोर", "सहर पुस्तक भण्डार", "RAJASTHANI JUTTI", "हवा महल ज्वेलर्स", "राजस्थान माटी कला", "GULABI CHAI", "सांगानेरी प्रिन्ट", "चाँदपोल साड़ी सेंटर"]
const MODERN_NAMES := ["SHARMA MOBILE POINT", "JAIPUR MOTORS", "HOTEL PINK PEARL", "ROYAL SWEETS & NAMKEEN", "GULABI BANK", "SIKAR ROAD TYRES", "DR. MEENA CLINIC", "NEW STYLE GARMENTS", "SAHAR ELECTRONICS", "PINK CITY DHABA"]

var rng := RandomNumberGenerator.new()
var noise := FastNoiseLite.new()
var gali: Node3D
var zone_label_nodes: Array[Label3D] = []

func zone_at(z: float) -> Dictionary:
	for zone in ZONES:
		if z <= zone.from and z > zone.to:
			return zone
	return ZONES[0] if z > 0 else ZONES[ZONES.size() - 1]

func make_materials() -> void:
	super.make_materials()
	var extra := {"hm_pink": "c9775f", "hm_red": "a9513c", "white": "e9e2d3", "cream": "e3d4b6", "concrete": "b8b3a8", "grey": "8a8a85", "glass": "6f8fa3", "tarmac": "4a4b4c", "kerb_yellow": "d9b23c", "kerb_black": "2a2a2a", "grass": "5f7f3f", "hedge": "3f6a3a", "hill_rock": "8b7a66", "scrub": "5e6f45", "sand": "c7b48f", "bin_green": "4e8f52", "bin_blue": "3d6fa0", "terracotta": "b56a4e", "maroon": "813f40", "saffron": "c28e4d", "teal": "537c70", "ivory": "cdbc9d", "blue": "526777", "pink": "a46475", "fort": "9c8b73", "black": "1d1d1d", "sky_blue": "5aa0c8", "rust": "7a4a2f", "orange": "d8742a"}
	for key in extra:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(extra[key])
		mat.roughness = 0.92
		mat.metallic_specular = 0.2
		mats[key] = mat
	mats["glass"].roughness = 0.25
	mats["glass"].metallic = 0.3
	mats["glass"].metallic_specular = 0.7
	for key in ["hm_pink", "hm_red", "terracotta"]:
		mats[key].albedo_texture = load("res://assets/textures/weathered_Diffuse.jpg")
		mats[key].normal_enabled = true
		mats[key].normal_texture = load("res://assets/textures/weathered_nor_gl.jpg")
		mats[key].normal_scale = 0.3
		mats[key].uv1_scale = Vector3.ONE * 0.45
		mats[key].uv1_triplanar = true
		mats[key].uv1_world_triplanar = true
	for key in ["white", "cream", "concrete"]:
		mats[key].albedo_texture = load("res://assets/textures/plaster_Diffuse.jpg")
		mats[key].normal_enabled = true
		mats[key].normal_texture = load("res://assets/textures/plaster_nor_gl.jpg")
		mats[key].normal_scale = 0.25
		mats[key].uv1_scale = Vector3.ONE * 0.5
		mats[key].uv1_triplanar = true
		mats[key].uv1_world_triplanar = true
	mats["tarmac"].albedo_texture = load("res://assets/textures/asphalt_Diffuse.jpg")
	mats["tarmac"].uv1_scale = Vector3.ONE * 0.2
	mats["tarmac"].uv1_triplanar = true
	mats["tarmac"].uv1_world_triplanar = true
	mats["tarmac"].albedo_color = Color(0.55, 0.55, 0.54)

func lighting() -> void:
	super.lighting()
	for child in get_children():
		if child is WorldEnvironment:
			var env: Environment = child.environment
			env.fog_enabled = true
			env.fog_light_color = Color("d9cbb4")
			env.fog_density = 0.0006
			env.fog_sky_affect = 0.25
		elif child is DirectionalLight3D:
			child.directional_shadow_max_distance = 60

# ---------------------------------------------------------------- world ----

func build_street() -> void:
	rng.seed = 2611
	noise.seed = 75
	noise.frequency = 0.02
	zone_hawa_mahal()
	zone_chandpole()
	zone_sikar_road()
	zone_vdn()
	zone_hills()
	embed_gali()
	world_boundaries()

func world_boundaries() -> void:
	for side in [-1, 1]:
		var wall := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3(0.5, 40, 300)
		wall.shape = shape
		wall.position = Vector3(side * 236, 20, -630)
		collision_root.add_child(wall)
	var north := CollisionShape3D.new()
	var north_shape := BoxShape3D.new()
	north_shape.size = Vector3(480, 60, 0.5)
	north.shape = north_shape
	north.position = Vector3(0, 30, WORLD_NORTH_Z - 10)
	collision_root.add_child(north)

func zone_sign(z: float, text: String, hindi: String) -> void:
	# Blue-white municipal street sign on a post at the zone entry.
	for x in [-10.4, 10.4]:
		box(Vector3(x, 1.4, z), Vector3(0.07, 2.8, 0.07), "metal")
		box(Vector3(x, 2.95, z), Vector3(1.9, 0.55, 0.06), "blue")
		var label := Label3D.new()
		label.text = hindi + "\n" + text
		label.font = hindi_font
		label.font_size = 30
		label.pixel_size = 0.0055
		label.position = Vector3(x, 2.95, z + 0.04)
		label.modulate = Color("f4efe4")
		label.outline_size = 2
		add_child(label)
		var back: Label3D = label.duplicate()
		back.position = Vector3(x, 2.95, z - 0.04)
		back.rotation.y = PI
		add_child(back)

# ------------------------------------------------- shared street pieces ----

func boulevard(z_from: float, z_to: float, median: bool, road_key := "road") -> void:
	# Two 7 m carriageways, 3 m median, 3.5 m footpaths, building faces at ±12.
	var length := z_from - z_to
	var mid := (z_from + z_to) / 2
	box(Vector3(0, -0.35, mid), Vector3(48, 0.7, length), "stone", true)
	for side in [-1, 1]:
		box(Vector3(side * 5.0, 0.015, mid), Vector3(7, 0.03, length), road_key)
		box(Vector3(side * 11.75, 0.1, mid), Vector3(3.5, 0.2, length), "stone", true)
		for z in range(int(z_to) + 10, int(z_from), 20):
			box(Vector3(side * 9.85, 0.07, z), Vector3(0.6, 0.14, 4.0), "stone", true, Vector3(0, 0, side * 0.3))
		kerb_railing(side * 10.15, z_from, z_to)
	if median:
		box(Vector3(0, 0.015, mid), Vector3(3, 0.03, length), road_key)
		var z := z_from - 6
		while z - 12 > z_to + 4:
			planter(z, 12)
			z -= 20
		z = z_from - 10
		while z > z_to + 6:
			twin_lamp(0, z)
			z -= 20

func kerb_railing(x: float, z_from: float, z_to: float) -> void:
	# Black iron railing with 2 m posts, broken every 20 m for crossings.
	var z := z_from - 1.0
	while z > z_to + 1.0:
		var segment := minf(16.0, z - z_to - 2.0)
		if segment < 4.0:
			break
		var center := z - segment / 2
		for rail_y in [0.55, 0.95, 1.15]:
			box(Vector3(x, rail_y + 0.2, center), Vector3(0.035, 0.035, segment), "metal")
		var p := 0.0
		while p <= segment:
			box(Vector3(x, 0.8, z - p), Vector3(0.06, 1.2, 0.06), "metal", true)
			p += 2.0
		z -= segment + 4.0

func planter(z: float, length: float) -> void:
	box(Vector3(0, 0.5, z), Vector3(2.6, 1.0, length), "hm_red", true)
	box(Vector3(0, 1.03, z), Vector3(2.75, 0.08, length + 0.15), "trim")
	for end in [-1, 1]:
		box(Vector3(0, 0.62, z + end * length / 2), Vector3(3.0, 1.25, 0.5), "hm_red", true)
	for rail_y in [1.25, 1.45]:
		box(Vector3(0, rail_y, z), Vector3(2.7, 0.03, length), "metal")
	var i := 0.0
	while i <= length:
		box(Vector3(-1.33, 1.3, z - length / 2 + i), Vector3(0.04, 0.5, 0.04), "metal")
		box(Vector3(1.33, 1.3, z - length / 2 + i), Vector3(0.04, 0.5, 0.04), "metal")
		i += 1.0
	for shrub in range(int(length / 1.4)):
		var pz := z - length / 2 + 0.8 + shrub * 1.4
		round_prop(Vector3(rng.randf_range(-0.6, 0.6), 1.45, pz), Vector3(1.1, 0.9, 1.2), "hedge" if shrub % 2 else "leaves_light")

func twin_lamp(x: float, z: float) -> void:
	box(Vector3(x, 0.3, z), Vector3(0.5, 0.6, 0.5), "metal", true)
	box(Vector3(x, 3.4, z), Vector3(0.14, 6.2, 0.14), "metal")
	box(Vector3(x, 6.2, z), Vector3(2.2, 0.08, 0.08), "metal")
	for arm in [-1, 1]:
		box(Vector3(x + arm * 1.0, 6.0, z), Vector3(0.06, 0.5, 0.06), "metal")
		round_prop(Vector3(x + arm * 1.0, 5.55, z), Vector3(0.45, 0.6, 0.45), "gold")
		box(Vector3(x + arm * 1.0, 5.85, z), Vector3(0.5, 0.06, 0.5), "metal")
	round_prop(Vector3(x, 6.55, z), Vector3(0.35, 0.5, 0.35), "gold")

func bins(x: float, z: float) -> void:
	for i in range(2):
		var key := "bin_green" if i == 0 else "bin_blue"
		box(Vector3(x, 0.45, z + i * 0.8), Vector3(0.55, 0.9, 0.55), key, true)
		round_prop(Vector3(x, 0.93, z + i * 0.8), Vector3(0.58, 0.3, 0.58), key)
	box(Vector3(x, 0.6, z + 0.4), Vector3(0.05, 1.2, 1.6), "metal")

func big_tree(x: float, z: float, size := 1.0, dark := true) -> void:
	box(Vector3(x, 2.2 * size, z), Vector3(0.45 * size, 4.4 * size, 0.45 * size), "wood", true)
	for branch in range(6):
		var angle := branch * TAU / 6 + x * 0.1
		var center := Vector3(x + cos(angle) * 1.6 * size, 4.8 * size + sin(branch * 1.3) * 0.6 * size, z + sin(angle) * 1.6 * size)
		box(center - Vector3(0, 0.6 * size, 0), Vector3(0.14 * size, 2.4 * size, 0.14 * size), "wood", false, Vector3(sin(angle) * 0.6, 0, cos(angle) * 0.6))
		for leaf in range(20):
			var theta := leaf * 2.399963
			var radius := sqrt(float(leaf) / 20) * 1.9 * size
			var offset := Vector3(cos(theta) * radius, sin(leaf * 1.7) * 0.9 * size, sin(theta) * radius)
			round_prop(center + offset, Vector3(0.9, 0.3, 1.2) * size, ("leaves_light" if leaf % 3 == 0 else "leaves") if dark else ("scrub" if leaf % 2 else "leaves_light"))

func scrub_tree(x: float, y: float, z: float, size: float) -> void:
	box(Vector3(x, y + 0.9 * size, z), Vector3(0.18 * size, 1.8 * size, 0.18 * size), "wood")
	for leaf in range(7):
		var a := leaf * 2.4
		round_prop(Vector3(x + cos(a) * 0.7 * size, y + 1.9 * size + sin(leaf) * 0.3 * size, z + sin(a) * 0.7 * size), Vector3(1.1, 0.5, 1.1) * size, "scrub" if leaf % 2 else "leaves_light")

func striped_awning(side: int, z: float, width: float, y: float, key_a := "red", key_b := "paper") -> void:
	var face := side * 12.0
	var stripes := int(width / 0.4)
	for i in range(stripes):
		box(Vector3(face - side * 0.7, y, z - width / 2 + 0.2 + i * 0.4), Vector3(1.5, 0.05, 0.4), key_a if i % 2 else key_b, false, Vector3(0, 0, side * 0.35))
	for edge in [-1, 1]:
		box(Vector3(face - side * 1.3, y - 1.3, z + edge * (width / 2 - 0.2)), Vector3(0.05, 2.6, 0.05), "metal")

func signboard(side: int, z: float, y: float, width: float, text: String, board := "dark", ink := Color("ead8b3"), size := 38) -> void:
	var face := side * 12.0
	box(Vector3(face - side * 0.1, y, z), Vector3(0.12, 0.6, width), board)
	label3d(Vector3(face - side * 0.18, y, z), text, side, ink, size)

func vehicle_auto(x: float, z: float, rot := 0.0) -> void:
	var basis := Basis.from_euler(Vector3(0, rot, 0))
	var at := func(local: Vector3) -> Vector3: return Vector3(x, 0, z) + basis * local
	box(at.call(Vector3(0, 0.75, 0.1)), Vector3(1.3, 0.9, 2.2), "green", true, Vector3(0, rot, 0))
	box(at.call(Vector3(0, 1.45, 0.1)), Vector3(1.32, 0.5, 2.3), "black", false, Vector3(0, rot, 0))
	box(at.call(Vector3(0, 1.75, 0.1)), Vector3(1.36, 0.1, 2.4), "black", false, Vector3(0, rot, 0))
	box(at.call(Vector3(0, 0.5, -1.0)), Vector3(0.9, 0.5, 0.5), "yellow", false, Vector3(0, rot, 0))
	box(at.call(Vector3(0, 1.1, -0.95)), Vector3(1.2, 0.5, 0.05), "glass", false, Vector3(0, rot, 0))
	for wheel in [Vector3(0, 0.3, -1.1), Vector3(-0.7, 0.3, 0.7), Vector3(0.7, 0.3, 0.7)]:
		round_prop(at.call(wheel), Vector3(0.2, 0.6, 0.6), "black")

func vehicle_car(x: float, z: float, key: String, rot := 0.0) -> void:
	box(Vector3(x, 0.55, z), Vector3(1.7, 0.55, 4.0), key, true, Vector3(0, rot, 0))
	box(Vector3(x, 1.05, z - 0.2), Vector3(1.5, 0.5, 2.1), key, false, Vector3(0, rot, 0))
	box(Vector3(x, 1.05, z - 0.2), Vector3(1.54, 0.3, 2.0), "glass", false, Vector3(0, rot, 0))
	var basis := Basis.from_euler(Vector3(0, rot, 0))
	for wheel in [Vector3(-0.85, 0.3, 1.3), Vector3(0.85, 0.3, 1.3), Vector3(-0.85, 0.3, -1.3), Vector3(0.85, 0.3, -1.3)]:
		round_prop(Vector3(x, 0, z) + basis * wheel, Vector3(0.25, 0.6, 0.6), "black")

func vehicle_scooter(x: float, z: float, key: String, rot := 0.0) -> void:
	box(Vector3(x, 0.55, z), Vector3(0.45, 0.35, 1.5), key, false, Vector3(0, rot, 0))
	box(Vector3(x, 0.8, z + 0.1), Vector3(0.5, 0.12, 0.7), "black", false, Vector3(0, rot, 0))
	box(Vector3(x, 0.95, z - 0.7), Vector3(0.5, 0.05, 0.1), "metal", false, Vector3(0, rot, 0))
	var basis := Basis.from_euler(Vector3(0, rot, 0))
	for wheel in [Vector3(0, 0.25, 0.65), Vector3(0, 0.25, -0.65)]:
		round_prop(Vector3(x, 0, z) + basis * wheel, Vector3(0.12, 0.5, 0.5), "black")

# ------------------------------------------------------ Hawa Mahal road ----

func zone_hawa_mahal() -> void:
	boulevard(40.0, -40.0, true)
	# Closed decorative gateway at the south end, like the earlier street.
	box(Vector3(0, 1, SOUTH_GATE_Z), Vector3(44, 2, 0.6), "plaster", true)
	box(Vector3(0, 7.0, SOUTH_GATE_Z), Vector3(26, 1.4, 1.2), "rose")
	box(Vector3(0, 7.9, SOUTH_GATE_Z), Vector3(26.8, 0.3, 1.5), "trim")
	for x in [-12, 12]:
		box(Vector3(x, 3.6, SOUTH_GATE_Z), Vector3(1.8, 7.2, 1.8), "rose", true)
		box(Vector3(x, 7.6, SOUTH_GATE_Z), Vector3(2.4, 0.35, 2.4), "trim")
		round_prop(Vector3(x, 8.4, SOUTH_GATE_Z), Vector3(1.6, 1.2, 1.6), "trim")
	var gate_label := Label3D.new()
	gate_label.text = "GULABI SAHAR"
	gate_label.position = Vector3(0, 6.9, SOUTH_GATE_Z - 0.7)
	gate_label.rotation.y = PI
	gate_label.font_size = 76
	gate_label.pixel_size = 0.009
	gate_label.modulate = Color("fff0ce")
	add_child(gate_label)
	zone_sign(36.0, "HAWA MAHAL ROAD", "हवा महल रोड")
	hawa_mahal_block()
	for z in [5.0, 35.0]:
		arcade_bay(-1, z, int(z / 10), {})
	for i in range(8):
		arcade_bay(1, -35.0 + i * 10.0, i, {"cafe": i == 3, "tall": i == 5})
	bins(-10.9, 2.0)
	bins(10.9, -30.0)
	big_tree(-11.6, 32.0, 1.4)
	big_tree(11.6, 14.0, 1.5)
	big_tree(11.6, -22.0, 1.3)
	vehicle_auto(-6.0, 12.0)
	vehicle_auto(6.4, -8.0, PI)
	vehicle_scooter(8.2, 22.0, "red", 0.2)
	vehicle_scooter(8.2, 23.4, "blue", 0.1)
	vehicle_car(-7.8, -26.0, "white")

func hawa_mahal_block() -> void:
	# 40 m, five tiers, 15 bays of projecting jharokhas; shops under the north half.
	var face := -12.0
	var z0 := -40.0
	# South half is solid; the north half opens at street level for the shops under the facade.
	box(Vector3(-16.0, 7.0, -30.0), Vector3(8.0, 14.0, 20.0), "hm_pink", true)
	box(Vector3(-16.0, 8.5, -10.0), Vector3(8.0, 11.0, 20.0), "hm_pink", true)
	box(Vector3(-19.9, 1.5, -10.0), Vector3(0.2, 3.0, 20.0), "dark", true)
	box(Vector3(-16.0, 0.15, -10.0), Vector3(8.0, 0.3, 20.0), "stone", true)
	for dz in [-20.25, -15.75, -11.25, -6.75, -2.25, -0.1]:
		box(Vector3(-16.0, 1.5, dz), Vector3(8.0, 3.0, 0.25), "hm_pink", true)
	for y in [2.8, 5.6, 8.4, 11.2]:
		box(Vector3(face, y, -20.0), Vector3(0.5, 0.18, 40.4), "trim")
		box(Vector3(face + 0.1, y + 0.2, -20.0), Vector3(0.2, 0.08, 40.4), "trim")
	box(Vector3(face, 14.05, -20.0), Vector3(0.6, 0.3, 40.6), "trim")
	for merlon in range(40):
		box(Vector3(face + 0.1, 14.5, z0 + 0.5 + merlon * 1.0), Vector3(0.3, 0.6, 0.5), "hm_pink")
	for bay in range(15):
		var z := z0 + 1.33 + bay * 2.667
		for tier in range(4):
			var base := 2.8 + tier * 2.8
			jharokha(face, base, z, tier == 3)
	for x_c in [-39.0, -20.0, -1.0]:
		chhatri(face - 1.2, 14.3, x_c, 1.3)
	for z in [-37.0, -33.0, -29.0, -25.0]:
		box(Vector3(face + 0.05, 1.3, z), Vector3(0.15, 2.4, 1.6), "dark")
		arch(face + 0.1, 2.5, z, 0.85)
		for bar in range(5):
			box(Vector3(face + 0.1, 1.3, z - 0.6 + bar * 0.3), Vector3(0.06, 2.3, 0.05), "trim")
	for i in range(4):
		var z := -18.0 + i * 4.5
		shop_stock(-1, z, 13.2)
		striped_awning(-1, z, 3.8, 2.9, "red" if i % 2 else "maroon", "paper")
		signboard(-1, z, 3.2, 3.2, SHOP_NAMES[(i + 7) % SHOP_NAMES.size()], "dark", Color("ead8b3"), 30)
	var hm_label := Label3D.new()
	hm_label.text = "हवा महल"
	hm_label.font = hindi_font
	hm_label.font_size = 72
	hm_label.pixel_size = 0.012
	hm_label.position = Vector3(face + 0.35, 1.2, -30.0)
	hm_label.rotation.y = PI / 2
	hm_label.modulate = Color("f7e6c6")
	hm_label.outline_size = 6
	add_child(hm_label)

func jharokha(face: float, base: float, z: float, domed: bool) -> void:
	# Projecting bay: body, dark reveal with jaali bars, trim frame, chhajja and dome.
	box(Vector3(face + 0.3, base + 1.0, z), Vector3(0.6, 2.0, 1.3), "hm_pink")
	box(Vector3(face + 0.62, base + 1.05, z), Vector3(0.08, 1.4, 0.8), "dark")
	for bar in range(3):
		box(Vector3(face + 0.64, base + 1.05, z - 0.25 + bar * 0.25), Vector3(0.04, 1.3, 0.04), "trim")
	box(Vector3(face + 0.64, base + 1.05, z), Vector3(0.04, 0.04, 0.8), "trim")
	for edge in [-1, 1]:
		box(Vector3(face + 0.62, base + 1.0, z + edge * 0.6), Vector3(0.1, 2.0, 0.12), "trim")
	box(Vector3(face + 0.45, base + 2.05, z), Vector3(1.0, 0.1, 1.5), "trim")
	box(Vector3(face + 0.45, base + 0.05, z), Vector3(1.0, 0.1, 1.5), "trim")
	arch(face + 0.66, base + 1.55, z, 0.42)
	if domed:
		round_prop(Vector3(face + 0.35, base + 2.45, z), Vector3(1.0, 0.8, 1.0), "trim")
		round_prop(Vector3(face + 0.35, base + 2.9, z), Vector3(0.16, 0.3, 0.16), "gold")

func chhatri(x: float, y: float, z: float, size: float) -> void:
	for dx in [-1, 1]:
		for dz in [-1, 1]:
			box(Vector3(x + dx * size * 0.45, y + size * 0.9, z + dz * size * 0.45), Vector3(0.12, size * 1.8, 0.12), "trim")
	box(Vector3(x, y + size * 1.85, z), Vector3(size * 1.3, 0.12, size * 1.3), "trim")
	round_prop(Vector3(x, y + size * 2.2, z), Vector3(size * 1.3, size * 0.9, size * 1.3), "trim")
	round_prop(Vector3(x, y + size * 2.7, z), Vector3(0.14, 0.3, 0.14), "gold")

func shop_stock(side: int, z: float, counter_x: float) -> void:
	box(Vector3(side * counter_x, 0.5, z), Vector3(0.7, 0.9, 2.6), "wood", true)
	box(Vector3(side * counter_x, 0.98, z), Vector3(0.85, 0.08, 2.7), "stone")
	for stack in range(5):
		for layer in range(3):
			box(Vector3(side * (counter_x - 0.02), 1.06 + layer * 0.06, z - 1.0 + stack * 0.5), Vector3(0.55, 0.05, 0.4), ["ivory", "maroon", "teal", "saffron", "pink"][(stack + layer) % 5])
	for shelf in range(3):
		box(Vector3(side * (counter_x + 1.2), 0.7 + shelf * 0.55, z), Vector3(0.6, 0.05, 2.6), "wood")
		for item in range(8):
			box(Vector3(side * (counter_x + 1.15), 0.86 + shelf * 0.55, z - 1.1 + item * 0.3), Vector3(0.3, 0.25, 0.22), ["red", "yellow", "green", "paper", "blue"][(item + shelf) % 5])

func arcade_bay(side: int, z: float, index: int, opts: Dictionary) -> void:
	# Two-storey pink arcade bay: shop below, cusped-arch gallery above.
	var tall: bool = opts.get("tall", false)
	var cafe: bool = opts.get("cafe", false)
	var height := 11.4 if tall else 8.0
	var wall: String = ["plaster", "rose", "ochre", "terracotta"][index % 4]
	var face := side * 12.0
	box(Vector3(side * 16.0, (height + 3.0) / 2, z), Vector3(8.0, height - 3.0, 9.7), wall, true)
	box(Vector3(side * 19.9, 1.5, z), Vector3(0.2, 3.0, 9.7), wall, true)
	box(Vector3(side * 16.0, 0.15, z), Vector3(8.0, 0.3, 9.7), "stone", true)
	for edge in [-1, 1]:
		box(Vector3(side * 16.0, 1.5, z + edge * 4.75), Vector3(8.0, 3.0, 0.2), wall, true)
	for y in [3.4, 6.2, height]:
		box(Vector3(face, y, z), Vector3(0.3, 0.2, 9.9), "trim")
	for merlon in range(9):
		box(Vector3(face - side * 0.1, height + 0.4, z - 4.4 + merlon * 1.1), Vector3(0.3, 0.5, 0.55), wall)
	for dz in [-3.0, 0.0, 3.0]:
		box(Vector3(face - side * 0.05, 4.9, z + dz), Vector3(0.15, 2.4, 1.5), "dark")
		arch(face - side * 0.1, 5.4, z + dz, 0.8)
		for edge in [-1, 1]:
			box(Vector3(face - side * 0.15, 4.9, z + dz + edge * 0.85), Vector3(0.2, 2.4, 0.15), "trim")
		for bar in range(6):
			box(Vector3(face - side * 0.2, 4.2, z + dz - 0.6 + bar * 0.24), Vector3(0.05, 0.7, 0.04), "wood")
		box(Vector3(face - side * 0.2, 4.55, z + dz), Vector3(0.05, 0.05, 1.5), "wood")
		if tall:
			box(Vector3(face - side * 0.05, 8.3, z + dz), Vector3(0.15, 2.0, 1.3), "dark")
			arch(face - side * 0.1, 8.8, z + dz, 0.7)
	if tall:
		for cz in [z - 3.2, z + 3.2]:
			chhatri(face - side * 1.5, height + 0.2, cz, 1.0)
	if cafe:
		for rail in range(2):
			box(Vector3(face - side * 0.6, height + 0.5 + rail * 0.4, z), Vector3(0.04, 0.04, 8.0), "metal")
		for post in range(9):
			box(Vector3(face - side * 0.6, height + 0.5, z - 4.0 + post * 1.0), Vector3(0.05, 1.0, 0.05), "metal")
		for uz in [z - 2.0, z + 2.0]:
			box(Vector3(face - side * 2.5, height + 1.1, uz), Vector3(0.06, 2.2, 0.06), "metal")
			round_prop(Vector3(face - side * 2.5, height + 2.2, uz), Vector3(2.4, 0.5, 2.4), "sky_blue")
			box(Vector3(face - side * 2.5, height + 0.4, uz), Vector3(1.0, 0.08, 1.0), "white")
		signboard(side, z, height - 0.9, 5.0, "ROOFTOP VIEW CAFE", "white", Color("3a2412"), 30)
	# Ground floor shop: open front, counter and stock inside, awning and signboard.
	box(Vector3(side * 19.85, 1.5, z), Vector3(0.3, 3.0, 9.7), "dark", true)
	box(Vector3(side * 16.0, 2.95, z), Vector3(8.0, 0.1, 9.7), "dark")
	shop_stock(side, z, 13.2)
	striped_awning(side, z, 7.4, 2.95, ["red", "green", "maroon", "blue"][index % 4], "paper")
	signboard(side, z, 3.75, 7.0, SHOP_NAMES[index % SHOP_NAMES.size()], "dark" if index % 2 else "white", Color("ead8b3") if index % 2 else Color("3a2412"), 36)
	for edge in [-1, 1]:
		box(Vector3(face - side * 0.1, 1.4, z + edge * 3.6), Vector3(0.3, 2.8, 0.3), "trim")
	# Facade wear: pipe, meter, posters.
	box(Vector3(face - side * 0.2, height / 2, z - 4.6), Vector3(0.1, height, 0.1), "metal")
	box(Vector3(face - side * 0.18, 1.7, z + 4.4), Vector3(0.03, 0.8, 0.5), "poster")
	box(Vector3(face - side * 0.2, 1.75, z + 4.4), Vector3(0.02, 0.15, 0.42), "red")
	if index % 3 == 0:
		box(Vector3(face - side * 0.4, 7.2, z - 1.5), Vector3(0.7, 0.55, 0.85), "grey")
	round_prop(Vector3(side * 17.5, height + 0.9, z + 2.0), Vector3(1.4, 1.5, 1.4), "black")

# ----------------------------------------------------------- Chandpole ----

func zone_chandpole() -> void:
	boulevard(-40.0, -100.0, true)
	boulevard(-100.0, -140.0, false)
	zone_sign(-44.0, "CHANDPOLE BAZAR", "चाँदपोल बाज़ार")
	for i in range(6):
		arcade_bay(-1, -45.0 - i * 10.0, i + 2, {"tall": i == 2})
		arcade_bay(1, -45.0 - i * 10.0, i + 5, {"cafe": i == 4})
	big_tree(-11.6, -62.0, 1.3)
	big_tree(11.6, -88.0, 1.4)
	bins(10.9, -70.0)
	vehicle_auto(-6.0, -58.0, 0.1)
	vehicle_auto(-6.2, -62.0, 0.0)
	vehicle_car(7.6, -80.0, "grey", PI)
	city_gate(-118.0)
	# Beyond the gate the old city ends: a short modern strip leads to Sikar Road.
	for side in [-1, 1]:
		box(Vector3(side * 16.0, 2.5, -132.0), Vector3(8.0, 5.0, 14.0), "concrete", true)
		box(Vector3(side * 12.05, 1.5, -132.0), Vector3(0.1, 3.0, 12.0), "glass")
		signboard(side, -132.0, 3.6, 8.0, MODERN_NAMES[(1 if side < 0 else 4)], "white", Color("3a2412"), 30)

func city_gate(z: float) -> void:
	# Chandpole: pink city wall with a central road arch, two footpath arches and bastions.
	var wall := "hm_pink"
	for side in [-1, 1]:
		box(Vector3(side * 17.0, 4.5, z), Vector3(8.0, 9.0, 4.0), wall, true)
		box(Vector3(side * 9.5, 4.5, z), Vector3(1.6, 9.0, 4.0), wall, true)
		box(Vector3(side * 11.75, 7.4, z), Vector3(3.0, 3.2, 4.0), wall, true)
		arch(side * 11.75, 5.8, z - 2.05, 1.5, PI / 2)
		arch(side * 11.75, 5.8, z + 2.05, 1.5, PI / 2)
		box(Vector3(side * 24.0, 6.0, z), Vector3(6.0, 12.0, 6.0), wall, true)
		for merlon in range(5):
			box(Vector3(side * 24.0 - 2.5 + merlon * 1.25, 12.4, z - 2.6), Vector3(0.6, 0.8, 0.5), wall)
			box(Vector3(side * 24.0 - 2.5 + merlon * 1.25, 12.4, z + 2.6), Vector3(0.6, 0.8, 0.5), wall)
		chhatri(side * 24.0, 12.0, z, 1.4)
		for y in [3.0, 6.0]:
			box(Vector3(side * 17.0, y, z - 2.05), Vector3(8.2, 0.15, 0.2), "trim")
			box(Vector3(side * 17.0, y, z + 2.05), Vector3(8.2, 0.15, 0.2), "trim")
		for window in range(3):
			box(Vector3(side * (14.5 + window * 2.4), 7.2, z - 2.05), Vector3(0.9, 1.4, 0.12), "dark")
			arch(side * (14.5 + window * 2.4), 7.6, z - 2.08, 0.45, PI / 2)
	box(Vector3(0, 10.5, z), Vector3(17.5, 3.0, 4.0), wall, true)
	box(Vector3(0, 12.3, z), Vector3(17.5, 0.3, 4.4), "trim")
	for merlon in range(14):
		box(Vector3(-8.0 + merlon * 1.23, 12.9, z - 2.0), Vector3(0.6, 0.9, 0.5), wall)
		box(Vector3(-8.0 + merlon * 1.23, 12.9, z + 2.0), Vector3(0.6, 0.9, 0.5), wall)
	arch(0, 9.0, z - 2.05, 4.5, PI / 2)
	arch(0, 9.0, z + 2.05, 4.5, PI / 2)
	for x in [-4.0, 0.0, 4.0]:
		chhatri(x, 12.3, z, 1.1)
	var label := Label3D.new()
	label.text = "चाँदपोल"
	label.font = hindi_font
	label.font_size = 80
	label.pixel_size = 0.012
	label.position = Vector3(0, 11.0, z + 2.15)
	label.modulate = Color("f7e6c6")
	label.outline_size = 6
	add_child(label)
	var back: Label3D = label.duplicate()
	back.position = Vector3(0, 11.0, z - 2.15)
	back.rotation.y = PI
	add_child(back)

# ---------------------------------------------------------- Sikar Road ----

func zone_sikar_road() -> void:
	var z_from := -140.0
	var z_to := -300.0
	var mid := (z_from + z_to) / 2
	var length := z_from - z_to
	box(Vector3(0, -0.35, mid), Vector3(60, 0.7, length), "stone", true)
	box(Vector3(0, 0.015, mid), Vector3(22, 0.03, length), "tarmac")
	box(Vector3(0, 0.2, mid), Vector3(1.4, 0.4, length), "concrete", true)
	var z := z_from - 2.0
	while z > z_to:
		box(Vector3(0, 0.41, z), Vector3(1.4, 0.03, 1.0), "kerb_yellow" if int(z) % 2 == 0 else "kerb_black")
		z -= 1.0
	for side in [-1, 1]:
		box(Vector3(side * 12.5, 0.1, mid), Vector3(3.0, 0.2, length), "concrete", true)
		for rz in range(int(z_to) + 10, int(z_from), 30):
			box(Vector3(side * 10.8, 0.07, rz), Vector3(0.6, 0.14, 4.0), "concrete", true, Vector3(0, 0, side * 0.3))
		var pole_z := z_from - 8.0
		while pole_z > z_to + 4:
			box(Vector3(side * 13.6, 4.5, pole_z), Vector3(0.18, 9.0, 0.18), "concrete")
			box(Vector3(side * 13.6, 8.6, pole_z), Vector3(1.6, 0.08, 0.08), "metal")
			pole_z -= 24.0
	zone_sign(-144.0, "SIKAR ROAD", "सीकर रोड")
	var lamp_z := z_from - 14.0
	while lamp_z > z_to + 6:
		box(Vector3(0, 4.5, lamp_z), Vector3(0.16, 9.0, 0.16), "metal")
		for arm in [-1, 1]:
			box(Vector3(arm * 1.1, 8.8, lamp_z), Vector3(2.2, 0.08, 0.08), "metal", false, Vector3(0, 0, arm * 0.25))
			box(Vector3(arm * 2.1, 8.5, lamp_z), Vector3(0.6, 0.12, 0.3), "white")
		lamp_z -= 28.0
	for i in range(8):
		var bz := z_from - 10.0 - i * 20.0
		if i == 4:
			petrol_pump(1, bz)
		else:
			modern_block(1, bz, i)
		if i == 2:
			bus_stop(-1, bz)
			modern_block(-1, bz, i + 3)
		else:
			modern_block(-1, bz, i + 3)
	big_tree(-12.6, -170.0, 1.5, false)
	big_tree(12.6, -250.0, 1.4, false)
	big_tree(-12.6, -282.0, 1.3, false)
	vehicle_car(-8.0, -160.0, "white")
	vehicle_car(-8.0, -166.0, "grey")
	vehicle_car(8.0, -236.0, "red", PI)
	vehicle_auto(8.0, -190.0, PI)
	vehicle_auto(8.0, -194.0, PI + 0.1)
	for i in range(4):
		vehicle_scooter(-9.6, -210.0 - i * 1.3, ["red", "blue", "black", "white"][i], 0.3)

func modern_block(side: int, z: float, index: int) -> void:
	var height: float = [10.0, 13.0, 11.5, 14.5, 9.5][index % 5]
	var wall: String = ["concrete", "cream", "white", "grey", "cream"][index % 5]
	var face := side * 14.0
	box(Vector3(side * 20.0, (height + 3.6) / 2, z), Vector3(12.0, height - 3.6, 18.0), wall, true)
	box(Vector3(side * 25.9, 1.8, z), Vector3(0.2, 3.6, 18.0), wall, true)
	box(Vector3(side * 20.0, 0.2, z), Vector3(12.0, 0.4, 18.0), "concrete", true)
	for edge in [-1, 1]:
		box(Vector3(side * 20.0, 1.8, z + edge * 8.9), Vector3(12.0, 3.6, 0.2), wall, true)
	var floors := int((height - 3.6) / 3.2)
	for f in range(floors):
		var y := 3.6 + f * 3.2
		box(Vector3(face, y, z), Vector3(0.5, 0.25, 18.2), "concrete")
		for w in range(5):
			var wz := z - 7.0 + w * 3.5
			box(Vector3(face - side * 0.05, y + 1.7, wz), Vector3(0.15, 1.6, 2.2), "glass")
			box(Vector3(face - side * 0.1, y + 0.85, wz), Vector3(0.2, 0.08, 2.4), "white")
			if (w + f + index) % 3 == 0:
				box(Vector3(face - side * 0.35, y + 1.2, wz + 0.5), Vector3(0.6, 0.5, 0.7), "grey")
			if (w + index) % 2 == 0:
				box(Vector3(face - side * 0.7, y + 0.5, wz), Vector3(1.4, 0.12, 2.6), "concrete")
				for bar in range(7):
					box(Vector3(face - side * 1.35, y + 1.0, wz - 1.2 + bar * 0.4), Vector3(0.04, 0.9, 0.04), "metal")
				box(Vector3(face - side * 1.35, y + 1.45, wz), Vector3(0.04, 0.04, 2.6), "metal")
	box(Vector3(face, height + 0.1, z), Vector3(0.5, 0.3, 18.2), "concrete")
	for shop in range(3):
		var sz := z - 6.0 + shop * 6.0
		box(Vector3(face - side * 0.02, 1.7, sz), Vector3(0.2, 3.2, 5.2), "glass")
		box(Vector3(face - side * 0.05, 0.6, sz), Vector3(0.3, 1.2, 5.2), "dark")
		var name_index := (index * 3 + shop) % MODERN_NAMES.size()
		box(Vector3(face - side * 0.15, 3.85, sz), Vector3(0.15, 0.9, 5.6), ["red", "white", "blue", "yellow", "dark"][name_index % 5])
		label3d(Vector3(face - side * 0.25, 3.85, sz), MODERN_NAMES[name_index], side, Color("f4efe4") if name_index % 5 in [0, 2, 4] else Color("2a1407"), 26)
		for edge in [-1, 1]:
			box(Vector3(face - side * 0.1, 1.7, sz + edge * 2.8), Vector3(0.3, 3.4, 0.4), "concrete")
	round_prop(Vector3(side * 22.0, height + 1.0, z + 5.0), Vector3(1.6, 1.8, 1.6), "black")
	box(Vector3(side * 18.0, height + 1.2, z - 4.0), Vector3(2.4, 2.4, 2.6), wall)
	if index % 2 == 0:
		box(Vector3(side * 17.0, height + 3.5, z), Vector3(0.3, 2.6, 8.0), "white")
		box(Vector3(side * 17.0, height + 3.5, z), Vector3(0.1, 2.0, 7.4), ["red", "blue", "saffron"][index % 3])
		for leg in [-3.0, 3.0]:
			box(Vector3(side * 17.0, height + 1.0, z + leg), Vector3(0.1, 2.4, 0.1), "metal")

func petrol_pump(side: int, z: float) -> void:
	var x := side * 20.0
	box(Vector3(x, 0.08, z), Vector3(12.0, 0.16, 18.0), "concrete", true)
	for cx in [-4.0, 4.0]:
		for cz in [-6.0, 6.0]:
			box(Vector3(x + cx, 2.6, z + cz), Vector3(0.5, 5.2, 0.5), "white", true)
	box(Vector3(x, 5.4, z), Vector3(13.0, 0.5, 19.0), "white")
	box(Vector3(x, 5.4, z), Vector3(13.1, 0.3, 19.1), "orange")
	for dz in [-3.0, 3.0]:
		box(Vector3(x, 0.9, z + dz), Vector3(1.0, 1.8, 0.7), "white", true)
		box(Vector3(x, 1.4, z + dz), Vector3(1.05, 0.5, 0.72), "orange")
		box(Vector3(x, 0.9, z + dz), Vector3(0.5, 0.4, 0.75), "dark")
	box(Vector3(side * 14.2, 4.0, z + 8.0), Vector3(0.3, 8.0, 0.3), "white")
	box(Vector3(side * 14.2, 7.2, z + 8.0), Vector3(1.6, 2.6, 0.2), "orange")
	label3d(Vector3(side * 14.3, 7.2, z + 8.0), "PETROL", side, Color("f4efe4"), 30)
	box(Vector3(x + side * 4.0, 1.8, z), Vector3(3.5, 3.6, 7.0), "white", true)
	box(Vector3(x + side * 2.2, 1.6, z), Vector3(0.1, 2.0, 5.0), "glass")
	vehicle_car(x - side * 2.5, z + 3.0, "white", PI / 2)
	vehicle_scooter(x - side * 2.5, z - 3.0, "black", PI / 2)

func bus_stop(side: int, z: float) -> void:
	var x := side * 12.3
	for pz in [-2.5, 2.5]:
		box(Vector3(x, 1.4, z + pz), Vector3(0.1, 2.8, 0.1), "metal")
		box(Vector3(x + side * 1.2, 1.4, z + pz), Vector3(0.1, 2.8, 0.1), "metal")
	box(Vector3(x + side * 0.6, 2.85, z), Vector3(1.8, 0.1, 6.0), "red")
	box(Vector3(x + side * 1.2, 1.5, z), Vector3(0.08, 2.0, 5.6), "glass")
	box(Vector3(x + side * 0.7, 0.5, z), Vector3(0.6, 0.08, 4.5), "wood")
	box(Vector3(x + side * 0.6, 2.4, z), Vector3(0.06, 0.6, 3.0), "white")
	label3d(Vector3(x + side * 0.55, 2.4, z), "BUS STOP • बस स्टॉप", -side, Color("2a1407"), 24)

# ---------------------------------------------------- Vidhyadhar Nagar ----

func zone_vdn() -> void:
	var z_from := -300.0
	var z_to := -480.0
	var mid := (z_from + z_to) / 2
	var length := z_from - z_to
	box(Vector3(0, -0.35, mid), Vector3(90, 0.7, length), "stone", true)
	for side in [-1, 1]:
		box(Vector3(side * 5.5, 0.015, mid), Vector3(7, 0.03, length), "tarmac")
		box(Vector3(side * 10.25, 0.1, mid), Vector3(2.5, 0.2, length), "concrete", true)
		for rz in range(int(z_to) + 8, int(z_from), 36):
			box(Vector3(side * 8.8, 0.07, rz), Vector3(0.6, 0.14, 4.0), "concrete", true, Vector3(0, 0, side * 0.3))
	box(Vector3(0, 0.15, mid), Vector3(4.0, 0.3, length), "concrete", true)
	box(Vector3(0, 0.32, mid), Vector3(3.6, 0.06, length), "grass")
	var z := z_from - 8.0
	while z > z_to + 6:
		box(Vector3(0, 0.6, z), Vector3(3.2, 0.5, 10.0), "hedge")
		big_tree(0, z - 8.0, 0.9)
		z -= 18.0
	z = z_from - 12.0
	while z > z_to + 6:
		twin_lamp(0, z)
		z -= 36.0
	zone_sign(-304.0, "VIDHYADHAR NAGAR", "विद्याधर नगर")
	corner_shops(-1, -306.0)
	corner_shops(1, -306.0)
	# Plots of 12 m, side lanes every 36 m. The park replaces plots on the east.
	for side in [-1, 1]:
		var pz := -318.0
		var index := 0
		while pz > z_to + 6:
			if side > 0 and pz < -376.0 and pz > -446.0:
				pz -= 12.0
				index += 1
				continue
			if int(index) % 3 == 2:
				side_lane(side, pz)
				pz -= 6.0
				index += 1
				continue
			house(side, pz, index)
			pz -= 12.0
			index += 1
	park(1, -411.0)
	temple(-1, -452.0)
	big_tree(-11.5, -340.0, 1.3)
	big_tree(11.5, -330.0, 1.2)
	big_tree(-11.5, -400.0, 1.4)
	vehicle_car(-8.6, -352.0, "white")
	vehicle_car(8.6, -364.0, "grey", PI)
	vehicle_scooter(-9.4, -420.0, "red", 0.2)
	vehicle_auto(8.4, -460.0, PI)

func corner_shops(side: int, z: float) -> void:
	var face := side * 11.5
	box(Vector3(side * 16.0, 3.5, z), Vector3(9.0, 1.0, 10.0), "cream", true)
	box(Vector3(side * 20.4, 1.5, z), Vector3(0.2, 3.0, 10.0), "dark", true)
	box(Vector3(side * 16.0, 0.15, z), Vector3(9.0, 0.3, 10.0), "stone", true)
	for edge in [-1, 1]:
		box(Vector3(side * 16.0, 1.5, z + edge * 4.9), Vector3(9.0, 3.0, 0.2), "cream", true)
	box(Vector3(side * 16.0, 1.5, z), Vector3(9.0, 3.0, 0.2), "cream", true)
	box(Vector3(face, 4.1, z), Vector3(0.4, 0.2, 10.2), "concrete")
	for dz in [-2.5, 2.5]:
		shop_stock(side, z + dz, 12.7)
	striped_awning(side, z, 9.0, 2.9, "blue", "paper")
	box(Vector3(face - side * 0.1, 3.4, z), Vector3(0.12, 0.6, 9.0), "white")
	label3d(Vector3(face - side * 0.18, 3.4, z), "शर्मा किराना • AMUL MILK BOOTH" if side < 0 else "VDN MEDICAL & GENERAL STORE", side, Color("2a1407"), 26)
	round_prop(Vector3(side * 16.0, 4.9, z + 3.0), Vector3(1.3, 1.4, 1.3), "black")

func side_lane(side: int, z: float) -> void:
	box(Vector3(side * 26.0, 0.015, z), Vector3(30, 0.03, 6.0), "tarmac")
	box(Vector3(side * 40.0, 1.0, z), Vector3(0.3, 2.0, 6.0), "cream", true)
	box(Vector3(side * 13.0, 1.2, z + 2.4), Vector3(0.1, 2.4, 0.1), "concrete")
	box(Vector3(side * 13.0, 2.3, z + 2.4), Vector3(0.9, 0.4, 0.06), "blue")

func house(side: int, z: float, index: int) -> void:
	# Residential plot: boundary wall, iron gate, setback house with balconies and roof clutter.
	var style := index % 3
	var wall: String = ["white", "cream", "terracotta"][style]
	var trim_key: String = ["grey", "white", "white"][style]
	var face := side * 11.5
	var floors: int = 2 + (index % 2)
	var height := floors * 3.3
	box(Vector3(face + side * 0.2, 0.8, z), Vector3(0.3, 1.6, 12.0), wall, true)
	box(Vector3(face + side * 0.2, 1.65, z), Vector3(0.4, 0.12, 12.1), trim_key)
	for edge in [-1, 1]:
		box(Vector3(side * 17.5, 0.8, z + edge * 6.0), Vector3(12.0, 1.6, 0.25), wall, true)
	box(Vector3(side * 23.4, 0.8, z), Vector3(0.25, 1.6, 12.0), wall, true)
	for gx in [-1.6, 1.6]:
		box(Vector3(face + side * 0.2, 1.1, z + 3.0 + gx), Vector3(0.4, 2.2, 0.4), trim_key, true)
	for bar in range(8):
		box(Vector3(face + side * 0.2, 0.9, z + 1.65 + bar * 0.37), Vector3(0.05, 1.7, 0.05), "black")
	box(Vector3(face + side * 0.2, 1.7, z + 3.0), Vector3(0.05, 0.08, 2.6), "black")
	box(Vector3(face + side * 0.2, 1.25, z - 4.5), Vector3(0.4, 0.3, 0.8), "white")
	label3d(Vector3(face + side * 0.0, 1.25, z - 4.5), ["SHARMA NIWAS", "मीना सदन", "RAJ VILLA", "सैनी हाउस", "GUPTA BHAWAN"][index % 5], side, Color("2a1407"), 18)
	var hx := side * 18.5
	box(Vector3(hx, height / 2, z), Vector3(9.0, height, 10.0), wall, true)
	for f in range(floors):
		var y := f * 3.3
		box(Vector3(side * 14.0, y + 3.3, z), Vector3(0.6, 0.22, 10.2), trim_key)
		for w in range(2):
			var wz := z - 2.5 + w * 5.0
			box(Vector3(side * 13.97, y + 1.9, wz), Vector3(0.1, 1.5, 1.6), "glass")
			box(Vector3(side * 13.9, y + 1.9, wz), Vector3(0.15, 1.6, 1.7), "dark")
			box(Vector3(side * 13.9, y + 1.9, wz), Vector3(0.12, 1.5, 1.6), "glass")
			if style == 1:
				arch(side * 13.85, y + 2.5, wz, 0.85)
		if f > 0:
			var bz := z + 2.0
			box(Vector3(side * 13.2, y + 0.1, bz), Vector3(2.0, 0.2, 4.5), "concrete")
			for bar in range(10):
				box(Vector3(side * 12.25, y + 0.65, bz - 2.1 + bar * 0.45), Vector3(0.04, 1.0, 0.04), "metal" if style != 0 else "white")
			box(Vector3(side * 12.25, y + 1.15, bz), Vector3(0.05, 0.05, 4.5), "metal" if style != 0 else "white")
			if style == 0:
				box(Vector3(side * 12.3, y + 0.65, bz), Vector3(0.03, 0.9, 4.3), "glass")
			box(Vector3(side * 13.9, y + 1.9, bz), Vector3(0.15, 2.2, 1.0), "dark")
	if style == 0:
		box(Vector3(side * 13.95, height / 2, z - 4.0), Vector3(0.2, height, 1.4), "grey")
	box(Vector3(side * 14.0, height + 0.3, z), Vector3(0.5, 0.6, 10.2), trim_key)
	box(Vector3(hx, height + 0.3, z), Vector3(9.2, 0.6, 0.25), trim_key)
	round_prop(Vector3(side * 20.0, height + 1.0, z - 3.0), Vector3(1.4, 1.6, 1.4), "black")
	box(Vector3(side * 20.5, height + 1.2, z + 2.5), Vector3(2.6, 2.4, 2.4), wall)
	if index % 2 == 0:
		box(Vector3(side * 16.5, height + 1.4, z), Vector3(3.0, 0.08, 2.0), "blue", false, Vector3(0, 0, side * 0.45))
	else:
		round_prop(Vector3(side * 16.0, height + 1.2, z + 3.5), Vector3(0.9, 0.1, 0.9), "white")
	# Front yard: car or scooter, a plant and a tree.
	if index % 2 == 0:
		vehicle_car(side * 12.8, z + 3.0, ["white", "grey", "red", "blue"][index % 4])
	else:
		vehicle_scooter(side * 12.4, z + 3.4, "black", PI / 2)
	round_prop(Vector3(face + side * 1.0, 0.35, z - 2.0), Vector3(0.5, 0.6, 0.5), "terracotta")
	for leaf in range(5):
		round_prop(Vector3(face + side * 1.0 + cos(leaf * 1.3) * 0.25, 0.8 + leaf * 0.08, z - 2.0 + sin(leaf * 1.3) * 0.25), Vector3(0.45, 0.12, 0.3), "leaves")
	if index % 3 == 1:
		big_tree(face + side * 1.4, z - 4.0, 0.75)

func park(side: int, z: float) -> void:
	# Sector park: railing, two gates, walking track, lawn, trees, benches, swings, gazebo.
	var x := side * 26.0
	box(Vector3(x, 0.12, z), Vector3(30.0, 0.24, 66.0), "grass", true)
	box(Vector3(x, 0.26, z), Vector3(22.0, 0.04, 56.0), "sand")
	box(Vector3(x, 0.28, z), Vector3(17.0, 0.04, 50.0), "grass")
	for edge in [-1, 1]:
		for rail_y in [0.6, 1.1]:
			box(Vector3(x, rail_y + 0.24, z + edge * 33.0), Vector3(30.0, 0.04, 0.04), "metal")
			box(Vector3(x + edge * 15.0, rail_y + 0.24, z), Vector3(0.04, 0.04, 66.0), "metal")
		var post := 0.0
		while post <= 30.0:
			box(Vector3(x - 15.0 + post, 0.84, z + edge * 33.0), Vector3(0.06, 1.2, 0.06), "metal", true)
			post += 2.0
		post = 0.0
		while post <= 66.0:
			if absf(post - 33.0) > 2.0 or edge > 0:
				box(Vector3(x + edge * 15.0, 0.84, z - 33.0 + post), Vector3(0.06, 1.2, 0.06), "metal", true)
			post += 2.0
	box(Vector3(side * 11.0, 0.3, z), Vector3(0.1, 0.12, 3.6), "metal")
	label3d(Vector3(side * 11.3, 2.2, z), "सेक्टर पार्क • SECTOR PARK", -side, Color("f4efe4"), 26)
	box(Vector3(side * 11.3, 2.2, z), Vector3(0.1, 0.6, 5.0), "green")
	for tz in [-26.0, -12.0, 4.0, 18.0, 28.0]:
		big_tree(x + (6.0 if int(tz) % 2 == 0 else -6.0), z + tz, 1.1)
	for b in range(4):
		var bz := z - 20.0 + b * 13.0
		box(Vector3(x - 10.0, 0.65, bz), Vector3(0.5, 0.08, 1.8), "wood")
		box(Vector3(x - 10.2, 0.95, bz), Vector3(0.08, 0.5, 1.8), "wood")
		for leg in [-0.7, 0.7]:
			box(Vector3(x - 10.0, 0.45, bz + leg), Vector3(0.4, 0.4, 0.08), "metal")
	# Swings and a slide on the north end.
	var sz := z - 22.0
	for leg in [-1.5, 1.5]:
		box(Vector3(x + 8.0 + leg, 1.4, sz), Vector3(0.1, 2.8, 0.1), "metal", true)
	box(Vector3(x + 8.0, 2.8, sz), Vector3(3.4, 0.1, 0.1), "metal")
	for seat in [-0.6, 0.6]:
		box(Vector3(x + 8.0 + seat, 1.6, sz), Vector3(0.03, 2.2, 0.03), "metal")
		box(Vector3(x + 8.0 + seat, 0.55, sz), Vector3(0.45, 0.06, 0.25), "red")
	box(Vector3(x + 8.0, 1.2, sz + 6.0), Vector3(1.0, 2.4, 1.0), "metal", true)
	box(Vector3(x + 8.0, 1.3, sz + 7.6), Vector3(0.8, 0.1, 3.4), "yellow", true, Vector3(-0.6, 0, 0))
	chhatri(x, 0.28, z + 24.0, 2.2)
	box(Vector3(x, 0.55, z + 24.0), Vector3(2.0, 0.5, 2.0), "stone", true)

func temple(side: int, z: float) -> void:
	var x := side * 17.0
	box(Vector3(x, 0.3, z), Vector3(8.0, 0.6, 8.0), "white", true)
	box(Vector3(x, 2.4, z), Vector3(5.0, 3.6, 5.0), "white", true)
	for tier in range(5):
		var size := 3.6 - tier * 0.6
		box(Vector3(x, 4.6 + tier * 1.1, z), Vector3(size, 1.1, size), "orange" if tier % 2 else "white")
	round_prop(Vector3(x, 10.4, z), Vector3(1.2, 0.9, 1.2), "gold")
	box(Vector3(x, 11.6, z), Vector3(0.05, 1.8, 0.05), "metal")
	box(Vector3(x + side * -0.3, 12.2, z), Vector3(0.6, 0.4, 0.02), "saffron")
	box(Vector3(x - side * 2.5, 1.5, z), Vector3(0.3, 1.8, 1.4), "dark")
	arch(x - side * 2.55, 2.4, z, 0.7)
	for bell in range(3):
		round_prop(Vector3(x - side * 3.0, 2.6, z - 1.0 + bell), Vector3(0.2, 0.3, 0.2), "gold")
	label3d(Vector3(x - side * 2.7, 3.6, z), "श्री गणेश मंदिर", -side, Color("c2410c"), 30)

# ---------------------------------------------------------------- hills ----

func terrain_height(x: float, z: float) -> float:
	var north := clampf((-480.0 - z) / 280.0, 0.0, 1.0)
	var side := clampf((absf(x) - 44.0) / 190.0, 0.0, 1.0)
	var side_start := clampf((-330.0 - z) / 140.0, 0.0, 1.0)
	var h := pow(north, 1.5) * 92.0 + pow(side, 1.4) * 55.0 * side_start
	var relief := north + side * side_start
	h += noise.get_noise_2d(x * 0.35, z * 0.35) * 22.0 * relief
	h += noise.get_noise_2d(x, z) * 7.0 * relief
	h += noise.get_noise_2d(x * 3.0, z * 3.0) * 1.5 * relief
	# Keep the road corridor flat until the viewpoint, then let it climb gently.
	var corridor := clampf((absf(x) - 16.0) / 20.0, 0.0, 1.0)
	var past_end := clampf((-510.0 - z) / 40.0, 0.0, 1.0)
	return h * maxf(corridor, past_end)

func zone_hills() -> void:
	# Road ends at a viewpoint; terrain rises north with a fort wall on the ridge.
	box(Vector3(0, -0.35, -495.0), Vector3(48, 0.7, 30), "stone", true)
	box(Vector3(0, 0.015, -495.0), Vector3(16, 0.03, 30), "tarmac")
	box(Vector3(0, 0.6, -509.5), Vector3(30, 1.2, 0.8), "fort", true)
	for x in [-14.0, -7.0, 0.0, 7.0, 14.0]:
		box(Vector3(x, 1.4, -509.5), Vector3(0.8, 0.5, 0.9), "fort")
	zone_sign(-484.0, "NAHARGARH VIEW POINT", "नाहरगढ़ व्यू पॉइंट")
	bins(-9.0, -500.0)
	vehicle_car(-6.0, -492.0, "white", PI / 2)
	vehicle_scooter(5.0, -500.0, "red", PI / 2)
	terrain_mesh()
	# Stone steps and a path up the slope to a chhatri viewpoint.
	var path_z := -512.0
	while path_z > -600.0:
		var y := terrain_height(0.0, path_z)
		box(Vector3(0, y + 0.05, path_z), Vector3(3.0, 0.14, 2.2), "fort", true)
		path_z -= 2.0
	var top_y := terrain_height(0.0, -600.0)
	box(Vector3(0, top_y + 0.1, -604.0), Vector3(8.0, 0.3, 8.0), "fort", true)
	chhatri(0, top_y + 0.2, -604.0, 2.4)
	fort_wall()
	for i in range(140):
		var x := rng.randf_range(-230.0, 230.0)
		var z := rng.randf_range(-770.0, -335.0)
		var y := terrain_height(x, z)
		if y < 2.0 or (absf(x) < 12.0 and z > -610.0):
			continue
		scrub_tree(x, y - 0.2, z, rng.randf_range(0.7, 1.6))
	for i in range(90):
		var x := rng.randf_range(-230.0, 230.0)
		var z := rng.randf_range(-770.0, -340.0)
		var y := terrain_height(x, z)
		if y < 1.5 or (absf(x) < 10.0 and z > -610.0):
			continue
		round_prop(Vector3(x, y, z), Vector3(rng.randf_range(1.0, 4.0), rng.randf_range(0.6, 2.2), rng.randf_range(1.0, 3.5)), "hill_rock" if i % 3 else "sand")

func terrain_mesh() -> void:
	var step := 8.0
	var x0 := -240.0
	var z0 := -300.0
	var nx := 61
	var nz := 61
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Shared vertices with indices give smooth shading instead of a faceted hill.
	for iz in range(nz):
		for ix in range(nx):
			var x := x0 + ix * step
			var z := z0 - iz * step
			var y := terrain_height(x, z)
			var slope := absf(terrain_height(x + step, z) - y) / step + absf(terrain_height(x, z - step) - y) / step
			var low := Color("5e5038")
			var mid := Color("4b5a33")
			var high := Color("5a544c")
			var color := low.lerp(mid, clampf(y / 30.0, 0.0, 1.0)).lerp(high, clampf((y - 45.0) / 40.0, 0.0, 1.0))
			color = color.lerp(Color("7a6c5a"), clampf(slope * 1.2, 0.0, 0.7))
			color = color.darkened(clampf(noise.get_noise_2d(x * 2.0, z * 2.0) * 0.3, -0.18, 0.18))
			surface.set_color(color)
			surface.add_vertex(Vector3(x, y, z))
	for iz in range(nz - 1):
		for ix in range(nx - 1):
			var a := iz * nx + ix
			var b := a + 1
			var c := a + nx
			var d := c + 1
			for index in [a, d, b, a, c, d]:
				surface.add_index(index)
	surface.generate_normals()
	var mesh := surface.commit()
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 1.0
	mat.albedo_texture = load("res://assets/textures/plaster_Diffuse.jpg")
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = true
	mat.uv1_scale = Vector3.ONE * 0.08
	instance.material_override = mat
	add_child(instance)
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = mesh.create_trimesh_shape()
	body.add_child(shape)
	add_child(body)

func fort_wall() -> void:
	# Nahargarh-style rampart along the ridge, bastions every 48 m, a fort block in the middle.
	var x := -176.0
	while x <= 176.0:
		var z := -700.0 + sin(x * 0.03) * 12.0
		var y := terrain_height(x, z)
		box(Vector3(x, y + 2.5, z), Vector3(12.5, 6.0, 3.0), "fort", true, Vector3(0, cos(x * 0.03) * -0.3, 0))
		for merlon in range(6):
			box(Vector3(x - 5.0 + merlon * 2.0, y + 6.0, z), Vector3(0.9, 1.0, 3.1), "fort")
		if int(x + 176.0) % 48 == 0:
			box(Vector3(x, y + 4.5, z), Vector3(8.0, 10.0, 8.0), "fort", true)
			for merlon in range(8):
				var a := merlon * TAU / 8
				box(Vector3(x + cos(a) * 3.8, y + 10.0, z + sin(a) * 3.8), Vector3(1.0, 1.0, 1.0), "fort")
		x += 12.0
	var fy := terrain_height(0.0, -706.0)
	box(Vector3(0, fy + 8.0, -716.0), Vector3(36.0, 16.0, 22.0), "fort", true)
	box(Vector3(0, fy + 16.4, -716.0), Vector3(37.0, 0.6, 23.0), "trim")
	for merlon in range(18):
		box(Vector3(-17.0 + merlon * 2.0, fy + 17.2, -705.5), Vector3(1.0, 1.2, 1.0), "fort")
	for cx in [-14.0, 0.0, 14.0]:
		chhatri(cx, fy + 16.6, -716.0, 1.8)
	for window in range(7):
		var wx := -14.0 + window * 4.7
		box(Vector3(wx, fy + 10.0, -704.9), Vector3(1.4, 2.2, 0.2), "dark")
		arch(wx, fy + 10.8, -704.85, 0.7, PI / 2)
		box(Vector3(wx, fy + 5.0, -704.9), Vector3(1.4, 2.2, 0.2), "dark")
		arch(wx, fy + 5.8, -704.85, 0.7, PI / 2)
	var label := Label3D.new()
	label.text = "नाहरगढ़"
	label.font = hindi_font
	label.font_size = 96
	label.pixel_size = 0.04
	label.position = Vector3(0, fy + 20.5, -705.0)
	label.modulate = Color("f7e6c6")
	label.outline_size = 8
	add_child(label)

# ------------------------------------------------------------- old gali ----

func embed_gali() -> void:
	# The narrow photo-referenced lane branches west off Hawa Mahal Road.
	gali = preload("res://art_review/lane_study.gd").new()
	gali.name = "OldGali"
	gali.skip_lighting = true
	gali.open_end = true
	gali.position = GALI_ORIGIN
	gali.rotation.y = PI / 2
	add_child(gali)
	# Footpath ramp into the lane and a sign at its mouth.
	box(Vector3(-12.1, 0.1, 20.0), Vector3(3.6, 0.2, 5.4), "stone", true)
	zone_sign_small(-10.6, 23.2, "मणिहारों का रास्ता", "MANIHARON KA RASTA →")

func zone_sign_small(x: float, z: float, hindi: String, text: String) -> void:
	box(Vector3(x, 1.4, z), Vector3(0.07, 2.8, 0.07), "metal")
	box(Vector3(x, 2.95, z), Vector3(0.06, 0.55, 2.2), "blue")
	var label := Label3D.new()
	label.text = hindi + "\n" + text
	label.font = hindi_font
	label.font_size = 26
	label.pixel_size = 0.0055
	label.position = Vector3(x + 0.04, 2.95, z)
	label.rotation.y = PI / 2
	label.modulate = Color("f4efe4")
	label.outline_size = 2
	add_child(label)
