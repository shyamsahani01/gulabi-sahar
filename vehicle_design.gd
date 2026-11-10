extends Node3D
## Original game vehicles, metres, forward -Z. Shared material batches per body;
## four independently rolling wheels. No licensed marques or external car assets.
static var model_cache: Dictionary = {}
var paint := Color("eee3ca")
var style := "sedan"
var wheels: Array[Node3D] = []
var steering := 0.0
var surfaces: Dictionary = {}
var materials: Dictionary = {}
var tire_radius := .365
var wheel_z := [-1.38,1.30]
var roof_height := 1.52
var half_width := .92
var wheel_x := .88

func material(key: String, color: Color, metal := 0.0, rough := 0.5) -> void:
	var m := StandardMaterial3D.new()
	m.albedo_color=color
	m.metallic=metal
	m.roughness=rough
	m.cull_mode=BaseMaterial3D.CULL_DISABLED
	materials[key]=m

func _ready() -> void:
	if style in ["suv","ambulance"]:
		tire_radius=.415
		roof_height=1.82
		half_width=.98
		wheel_x=.94
	elif style=="taxi":
		roof_height=1.72
		paint=Color("171d24")
	elif style in ["police","ambulance"]:
		paint=Color("ecf0ee")
	material("paint",paint,.32,.3)
	materials.paint.clearcoat_enabled=true
	materials.paint.clearcoat=.65
	materials.paint.clearcoat_roughness=.2
	material("glass",Color("253e4b"),.6,.12)
	material("rubber",Color("141a20"),0,.88)
	material("chrome",Color("d6e1e5"),.88,.19)
	material("alloy",Color("798d9c"),.8,.3)
	material("lamp",Color("edf8ff"),.15,.18)
	material("tail",Color("c72a35"),.25,.22)
	material("plate",Color("f0ede1"),.05,.6)
	material("blue",Color("214e9d"),.3,.3)
	material("taxi",Color("f0b52c"),.5,.26)
	material("interior",Color("564a40"),0,.9)
	for key in ["lamp","tail","blue"]:
		materials[key].emission_enabled=true
		materials[key].emission=materials[key].albedo_color
		materials[key].emission_energy_multiplier=.45 if key!="lamp" else .8
	# Parked ambulances/taxis and repeated traffic paints share immutable mesh
	# resources; each vehicle still owns its animated wheel transforms.
	var cache_key:=style+":"+paint.to_html()
	if model_cache.has(cache_key):
		var cached: Array=model_cache[cache_key]
		attach_mesh(self,cached[0])
		for side in [-1,1]:
			for z in wheel_z:
				var wheel:=Node3D.new()
				wheel.position=Vector3(side*wheel_x,tire_radius,z)
				add_child(wheel)
				wheels.append(wheel)
				attach_mesh(wheel,cached[wheels.size()])
	else:
		build_body()
		flush(self)
		build_wheels()
		var cached: Array=[get_child(0).mesh]
		for wheel in wheels: cached.append(wheel.get_child(0).mesh)
		model_cache[cache_key]=cached
	for back in [false,true]:
		var z:=2.163 if back else -2.222
		var text:="RJ14 GS 0001"
		if style=="taxi": text="RJ14 TX 2297"
		elif style=="police": text="RJ14 PC 1100"
		elif style in ["suv","ambulance"]: text="RJ14 SU 4400"
		badge(Vector3(0,.49,z),text,.075,0.0 if back else PI,Color("17212b"))
	if style=="taxi":
		badge(Vector3(0,roof_height+.14,-.019),"TAXI",.12,PI,Color("151b20"))
	if style in ["police","ambulance"]:
		for side in [-1,1]:
			badge(Vector3(side*(half_width+.018),.78,.1),"AMBULANCE" if style=="ambulance" else "POLICE",.16,side*PI/2,Color("f4f6f2"))

func surface(key: String) -> SurfaceTool:
	if not surfaces.has(key):
		var st:=SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		surfaces[key]=st
	return surfaces[key]

func append_mesh(mesh: Mesh, transform: Transform3D, key: String) -> void:
	var st:=surface(key)
	# Keep the whole batch non-indexed; append_from would index only primitives
	# and silently leave the hand-built body panels unreferenced.
	for point in mesh.get_faces():
		st.set_uv(Vector2.ZERO)
		st.add_vertex(transform*point)

func part(at: Vector3, size: Vector3, key: String, rot := Vector3.ZERO) -> void:
	var mesh:=BoxMesh.new()
	mesh.size=size
	append_mesh(mesh,Transform3D(Basis.from_euler(rot),at),key)

