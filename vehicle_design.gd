extends Node3D
## Original, reusable low-poly vehicles. Forward is -Z; dimensions are metres.
## Static parts are merged by material; only the four wheel assemblies animate.
var paint := Color("e8d9bc")
var style := "sedan"
var wheels: Array[Node3D] = []
var steering := 0.0
var surfaces: Dictionary = {}
var materials: Dictionary = {}

func material(key: String, color: Color, metal := 0.0, rough := 0.5) -> void:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = metal
	m.roughness = rough
	materials[key] = m

func _ready() -> void:
	material("paint", paint, .48, .28)
	material("glass", Color("263e4b"), .5, .18)
	material("rubber", Color("1b2025"), 0, .9)
	material("chrome", Color("b6c5cc"), .8, .23)
	material("lamp", Color("fff0cd"), .2, .2)
	material("tail", Color("cb383d"), .25, .28)
	material("plate", Color("edf0df"), .1, .6)
	material("blue", Color("285fa2"), .3, .3)
	build_body()
	flush(self)
	for side in [-1, 1]:
		for z in [-1.28, 1.25]:
			var wheel := Node3D.new()
			wheel.position = Vector3(side * .88, .38, z)
			add_child(wheel)
			wheels.append(wheel)
			var tire := CylinderMesh.new()
			tire.top_radius = .365
			tire.bottom_radius = .365
			tire.height = .24
			tire.radial_segments = 24
			append_mesh(tire, Transform3D(Basis(Vector3.FORWARD, PI/2), Vector3.ZERO), "rubber")
			var rim := CylinderMesh.new()
			rim.top_radius = .235
			rim.bottom_radius = .235
			rim.height = .255
			rim.radial_segments = 20
			append_mesh(rim, Transform3D(Basis(Vector3.FORWARD, PI/2), Vector3.ZERO), "chrome")
			for spoke in 5:
				var a := spoke * TAU / 5
				part(Vector3(side*.133, sin(a)*.12, cos(a)*.12), Vector3(.012,.075,.19), "rubber", Vector3(-a,0,0))
			flush(wheel)

func surface(key: String) -> SurfaceTool:
	if not surfaces.has(key):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		surfaces[key] = st
	return surfaces[key]

func append_mesh(mesh: Mesh, transform: Transform3D, key: String) -> void:
	var st := surface(key)
	for point in mesh.get_faces():
		st.set_uv(Vector2.ZERO)
		st.add_vertex(transform * point)

func part(at: Vector3, size: Vector3, key: String, rot := Vector3.ZERO) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	append_mesh(mesh, Transform3D(Basis.from_euler(rot), at), key)

func panel(points: Array, key: String) -> void:
	var st := surface(key)
	# Two-sided material-free geometry keeps windshields readable from either side.
	for i in range(1, points.size()-1):
		for p in [points[0],points[i],points[i+1],points[0],points[i+1],points[i]]:
			st.set_uv(Vector2(p.x,p.y))
			st.add_vertex(p)

