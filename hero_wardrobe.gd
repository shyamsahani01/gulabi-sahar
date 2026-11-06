extends RefCounted
## GTA-style outfits for the hero, built from the user's character reference sheet (2026-11-06):
## sunglasses, open leather jacket over a white tee with a chain, dark jeans and white sneakers,
## plus hoodie/cargo, tactical-vest and the original classic look. Everything is procedural
## geometry attached to the existing rig; the face, hair and body meshes are unchanged.
const OUTFITS := [
	{"name":"Street","style":1,"shell":"1a1a1d","tee":"ece8e0","trim":"b9bec2","pants":"2a3650","denim":1.0,"shoes":"f1efe9","sole":"cfccc4","accent":0.0,"glasses":true,"chain":true,"watch":true,"sleeves":"1a1a1d","sleeve_rough":.38,"beard":true},
	{"name":"Hoodie","style":2,"shell":"e8e1d3","tee":"e8e1d3","trim":"2a2a2a","pants":"25272b","denim":0.0,"shoes":"f4f2ee","sole":"1d1d1f","accent":1.0,"glasses":true,"cap":true,"hood":true,"logo":true,"cargo":true,"watch":true,"sleeves":"e8e1d3","sleeve_rough":.92,"beard":true},
	{"name":"Tactical","style":3,"shell":"17181a","tee":"17181a","trim":"2a2a2a","pants":"4b4f49","denim":0.0,"shoes":"151515","sole":"0b0b0b","accent":0.0,"glasses":true,"vest":true,"cargo":true,"watch":true,"beard":true},
	{"name":"Classic","style":0,"shell":"e6e1d5","tee":"e6e1d5","trim":"2a2a2a","pants":"36383b","denim":1.0,"shoes":"d0c8b8","sole":"4d5050","accent":0.0,"beard":false},
]
static var meshes: Dictionary = {}