func panel(points: Array, key: String) -> void:
	var st:=surface(key)
	# One surface per panel: opposite duplicate faces cancel generated normals.
	for i in range(1,points.size()-1):
		for p in [points[0],points[i],points[i+1]]:
			st.set_uv(Vector2(p.x,p.y))
			st.add_vertex(p)

func rod(a: Vector3,b: Vector3,radius: float,key: String) -> void:
	var mesh:=CylinderMesh.new()
	mesh.top_radius=radius
	mesh.bottom_radius=radius
	mesh.height=a.distance_to(b)
	mesh.radial_segments=10
	var direction: Vector3=(b-a).normalized()
	var rotation:=Basis(Quaternion(Vector3.UP,direction))
	append_mesh(mesh,Transform3D(rotation,(a+b)*.5),key)

func orb(at: Vector3,size: Vector3,key: String) -> void:
	var mesh:=SphereMesh.new()
	mesh.radius=.5
	mesh.height=1
	mesh.radial_segments=24
	mesh.rings=12
	append_mesh(mesh,Transform3D(Basis.from_scale(size),at),key)

func body_section(z: float) -> Array:
	var h:=1.02 if style in ["suv","ambulance"] else .94
	var taper:=smoothstep(1.60,2.23,absf(z))
	var w:=half_width-taper*.16
	var top:=h-taper*.19
	var bottom:=.32 if style!="suv" else .37
	for axle in wheel_z:
		var dz: float=absf(z-axle)
		var arch:=tire_radius+.065
		if dz<arch: bottom=maxf(bottom,tire_radius+sqrt(arch*arch-dz*dz))
	return [Vector3(-w*.91,bottom,z),Vector3(-w,bottom+.015,z),Vector3(-w,top-.055,z),Vector3(-w*.88,top,z),Vector3(-w*.48,top+.035,z),Vector3(w*.48,top+.035,z),Vector3(w*.88,top,z),Vector3(w,top-.055,z),Vector3(w,bottom+.015,z),Vector3(w*.91,bottom,z)]