func build_body() -> void:
	# Chamfered cross sections give the bonnet, shoulder and boot distinct profiles.
	var rings: Array = []
	for spec in [[-2.02,.71,.62],[-1.78,.87,.83],[-.78,.9,.91],[.98,.9,.91],[1.73,.85,.83],[1.98,.73,.70]]:
		var z: float = spec[0]
		var w: float = spec[1]
		var h: float = spec[2]
		rings.append([Vector3(-w*.88,.38,z),Vector3(-w,.54,z),Vector3(-w,h-.12,z),Vector3(-w*.86,h,z),Vector3(w*.86,h,z),Vector3(w,h-.12,z),Vector3(w,.54,z),Vector3(w*.88,.38,z)])
	for i in range(rings.size()-1):
		for j in 8:
			panel([rings[i][j],rings[i][(j+1)%8],rings[i+1][(j+1)%8],rings[i+1][j]],"paint")
	panel(rings[0],"paint")
	panel(rings[-1],"paint")
	var roof_y := 1.52 if style != "taxi" else 1.64
	var rear := .82 if style != "taxi" else 1.18
	panel([Vector3(-.70,roof_y,-.38),Vector3(.70,roof_y,-.38),Vector3(.72,roof_y,rear),Vector3(-.72,roof_y,rear)],"paint")
	panel([Vector3(-.75,.94,-.95),Vector3(.75,.94,-.95),Vector3(.67,roof_y-.05,-.40),Vector3(-.67,roof_y-.05,-.40)],"glass")
	panel([Vector3(-.72,roof_y-.05,rear),Vector3(.72,roof_y-.05,rear),Vector3(.77,.94,1.46),Vector3(-.77,.94,1.46)],"glass")
	for side in [-1,1]:
		panel([Vector3(side*.83,.94,-.89),Vector3(side*.69,roof_y-.04,-.34),Vector3(side*.71,roof_y-.04,.28),Vector3(side*.85,.94,.28)],"glass")
		panel([Vector3(side*.85,.94,.37),Vector3(side*.71,roof_y-.04,.37),Vector3(side*.71,roof_y-.04,rear-.03),Vector3(side*.83,.94,1.39)],"glass")
		part(Vector3(side*.84,.89,.24),Vector3(.04,.055,2.5),"chrome")
		part(Vector3(side*.87,.68,.28),Vector3(.015,.32,.018),"rubber")
		for z in [.10,1.02]:
			part(Vector3(side*.906,.82,z),Vector3(.04,.035,.18),"chrome")
		part(Vector3(side*.99,1.02,-.66),Vector3(.24,.13,.23),"paint",Vector3(0,side*.2,0))
		part(Vector3(side*1.01,1.02,-.53),Vector3(.17,.085,.02),"glass")
		part(Vector3(side*.59,.69,-1.94),Vector3(.43,.14,.07),"lamp",Vector3(0,side*-.20,0))
		part(Vector3(side*.60,.66,1.95),Vector3(.42,.12,.06),"tail",Vector3(0,side*.17,0))
		part(Vector3(side*.88,.39,0),Vector3(.07,.10,1.70),"rubber")
	part(Vector3(0,.48,-2.015),Vector3(1.38,.12,.06),"rubber")
	part(Vector3(0,.68,-2.025),Vector3(.62,.16,.025),"rubber")
	for y in [.63,.68,.73]:
		part(Vector3(0,y,-2.044),Vector3(.6,.018,.012),"chrome")
	for z in [-2.055,2.01]:
		part(Vector3(0,.48,z),Vector3(.37,.10,.018),"plate")
		for x in range(6):
			part(Vector3(-.13+x*.05,.48,z+signf(z)*.011),Vector3(.022,.047,.008),"rubber")
	if style == "police":
		part(Vector3(0,roof_y+.13,.2),Vector3(1.0,.08,.25),"rubber")
		part(Vector3(-.3,roof_y+.21,.2),Vector3(.39,.12,.23),"tail")
		part(Vector3(.3,roof_y+.21,.2),Vector3(.39,.12,.23),"blue")
		for side in [-1,1]:
			part(Vector3(side*.906,.7,.2),Vector3(.015,.12,1.7),"blue")
	elif style == "taxi":
		part(Vector3(0,roof_y+.13,.2),Vector3(.55,.19,.23),"lamp")

func flush(parent: Node3D) -> void:
	var combined := ArrayMesh.new()
	for key in surfaces:
		var st: SurfaceTool = surfaces[key]
		st.generate_normals()
		st.set_material(materials[key])
		st.commit(combined)
	var mesh := MeshInstance3D.new()
	mesh.mesh = combined
	mesh.visibility_range_end = 230
	parent.add_child(mesh)
	surfaces.clear()

func animate_wheels(distance: float, turn: float) -> void:
	steering = lerpf(steering, turn * -.38, .18)
	for i in wheels.size():
		var wheel: Node3D = wheels[i]
		wheel.rotation.y = steering if i % 2 == 0 else 0.0
		wheel.get_child(0).rotate_x(-distance / .365)