static func solid(color: String, roughness := .8, metallic := 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(color)
	mat.roughness = roughness
	mat.metallic = metallic
	mat.metallic_specular = .5 if metallic > .3 else .3
	return mat

static func part(parent: Node3D, mesh: Mesh, at: Vector3, scale: Vector3, material: Material, euler := Vector3.ZERO) -> MeshInstance3D:
	var piece := MeshInstance3D.new()
	piece.mesh = mesh
	piece.material_override = material
	piece.transform = Transform3D(Basis.from_euler(euler).scaled(scale), at)
	piece.visibility_range_end = 55
	piece.visibility_range_end_margin = 3
	parent.add_child(piece)
	return piece

static func attach(human: Node3D, bone: String) -> BoneAttachment3D:
	var node := BoneAttachment3D.new()
	node.bone_name = bone
	node.name = "Wardrobe_" + bone + "_" + str(human.wardrobe_nodes.size())
	human.skeleton.add_child(node)
	human.wardrobe_nodes.append(node)
	return node

static func sphere() -> Mesh:
	if not meshes.has("sphere"):
		var s := SphereMesh.new()
		s.radius = .5
		s.height = 1
		s.radial_segments = 18
		s.rings = 9
		meshes["sphere"] = s
	return meshes["sphere"]

static func cube() -> Mesh:
	if not meshes.has("cube"):
		meshes["cube"] = BoxMesh.new()
	return meshes["cube"]

static func tube(top: float, bottom: float) -> Mesh:
	var key := "tube%.3f_%.3f" % [top, bottom]
	if not meshes.has(key):
		var c := CylinderMesh.new()
		c.top_radius = top
		c.bottom_radius = bottom
		c.height = 1
		c.radial_segments = 14
		c.rings = 1
		meshes[key] = c
	return meshes[key]

static func apply(human: Node3D, index: int) -> void:
	for node in human.wardrobe_nodes:
		if is_instance_valid(node):
			node.queue_free()
	human.wardrobe_nodes.clear()
	var o: Dictionary = OUTFITS[wrapi(index, 0, OUTFITS.size())]
	human.outfit = wrapi(index, 0, OUTFITS.size())
	# Torso and legs reuse the skinned garments with new surface looks.
	for mesh in human.model.find_children("*", "MeshInstance3D", true, false):
		if "t-shirt" in mesh.name:
			var garment := ShaderMaterial.new()
			garment.shader = preload("res://assets/shaders/garment.gdshader")
			garment.set_shader_parameter("style", o.style)
			garment.set_shader_parameter("shell_color", Color(o.shell))
			garment.set_shader_parameter("tee_color", Color(o.tee))
			garment.set_shader_parameter("trim_color", Color(o.trim))
			for surface in mesh.mesh.get_surface_count():
				mesh.set_surface_override_material(surface, garment)
		elif "pants" in mesh.name:
			var fabric := ShaderMaterial.new()
			fabric.shader = preload("res://assets/shaders/woven_fabric.gdshader")
			fabric.set_shader_parameter("cloth_color", Color(o.pants))
			fabric.set_shader_parameter("denim", o.denim)
			for surface in mesh.mesh.get_surface_count():
				mesh.set_surface_override_material(surface, fabric)
		elif mesh.name.begins_with("HeroShoe"):
			var shoe := ShaderMaterial.new()
			shoe.shader = preload("res://assets/shaders/sneaker.gdshader")
			shoe.set_shader_parameter("upper_color", Color(o.shoes))
			shoe.set_shader_parameter("sole_color", Color(o.sole))
			shoe.set_shader_parameter("accent", o.accent)
			for surface in mesh.mesh.get_surface_count():
				mesh.set_surface_override_material(surface, shoe)
	if human.stubble != null:
		human.stubble.visible = o.get("beard", false)
	var leather := solid(o.get("sleeves", o.shell), o.get("sleeve_rough", .5))
	var chrome := solid("d9dde0", .22, .95)
	var black := solid("111214", .45)
	if o.get("style", 0) in [1, 2]:
		# Long sleeves follow the arm bones: shoulder-to-elbow and elbow-to-wrist tubes.
		for side in ["l", "r"]:
			part(attach(human, "upperarm_" + side), tube(.052, .06), Vector3(0, .145, 0), Vector3(1, .27, 1), leather)
			part(attach(human, "lowerarm_" + side), tube(.04, .053), Vector3(0, .125, 0), Vector3(1, .26, 1), leather)
			part(attach(human, "lowerarm_" + side), sphere(), Vector3(0, .005, 0), Vector3(.105, .105, .105), leather)
	if o.get("glasses", false):
		var head := attach(human, "head")
		var lens := solid("0d0f12", .12, .7)
		lens.albedo_color.a = .92
		lens.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		for side in [-1, 1]:
			part(head, sphere(), Vector3(side * .033, .027, .096), Vector3(.06, .03, .014), lens)
			part(head, cube(), Vector3(side * .033, .041, .095), Vector3(.062, .004, .008), black)
			part(head, cube(), Vector3(side * .066, .038, .032), Vector3(.004, .005, .12), black)
		part(head, cube(), Vector3(0, .036, .1), Vector3(.012, .004, .005), black)
	if o.get("chain", false):
		var chest := attach(human, "spine_03")
		var torus := TorusMesh.new()
		torus.inner_radius = .077
		torus.outer_radius = .083
		torus.rings = 36
		torus.ring_segments = 8
		torus.inner_radius = .064
		torus.outer_radius = .07
		part(chest, torus, Vector3(0, .262, .095), Vector3.ONE, chrome, Vector3(-.32, 0, 0))
		part(chest, cube(), Vector3(0, .2, .133), Vector3(.014, .022, .005), chrome)
	if o.get("watch", false):
		var wrist := attach(human, "lowerarm_l")
		part(wrist, tube(.5, .5), Vector3(0, .222, 0), Vector3(.076, .02, .066), black)
		part(wrist, cube(), Vector3(0, .222, .034), Vector3(.03, .012, .012), chrome)
	if o.get("cap", false):
		var head := attach(human, "head")
		var cap := solid("17181b", .85)
		part(head, sphere(), Vector3(0, .088, -.008), Vector3(.23, .15, .245), cap)
		part(head, cube(), Vector3(0, .05, -.155), Vector3(.1, .006, .09), cap)
		part(head, cube(), Vector3(0, .05, -.06), Vector3(.215, .018, .2), cap)
	if o.get("hood", false):
		var back := attach(human, "spine_03")
		part(back, sphere(), Vector3(0, .325, -.055), Vector3(.22, .12, .16), solid(o.shell, .92))
	if o.get("logo", false):
		var chest := attach(human, "spine_03")
		var text := TextMesh.new()
		text.font = load("res://assets/fonts/DejaVuSans-Bold.ttf")
		text.font_size = 64
		text.pixel_size = .0007
		text.depth = .004
		text.text = "GS★"
		var label := MeshInstance3D.new()
		label.mesh = text
		label.material_override = solid("202124", .8)
		label.transform = Transform3D(Basis.from_euler(Vector3(-.1, 0, 0)), Vector3(.085, .21, .168))
		label.visibility_range_end = 40
		chest.add_child(label)
	if o.get("cargo", false):
		var canvas := solid(o.pants, .92)
		for side in ["l", "r"]:
			var thigh := attach(human, "thigh_" + side)
			var out := .074 if side == "l" else -.074
			part(thigh, cube(), Vector3(out, .25, -.015), Vector3(.03, .12, .085), canvas)
			part(thigh, cube(), Vector3(out * 1.1, .205, -.015), Vector3(.034, .012, .09), solid(o.pants, .92).duplicate())
	if o.get("vest", false):
		var chest := attach(human, "spine_03")
		var nylon := solid("141516", .9)
		part(chest, cube(), Vector3(0, .135, .168), Vector3(.21, .17, .035), nylon, Vector3(-.12, 0, 0))
		part(chest, cube(), Vector3(0, .145, -.138), Vector3(.22, .18, .035), nylon, Vector3(.1, 0, 0))
		for side in [-1, 1]:
			part(chest, cube(), Vector3(side * .168, .15, .012), Vector3(.025, .1, .2), nylon)
			part(chest, cube(), Vector3(side * .072, .27, .05), Vector3(.045, .075, .15), nylon)
		for i in 3:
			part(chest, cube(), Vector3(-.065 + i * .065, .095, .195), Vector3(.05, .055, .03), nylon)