func build_body() -> void:
	var sill:=1.01 if style in ["suv","ambulance"] else .94
	# Dense curved sections plus real wheel cutouts remove the old cuboid shape.
	var zs: Array[float]=[-2.2,-2.13,-2.02,-1.88,-1.78,-.88,-.72,0,.7,.82,1.76,1.9,2.05,2.15]
	for axle in wheel_z:
		for i in 17:
			zs.append(axle+(tire_radius+.065)*cos(PI*i/16))
	zs.sort()
	for i in range(zs.size()-1):
		var a:=body_section(zs[i])
		var b:=body_section(zs[i+1])
		for j in range(a.size()-1):
			panel([a[j],a[j+1],b[j+1],b[j]],"paint")
	panel(body_section(-2.2),"paint")
	var last:=body_section(2.15)
	last.reverse()
	panel(last,"paint")
	part(Vector3(0,.32,0),Vector3(1.35,.12,3.8),"rubber")
	var front_top:=-.48
	var rear_top:=.72 if style=="sedan" or style=="police" else 1.16
	var rear_base:=1.53 if style!="suv" else 1.90
	var cabin_w:=half_width-.20
	var roof_key:="taxi" if style=="taxi" else "paint"
	# Rounded roof with eaves; swept pillars and quarter glass close the cabin.
	for i in 12:
		var x0:=lerpf(-cabin_w,cabin_w,float(i)/12)
		var x1:=lerpf(-cabin_w,cabin_w,float(i+1)/12)
		var y0:=roof_height+.055*(1-pow(x0/cabin_w,2))
		var y1:=roof_height+.055*(1-pow(x1/cabin_w,2))
		panel([Vector3(x0,y0,front_top),Vector3(x1,y1,front_top),Vector3(x1,y1,rear_top),Vector3(x0,y0,rear_top)],roof_key)
	panel([Vector3(-half_width*.83,sill,-1.03),Vector3(half_width*.83,sill,-1.03),Vector3(cabin_w,roof_height,front_top),Vector3(-cabin_w,roof_height,front_top)],"glass")
	panel([Vector3(-cabin_w,roof_height,rear_top),Vector3(cabin_w,roof_height,rear_top),Vector3(half_width*.84,sill,rear_base),Vector3(-half_width*.84,sill,rear_base)],"glass")
	for side in [-1,1]:
		var lower: float=side*half_width*.91
		var upper: float=side*cabin_w
		var window:=[Vector3(lower,sill,-.94),Vector3(upper,roof_height-.04,front_top+.06),Vector3(upper,roof_height-.04,rear_top-.06),Vector3(lower,sill,rear_base-.09)]
		panel(window if side>0 else [window[3],window[2],window[1],window[0]],"glass")
		rod(Vector3(lower,sill,-1.03),Vector3(upper,roof_height,front_top),.045,roof_key)
		rod(Vector3(upper,roof_height,rear_top),Vector3(lower,sill,rear_base),.06,roof_key)
		rod(Vector3(upper,roof_height,front_top),Vector3(upper,roof_height,rear_top),.032,"chrome")
		rod(Vector3(lower,sill,-1.03),Vector3(lower,sill,rear_base),.022,"chrome")
		rod(Vector3(lower,sill,.26),Vector3(upper,roof_height-.02,.26),.047,"rubber")
		rod(Vector3(lower,sill,1.03),Vector3(upper,roof_height-.02,.93),.025,"rubber")
		# Sculpted fender lips follow each open arch.
		for axle in wheel_z:
			for j in 20:
				var a:=PI*j/20
				var b:=PI*(j+1)/20
				var r:=tire_radius+.067
				rod(Vector3(side*(half_width+.008),tire_radius+sin(a)*r,axle+cos(a)*r),Vector3(side*(half_width+.008),tire_radius+sin(b)*r,axle+cos(b)*r),.028,"rubber" if style in ["suv","ambulance"] else "paint")
		part(Vector3(side*half_width,.48,0),Vector3(.04,.16,1.65),"rubber" if style in ["suv","ambulance"] else "paint")
		rod(Vector3(side*(half_width+.012),.82,-.78),Vector3(side*(half_width+.012),.82,1.0),.012,"chrome")
		for z in [-.85,.26,1.05]:
			rod(Vector3(side*(half_width+.006),.48,z),Vector3(side*(half_width+.006),sill-.06,z),.007,"rubber")
		for z in [.03,.88]:
			part(Vector3(side*(half_width+.025),.86,z),Vector3(.055,.035,.19),"chrome")
		rod(Vector3(side*.80,1.01,-.78),Vector3(side*1.04,1.06,-.73),.035,"rubber")
		orb(Vector3(side*1.06,1.10,-.70),Vector3(.24,.15,.28),"paint")
		part(Vector3(side*1.06,1.10,-.55),Vector3(.17,.10,.014),"glass")
		part(Vector3(side*1.06,1.095,-.835),Vector3(.18,.018,.016),"lamp")
		if style in ["police","ambulance"]:
			part(Vector3(side*(half_width+.014),.72,.1),Vector3(.013,.25,1.8),"tail" if style=="ambulance" else "blue")
			part(Vector3(side*(half_width+.023),.89,.1),Vector3(.014,.035,1.8),"tail")
		if style in ["suv","ambulance"]:
			rod(Vector3(side*.60,roof_height+.09,-.32),Vector3(side*.60,roof_height+.09,1.12),.035,"chrome")
			part(Vector3(side*.60,roof_height+.025,.45),Vector3(.055,.08,1.3),"rubber")
	# Bonnet creases, wipers and a broad inset grille with chrome surround.
	for side in [-1,1]:
		rod(Vector3(side*.37,.79,-2.05),Vector3(side*.53,sill+.035,-1.05),.008,"chrome")
		rod(Vector3(side*.28,sill+.04,-1.015),Vector3(side*.57,sill+.12,-.91),.013,"rubber")
	var grille:=[Vector3(-.54,.78,-2.213),Vector3(.54,.78,-2.213),Vector3(.44,.53,-2.222),Vector3(-.44,.53,-2.222)]
	panel(grille,"rubber")
	for i in 4: rod(grille[i],grille[(i+1)%4],.022,"chrome")
	for y in [.58,.64,.70,.75]:
		rod(Vector3(-.44,y,-2.229),Vector3(.44,y,-2.229),.009,"chrome")
	orb(Vector3(0,.69,-2.242),Vector3(.12,.065,.025),"chrome")
	part(Vector3(0,.38,-2.17),Vector3(1.22,.10,.09),"rubber")
	for side in [-1,1]:
		if style=="taxi":
			orb(Vector3(side*.64,.77,-2.13),Vector3(.33,.33,.11),"chrome")
			orb(Vector3(side*.64,.77,-2.195),Vector3(.265,.265,.035),"lamp")
		else:
			var lamp:=[Vector3(side*.49,.78,-2.22),Vector3(side*.80,.83,-2.10),Vector3(side*.83,.70,-2.08),Vector3(side*.55,.69,-2.21)]
			panel(lamp,"rubber")
			rod(lamp[0]+Vector3(0,.014,-.006),lamp[1]+Vector3(0,.014,-.006),.018,"lamp")
			orb(Vector3(side*.66,.75,-2.17),Vector3(.115,.075,.045),"lamp")
		part(Vector3(side*.68,.44,-2.08),Vector3(.24,.11,.08),"rubber")
		part(Vector3(side*.68,.45,-2.13),Vector3(.14,.025,.015),"lamp")
		part(Vector3(side*.62,.73,2.11),Vector3(.45,.13,.08),"tail",Vector3(0,side*.18,0))
		part(Vector3(side*.62,.73,2.16),Vector3(.28,.02,.02),"lamp")
		rod(Vector3(side*.5,.33,2.12),Vector3(side*.5,.33,2.24),.05,"chrome")
	part(Vector3(0,.39,2.12),Vector3(1.35,.13,.09),"rubber")
	for z in [-2.218,2.16]:
		part(Vector3(0,.49,z),Vector3(.49,.13,.016),"taxi" if style=="taxi" else "plate")
	if style=="taxi":
		part(Vector3(0,roof_height+.13,.12),Vector3(.6,.23,.28),"taxi")
		for side in [-1,1]:
			part(Vector3(side*(half_width+.015),.78,.08),Vector3(.015,.23,1.65),"taxi")
			for i in 12:
				part(Vector3(side*(half_width+.027),.83,-.65+i*.13),Vector3(.012,.07,.07),"rubber")
	elif style in ["police","ambulance"]:
		part(Vector3(0,roof_height+.09,.18),Vector3(1.15,.06,.26),"rubber")
		for side in [-1,1]:
			orb(Vector3(side*.33,roof_height+.17,.18),Vector3(.48,.16,.25),"tail" if side<0 or style=="ambulance" else "blue")
	elif style in ["suv","ambulance"]:
		part(Vector3(0,roof_height,1.25),Vector3(1.55,.08,.3),"paint")
		part(Vector3(0,roof_height-.04,1.41),Vector3(.52,.025,.02),"tail")

