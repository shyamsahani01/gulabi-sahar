extends "res://vehicle_design.gd"
## Original parked commuter scooter, inspired by Jaipur market reference photos.
func _ready() -> void:
	material("paint",paint,.3,.32)
	material("rubber",Color("20262a"),0,.85)
	material("chrome",Color("939fa4"),.7,.28)
	material("lamp",Color("eee2b6"),.1,.2)
	material("tail",Color("a9322c"),.15,.3)
	for z in [-.59,.57]:
		var tire:=CylinderMesh.new()
		tire.top_radius=.245
		tire.bottom_radius=.245
		tire.height=.14
		tire.radial_segments=20
		append_mesh(tire,Transform3D(Basis(Vector3.FORWARD,PI/2),Vector3(0,.25,z)),"rubber")
		var hub:=CylinderMesh.new()
		hub.top_radius=.135
		hub.bottom_radius=.135
		hub.height=.15
		hub.radial_segments=16
		append_mesh(hub,Transform3D(Basis(Vector3.FORWARD,PI/2),Vector3(0,.25,z)),"chrome")
	oval(Vector3(0,.52,.37),Vector3(.46,.56,.88),"paint")
	oval(Vector3(0,.79,.25),Vector3(.43,.15,.70),"rubber")
	part(Vector3(0,.29,-.12),Vector3(.42,.08,.68),"rubber")
	oval(Vector3(0,.69,-.49),Vector3(.45,.84,.27),"paint")
	part(Vector3(0,.93,-.51),Vector3(.08,.55,.07),"chrome",Vector3(-.16,0,0))
	oval(Vector3(0,1.13,-.54),Vector3(.43,.2,.21),"paint")
	oval(Vector3(0,1.13,-.65),Vector3(.26,.13,.025),"lamp")
	part(Vector3(0,1.12,-.50),Vector3(.69,.045,.045),"chrome")
	for side in [-1,1]:
		part(Vector3(side*.31,1.12,-.50),Vector3(.14,.065,.075),"rubber")
		part(Vector3(side*.29,1.28,-.50),Vector3(.018,.28,.018),"chrome",Vector3(0,0,side*-.2))
		oval(Vector3(side*.32,1.42,-.49),Vector3(.17,.10,.035),"chrome")
		part(Vector3(side*.13,.19,.26),Vector3(.025,.35,.04),"chrome",Vector3(0,0,side*.4))
	oval(Vector3(0,.62,.78),Vector3(.25,.1,.035),"tail")
	part(Vector3(0,.46,.79),Vector3(.22,.12,.02),"lamp")
	flush(self)

func oval(at: Vector3, size: Vector3, key: String) -> void:
	var mesh:=SphereMesh.new()
	mesh.radius=.5
	mesh.height=1
	mesh.radial_segments=16
	mesh.rings=8
	append_mesh(mesh,Transform3D(Basis.from_scale(size),at),key)