func build_wheels() -> void:
	for side in [-1,1]:
		for z in wheel_z:
			var wheel:=Node3D.new()
			wheel.position=Vector3(side*wheel_x,tire_radius,z)
			add_child(wheel)
			wheels.append(wheel)
			var tire:=TorusMesh.new()
			tire.inner_radius=tire_radius-.14
			tire.outer_radius=tire_radius
			tire.rings=32
			tire.ring_segments=12
			append_mesh(tire,Transform3D(Basis(Vector3.FORWARD,PI/2),Vector3.ZERO),"rubber")
			var rim:=CylinderMesh.new()
			rim.top_radius=tire_radius-.10
			rim.bottom_radius=rim.top_radius
			rim.height=.14
			rim.radial_segments=32
			append_mesh(rim,Transform3D(Basis(Vector3.FORWARD,PI/2),Vector3.ZERO),"rubber")
			var hoop:=TorusMesh.new()
			hoop.inner_radius=tire_radius-.13
			hoop.outer_radius=tire_radius-.10
			hoop.rings=32
			hoop.ring_segments=8
			append_mesh(hoop,Transform3D(Basis(Vector3.FORWARD,PI/2),Vector3(side*.082,0,0)),"chrome")
			for spoke in 10:
				var a:=spoke*TAU/10
				rod(Vector3(side*.09,sin(a)*.065,cos(a)*.065),Vector3(side*.09,sin(a+.13)*(tire_radius-.12),cos(a+.13)*(tire_radius-.12)),.018,"chrome")
			orb(Vector3(side*.09,0,0),Vector3(.035,.13,.13),"alloy")
			for stud in 5:
				var a:=stud*TAU/5
				orb(Vector3(side*.112,sin(a)*.043,cos(a)*.043),Vector3(.015,.018,.018),"chrome")
			flush(wheel)

func badge(at: Vector3,value: String,height: float,yaw: float,color: Color) -> void:
	var label:=Label3D.new()
	label.text=value
	label.font_size=48
	label.pixel_size=height/48
	label.modulate=color
	label.outline_size=0
	label.no_depth_test=false
	label.position=at
	label.rotation.y=yaw
	label.visibility_range_end=28
	add_child(label)

func flush(parent: Node3D) -> void:
	var combined:=ArrayMesh.new()
	for key in surfaces:
		var st: SurfaceTool=surfaces[key]
		st.generate_normals()
		st.set_material(materials[key])
		st.commit(combined)
	attach_mesh(parent,combined)
	surfaces.clear()

func attach_mesh(parent: Node3D,resource: ArrayMesh) -> void:
	var mesh:=MeshInstance3D.new()
	mesh.mesh=resource
	mesh.visibility_range_end=230
	parent.add_child(mesh)

func animate_wheels(distance: float, turn: float) -> void:
	steering=lerpf(steering,turn*-.38,.18)
	for i in wheels.size():
		var wheel: Node3D=wheels[i]
		wheel.rotation.y=steering if i%2==0 else 0.0
		wheel.get_child(0).rotate_x(-distance/tire_radius)
