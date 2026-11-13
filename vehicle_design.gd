extends Node3D
## Original reference-guided vehicle geometry, metres, forward -Z.
## Shared immutable body/wheel meshes; steering and wheel rotation stay per car.
static var model_cache: Dictionary = {}
var paint := Color("eee3ca")
var style := "sedan"
var wheels: Array[Node3D] = []
var steering := 0.0
var surfaces: Dictionary = {}
var materials: Dictionary = {}
var tire_radius := .335
var wheel_z := [-1.32,1.28]
var roof_height := 1.46
var half_width := .89
var wheel_x := .85
var suv := false
var taxi := false
var belt := 1.02
var roof_front := -.38
var roof_rear := .58
var cabin_width := .66

func material(key: String, color: Color, metal := 0.0, rough := .5) -> void:
	var m := StandardMaterial3D.new()
	m.albedo_color=color
	m.metallic=metal
	m.roughness=rough
	m.cull_mode=BaseMaterial3D.CULL_DISABLED
	materials[key]=m

func _ready() -> void:
	suv=style in ["suv","ambulance"]
	taxi=style=="taxi"
	if suv:
		tire_radius=.39
		roof_height=1.76
		half_width=.96
		wheel_x=.91
		belt=1.14
		roof_rear=1.05
		cabin_width=.72
	elif taxi:
		tire_radius=.36
		roof_height=1.64
		belt=1.04
		roof_front=-.55
		roof_rear=.82
		cabin_width=.70
		paint=Color("171d24")
	if style in ["police","ambulance"]: paint=Color("eef1f2")
	material("paint",paint,.24,.34)
	materials.paint.clearcoat_enabled=true
	materials.paint.clearcoat=.5
	materials.paint.clearcoat_roughness=.18
	material("glass",Color(.30,.43,.49,.26),.12,.24)
	materials.glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	material("lens",Color(.68,.78,.84,.18),.05,.12)
	materials.lens.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	material("rubber",Color("171b20"),0,.86)
	material("black",Color("10191d"),.25,.32)
	material("chrome",Color("87949e"),.7,.32)
	material("alloy",Color("66757e"),.7,.3)
	material("lamp",Color("f1f4ed"),.15,.22)
	material("tail",Color("a90d23"),.25,.25)
	material("plate",Color("eeeae0"),0,.65)
	material("blue",Color("1245a1"),.3,.29)
	material("taxi",Color("f4b920"),.3,.28)
	material("interior",Color("41454a"),0,.94)
	material("seat",Color("70675c"),0,.95)
	for key in ["lamp","tail"]:
		materials[key].emission_enabled=true
		materials[key].emission=materials[key].albedo_color
		materials[key].emission_energy_multiplier=.38 if key=="lamp" else .16
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
		build_cabin()
		build_interior()
		build_front()
		build_rear()
		build_details()
		flush(self)
		build_wheels()
		var cached: Array=[get_child(0).mesh]
		for wheel in wheels: cached.append(wheel.get_child(0).mesh)
		model_cache[cache_key]=cached
	var registration:="RJ14 GS 0001"
	if taxi: registration="RJ14 TX 2297"
	elif style=="police": registration="RJ14 PC 1100"
	elif suv: registration="RJ14 SU 4400"
	badge(Vector3(0,.48,-2.257),registration,.068,PI,Color("101820"))
	badge(Vector3(0,.65,2.178),registration,.068,0,Color("101820"))
	if taxi:
		badge(Vector3(0,roof_height+.14,-.081),"TAXI",.105,PI,Color("101820"))
	if style in ["police","ambulance"]:
		for side in [-1,1]:
			badge(Vector3(side*(half_width+.016),.84,.22),"AMBULANCE" if style=="ambulance" else "POLICE",.15,side*PI/2,Color.WHITE)
	if style=="police":
		var hood:=Label3D.new()
		hood.text="POLICE"
		hood.font_size=64
		hood.pixel_size=.0022
		hood.outline_size=0
		hood.modulate=Color("163988")
		hood.position=Vector3(0,top_height(-1.6)+.082,-1.6)
		var slope:=(top_height(-1.59)-top_height(-1.61))/.02
		hood.rotation=Vector3(-PI/2+atan(slope),PI,0)
		hood.visibility_range_end=28
		add_child(hood)

func surface(key: String) -> SurfaceTool:
	if not surfaces.has(key):
		var st:=SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_smooth_group(0)
		surfaces[key]=st
	return surfaces[key]

func append_mesh(mesh: Mesh, transform: Transform3D, key: String) -> void:
	var st:=surface(key)
	for point in mesh.get_faces():
		st.set_uv(Vector2.ZERO)
		st.add_vertex(transform*point)

func part(at: Vector3,size: Vector3,key: String,rot := Vector3.ZERO) -> void:
	var mesh:=BoxMesh.new()
	mesh.size=size
	append_mesh(mesh,Transform3D(Basis.from_euler(rot),at),key)

func panel(points: Array,key: String) -> void:
	var st:=surface(key)
	for i in range(1,points.size()-1):
		for p in [points[0],points[i],points[i+1]]:
			st.set_uv(Vector2(p.x,p.y))
			st.add_vertex(p)

func facing(points: Array,key: String,normal: Vector3) -> void:
	var vertices:=points.duplicate()
	if (vertices[1]-vertices[0]).cross(vertices[2]-vertices[0]).dot(normal)>0:
		vertices.reverse()
	panel(vertices,key)

func rod(a: Vector3,b: Vector3,radius: float,key: String) -> void:
	if a.distance_squared_to(b)<.000001: return
	var mesh:=CylinderMesh.new()
	mesh.top_radius=radius
	mesh.bottom_radius=radius
	mesh.height=a.distance_to(b)
	mesh.radial_segments=8
	mesh.rings=1
	append_mesh(mesh,Transform3D(Basis(Quaternion(Vector3.UP,(b-a).normalized())),(a+b)*.5),key)

func orb(at: Vector3,size: Vector3,key: String) -> void:
	var mesh:=SphereMesh.new()
	mesh.radius=.5
	mesh.height=1
	mesh.radial_segments=20
	mesh.rings=10
	append_mesh(mesh,Transform3D(Basis.from_scale(size),at),key)

# Bevelled solid with a rounded XY perimeter, rather than exposed box corners.
func rounded(at: Vector3,size: Vector3,r: float,key: String,rot := Vector3.ZERO) -> void:
	var rings: Array=[]
	var bevel:=minf(r*.45,size.z*.22)
	for section in 4:
		var end:=section==0 or section==3
		var inset:=bevel if end else 0.0
		var w:=size.x*.5-inset
		var h:=size.y*.5-inset
		var radius:=minf(r,minf(w,h))
		var z: float=[-size.z*.5,-size.z*.5+bevel,size.z*.5-bevel,size.z*.5][section]
		var points: Array=[]
		for corner in 4:
			var cx:=w-radius if corner in [0,3] else -w+radius
			var cy:=h-radius if corner in [0,1] else -h+radius
			for j in 5:
				var angle: float=corner*PI/2+j*PI/8
				points.append(at+Basis.from_euler(rot)*Vector3(cx+cos(angle)*radius,cy+sin(angle)*radius,z))
		rings.append(points)
	for i in 3:
		for j in rings[i].size():
			var k: int=(j+1)%rings[i].size()
			panel([rings[i+1][j],rings[i+1][k],rings[i][k],rings[i][j]],key)
	var front: Array=rings[0].duplicate()
	panel(front,key)
	var back: Array=rings[3].duplicate()
	back.reverse()
	panel(back,key)

func top_height(z: float) -> float:
	var nose:=smoothstep(-2.2,-.95,z)
	var tail:=smoothstep(1.35,2.15,z)
	return belt-.18+.18*nose-.13*tail

func body_width(z: float) -> float:
	return half_width*(1.0-.13*smoothstep(1.55,2.22,absf(z)))

func body_section(z: float) -> Array:
	var h:=top_height(z)
	var w:=body_width(z)
	var bottom:=.25 if not suv else .32
	for axle in wheel_z:
		var dz: float=absf(z-axle)
		var r:=tire_radius+.052
		if dz<r: bottom=maxf(bottom,tire_radius+sqrt(r*r-dz*dz))
	var shoulder:=h-.07
	var low: float=minf(bottom,shoulder-.015)
	# Multiple side creases and bonnet crown give highlights real geometry.
	var points: Array=[Vector3(-w*.91,low,z),Vector3(-w*.98,lerpf(low,shoulder,.22),z),Vector3(-w,lerpf(low,shoulder,.63),z),Vector3(-w*.99,shoulder,z),Vector3(-w*.93,h-.015,z),Vector3(-w*.77,h+.025,z),Vector3(-w*.42,h+.05,z),Vector3(0,h+.065,z),Vector3(w*.42,h+.05,z),Vector3(w*.77,h+.025,z),Vector3(w*.93,h-.015,z),Vector3(w*.99,shoulder,z),Vector3(w,lerpf(low,shoulder,.63),z),Vector3(w*.98,lerpf(low,shoulder,.22),z),Vector3(w*.91,low,z)]
	for i in points.size():
		points[i].z-=signf(z)*.24*smoothstep(1.55,2.20,absf(z))*pow(absf(points[i].x)/w,4)
	return points

func build_end_cap(z: float) -> void:
	var outline:=body_section(z)
	var center:=Vector3(0,top_height(z)*.62,z)
	for i in outline.size():
		facing([center,outline[i],outline[(i+1)%outline.size()]],"paint",Vector3(0,0,signf(z)))

func build_body() -> void:
	var rear_base:=1.79 if suv else (1.44 if taxi else 1.35)
	var zs: Array[float]=[-1.13,rear_base]
	for i in 64: zs.append(lerpf(-2.20,2.15,i/63.0))
	for axle in wheel_z:
		for i in 25: zs.append(axle+(tire_radius+.052)*cos(PI*i/24))
	zs.sort()
	for i in range(zs.size()-1):
		var a:=body_section(zs[i])
		var b:=body_section(zs[i+1])
		for j in range(a.size()-1):
			# The bonnet/boot surface must not continue through the passenger cabin.
			# Keep the outer door shoulders; the cabin builder closes their sills.
			if zs[i]>=-1.13 and zs[i+1]<=rear_base and j>=4 and j<=9: continue
			panel([a[j],a[j+1],b[j+1],b[j]],"paint")
	build_end_cap(-2.2)
	build_end_cap(2.15)
	part(Vector3(0,.27,0),Vector3(1.42,.10,3.75),"black")
	for side in [-1,1]:
		# Continuous arch mouldings with an inner dark wheel well.
		for axle in wheel_z:
			for j in 32:
				var a:=PI*j/32
				var b:=PI*(j+1)/32
				var r:=tire_radius+.055
				var z0: float=axle+cos(a)*r
				var z1: float=axle+cos(b)*r
				var p:=Vector3(side*(body_width(z0)+.010),tire_radius+sin(a)*r,z0)
				var q:=Vector3(side*(body_width(z1)+.010),tire_radius+sin(b)*r,z1)
				rod(p,q,.026 if suv else .014,"rubber" if suv else "paint")
				panel([p,q,q+Vector3(-side*.14,0,0),p+Vector3(-side*.14,0,0)],"black")
		# Rocker panel with its own raised outer edge.
		rounded(Vector3(side*(half_width-.025),.32 if not suv else .38,0),Vector3(.12,.13,1.65),.045,"rubber" if suv else "paint")
		rod(Vector3(side*(half_width+.006),.40,-.78),Vector3(side*(half_width+.006),.40,.78),.008,"chrome" if suv else "paint")

# Curved roof, pitched windscreen and four individually framed side windows.
func roof_y(x: float,z: float) -> float:
	var t:=inverse_lerp(roof_front,roof_rear,z)
	return roof_height+(.095 if taxi else .045)*(1-pow(x/cabin_width,2))-.045*pow(absf(t-.5)*2,3)

func build_cabin() -> void:
	var key:="taxi" if taxi else "paint"
	for ix in 16:
		for iz in 12:
			var x0:=lerpf(-cabin_width,cabin_width,ix/16.0)
			var x1:=lerpf(-cabin_width,cabin_width,(ix+1)/16.0)
			var z0:=lerpf(roof_front,roof_rear,iz/12.0)
			var z1:=lerpf(roof_front,roof_rear,(iz+1)/12.0)
			panel([Vector3(x0,roof_y(x0,z0),z0),Vector3(x1,roof_y(x1,z0),z0),Vector3(x1,roof_y(x1,z1),z1),Vector3(x0,roof_y(x0,z1),z1)],key)
	var rear_base:=1.79 if suv else (1.44 if taxi else 1.35)
	# Subdivided gently convex windshield instead of one opaque slab.
	for back in [false,true]:
		var bottom_z: float=rear_base if back else -1.13
		var top_z: float=roof_rear if back else roof_front
		var bottom_w:=half_width*.86
		for i in 20:
			var u:=i/20.0
			var v:=(i+1)/20.0
			var pts: Array=[]
			for pair in [Vector2(u,0),Vector2(v,0),Vector2(v,1),Vector2(u,1)]:
				var x:=lerpf(-1,1,pair.x)
				var t: float=pair.y
				var w:=lerpf(bottom_w,cabin_width-.052,t)
				var y:=lerpf(belt+.035,roof_height-.055,t)
				var z:=lerpf(bottom_z,top_z,t)+(1-x*x)*(.055 if back else -.065)
				pts.append(Vector3(x*w,y,z))
			if back: pts.reverse()
			panel(pts,"glass")
			# Join the curved roof edge to the recessed glass, closing the old gap.
			var rim: Array=[]
			for t in [u,v]:
				var x:=lerpf(-1,1,t)
				rim.append(Vector3(x*cabin_width,roof_y(x*cabin_width,top_z),top_z))
			for t in [v,u]:
				var x:=lerpf(-1,1,t)
				rim.append(Vector3(x*(cabin_width-.052),roof_height-.055,top_z+(1-x*x)*(.055 if back else -.065)))
			facing(rim,key,Vector3(0,1,1 if back else -1))
		rod(Vector3(-bottom_w,belt+.03,bottom_z),Vector3(bottom_w,belt+.03,bottom_z),.018,"black")
	for side in [-1,1]:
		var low: float=side*half_width*.88
		var high: float=side*cabin_width
		# Broad painted A/C pillars close the body without sticking out as tubes.
		panel([Vector3(low,belt,-1.15),Vector3(high,roof_height-.04,roof_front-.015),Vector3(high-side*.075,roof_height-.04,roof_front+.08),Vector3(low-side*.05,belt,-1.04)],key)
		panel([Vector3(high,roof_height-.04,roof_rear-.04),Vector3(low,belt,rear_base+.08),Vector3(low,belt,rear_base-.18),Vector3(high,roof_height-.04,roof_rear-.19)],key)
		var front_window:=[Vector3(low,belt+.035,-.99),Vector3(high,roof_height-.075,roof_front+.09),Vector3(high,roof_height-.045,.12),Vector3(low,belt+.035,.12)]
		var rear_window:=[Vector3(low,belt+.035,.23),Vector3(high,roof_height-.045,.23),Vector3(high,roof_height-.075,roof_rear-.19),Vector3(low,belt+.035,rear_base-.23)]
		for window in [front_window,rear_window]:
			panel(window if side>0 else [window[3],window[2],window[1],window[0]],"glass")
			for i in 4: rod(window[i],window[(i+1)%4],.012,"black")
		panel([Vector3(low,belt,.12),Vector3(high,roof_height-.03,.12),Vector3(high,roof_height-.03,.23),Vector3(low,belt,.23)],"black")
		rod(Vector3(low,belt+.015,-1.03),Vector3(low,belt+.015,rear_base-.08),.010,"chrome")
		rod(Vector3(high,roof_height-.025,roof_front),Vector3(high,roof_height-.025,roof_rear),.014,key)
		# Body shoulder joins the inset glass to the full-width doors.
		panel([Vector3(side*half_width*.94,belt-.015,-1.1),Vector3(low,belt+.025,-1.1),Vector3(low,belt+.025,rear_base),Vector3(side*body_width(rear_base)*.94,top_height(rear_base)-.015,rear_base)],key if taxi else "paint")
		if suv:
			rod(Vector3(side*.61,roof_height+.075,roof_front+.06),Vector3(side*.61,roof_height+.075,roof_rear-.03),.026,"chrome")
			for z in [roof_front+.13,roof_rear-.1]: rounded(Vector3(side*.61,roof_height+.025,z),Vector3(.075,.09,.20),.025,"black")
	if suv:
		rounded(Vector3(0,roof_height-.02,1.14),Vector3(1.48,.075,.27),.035,"paint")
	# Wipers follow the windshield angle.
	for side in [-1,1]: rod(Vector3(side*.15,belt+.06,-1.16),Vector3(side*.52,belt+.13,-1.06),.008,"black")

func build_interior() -> void:
	part(Vector3(0,.52,.25),Vector3(1.45,.10,2.10),"interior")
	rounded(Vector3(0,belt-.10,-.83),Vector3(1.47,.21,.38),.07,"interior")
	for x in [-.39,.39]:
		for z in [.02,.55]:
			rounded(Vector3(x,.65,z),Vector3(.53,.15,.49),.055,"seat")
			rounded(Vector3(x,.91,z+.22),Vector3(.51,.56,.16),.065,"seat",Vector3(-.12,0,0))
			rounded(Vector3(x,1.18,z+.25),Vector3(.27,.20,.12),.055,"seat")
	# Right-hand-drive steering ring and console, visible through actual glass.
	var center:=Vector3(.40,belt-.02,-.59)
	for i in 24:
		var a:=i*TAU/24
		var b:=(i+1)*TAU/24
		rod(center+Vector3(cos(a)*.16,sin(a)*.14,sin(a)*.065),center+Vector3(cos(b)*.16,sin(b)*.14,sin(b)*.065),.015,"black")
	for a in [0.0,PI,PI*1.5]: rod(center,center+Vector3(cos(a)*.14,sin(a)*.12,sin(a)*.055),.018,"chrome")
	rounded(Vector3(0,.70,-.15),Vector3(.20,.18,.70),.04,"interior")
	rod(Vector3(0,.76,-.22),Vector3(0,.87,-.23),.02,"black")

func front_panel(points: Array,key: String) -> void:
	facing(points,key,Vector3.FORWARD)

func build_front() -> void:
	# Recessed lower intake and shaped bumper cheeks follow the body nose.
	rounded(Vector3(0,.36,-2.16),Vector3(1.53,.16,.14),.06,"paint")
	rounded(Vector3(0,.375,-2.248),Vector3(.88,.10,.018),.04,"black")
	var plate_key:="taxi" if taxi else "plate"
	rounded(Vector3(0,.48,-2.247),Vector3(.48,.115,.018),.014,plate_key)
	if taxi:
		# Round classic lamps, separate pontoon fenders, oval chrome radiator.
		orb(Vector3(0,.78,-2.17),Vector3(.99,.61,.22),"chrome")
		orb(Vector3(0,.78,-2.235),Vector3(.90,.50,.10),"black")
		for i in 6:
			var y:=.59+i*.066
			var w:=.41*sqrt(maxf(0,1-pow((y-.78)/.25,2)))
			rod(Vector3(-w,y,-2.294),Vector3(w,y,-2.294),.009,"chrome")
		rod(Vector3(0,.55,-2.30),Vector3(0,1.0,-2.30),.014,"chrome")
		for side in [-1,1]:
			orb(Vector3(side*.66,.84,-1.83),Vector3(.43,.45,.84),"paint")
			orb(Vector3(side*.65,.88,-2.14),Vector3(.33,.33,.16),"chrome")
			orb(Vector3(side*.65,.88,-2.224),Vector3(.265,.265,.045),"lamp")
			orb(Vector3(side*.65,.62,-2.195),Vector3(.105,.08,.035),"taxi")
			rod(Vector3(side*.28,.43,-2.29),Vector3(side*.80,.43,-2.19),.045,"chrome")
			rounded(Vector3(side*.54,.45,-2.26),Vector3(.08,.18,.09),.025,"chrome")
		rod(Vector3(0,1.06,-1.64),Vector3(0,1.11,-1.02),.008,"chrome")
	else:
		var top:=1.02 if suv else .85
		var bottom:=.61 if suv else .67
		var corners:=[Vector3(-.49,top,-2.224),Vector3(.49,top,-2.224),Vector3(.41,bottom,-2.255),Vector3(-.41,bottom,-2.255)]
		front_panel(corners,"black")
		for i in 4: rod(corners[i],corners[(i+1)%4],.016,"chrome")
		for i in (5 if suv else 3):
			var y:=lerpf(bottom+.035,top-.035,float(i)/(4 if suv else 2))
			rod(Vector3(-.43,y,-2.26),Vector3(.43,y,-2.26),.008,"chrome")
		orb(Vector3(0,(top+bottom)*.5,-2.28),Vector3(.10,.065,.025),"chrome")
		for side in [-1,1]:
			var h:=1.0 if suv else .86
			var points:=[Vector3(side*.49,h,-2.245),Vector3(side*.76,h+.02,-2.15),Vector3(side*.82,h-.035,-2.005),Vector3(side*.74,h-.13,-2.16),Vector3(side*.51,h-.12,-2.25)]
			front_panel(points,"black")
			for i in 5: rod(points[i],points[(i+1)%5],.009,"chrome")
			for t in [.38,.70]:
				orb(Vector3(side*lerpf(.50,.79,t),h-.025,lerpf(-2.26,-2.15,t)-.022),Vector3(.09,.063,.045),"lamp")
			var lens: Array=[]
			for point in points: lens.append(point+Vector3(0,0,-.018))
			front_panel(lens,"lens")
			rod(points[0]+Vector3(0,-.017,-.01),points[1]+Vector3(0,-.017,-.01),.012,"lamp")
			rod(points[1]+Vector3(0,-.017,-.01),points[2]+Vector3(0,-.014,-.01),.012,"lamp")
			# Deep black fog pockets / SUV vertical running-light blade.
			var fog:=[Vector3(side*.55,.56,-2.245),Vector3(side*.76,.59,-2.18),Vector3(side*.79,.35,-2.14),Vector3(side*.60,.37,-2.25)]
			front_panel(fog,"black")
			for i in 4: rod(fog[i],fog[(i+1)%4],.012,"paint")
			rod(Vector3(side*.63,.42,-2.259),Vector3(side*.74,.44,-2.21),.012,"lamp")
			if suv: rod(Vector3(side*.77,.74,-2.14),Vector3(side*.76,.53,-2.18),.018,"lamp")
		# Quiet bonnet crease lines; no chrome bars across the hood.
		for side in [-1,1]:
			for i in 18:
				var z0:=lerpf(-1.98,-1.12,i/18.0)
				var z1:=lerpf(-1.98,-1.12,(i+1)/18.0)
				rod(Vector3(side*.51,top_height(z0)+.047,z0),Vector3(side*.51,top_height(z1)+.047,z1),.005,"paint")
	if suv: rounded(Vector3(0,.32,-2.19),Vector3(1.12,.09,.14),.03,"chrome")

func rear_lens_z(x: float) -> float:
	return 2.15-.24*smoothstep(1.55,2.20,2.15)*pow(absf(x)/body_width(2.15),4)+.019

func build_rear() -> void:
	rounded(Vector3(0,.36,2.09),Vector3(1.55,.16,.16),.055,"paint")
	rounded(Vector3(0,.30,2.11),Vector3(1.28,.10,.12),.035,"black")
	rounded(Vector3(0,.65,2.167),Vector3(.48,.115,.018),.015,"taxi" if taxi else "plate")
	for side in [-1,1]:
		var y:=.89 if suv else .83
		# Subdivided lenses follow the rounded tail, so their centre cannot sink
		# into the body as a single flat polygon would.
		for i in 16:
			var x0: float=side*lerpf(.38,.77,i/16.0)
			var x1: float=side*lerpf(.38,.77,(i+1)/16.0)
			var z0:=rear_lens_z(x0)
			var z1:=rear_lens_z(x1)
			facing([Vector3(x0,y+.055,z0),Vector3(x1,y+.055,z1),Vector3(x1,y-.085,z1),Vector3(x0,y-.085,z0)],"black",Vector3.BACK)
			for band in [.025,-.06]:
				facing([Vector3(x0,y+band+.010,z0+.006),Vector3(x1,y+band+.010,z1+.006),Vector3(x1,y+band-.010,z1+.006),Vector3(x0,y+band-.010,z0+.006)],"tail",Vector3.BACK)
			if i<8:
				facing([Vector3(x0,y-.018,z0+.007),Vector3(x1,y-.018,z1+.007),Vector3(x1,y-.027,z1+.007),Vector3(x0,y-.027,z0+.007)],"lamp",Vector3.BACK)
		for j in 8:
			var z0:=lerpf(1.85,2.025,j/8.0)
			var z1:=lerpf(1.85,2.025,(j+1)/8.0)
			var x0: float=side*(body_width(z0)+.008)
			var x1: float=side*(body_width(z1)+.008)
			facing([Vector3(x0,y+.04,z0),Vector3(x1,y+.04,z1),Vector3(x1,y-.065,z1),Vector3(x0,y-.065,z0)],"tail",Vector3(side,0,0))
		rod(Vector3(side*.53,.28,2.11),Vector3(side*.53,.28,2.25),.044,"chrome")
		orb(Vector3(side*.53,.28,2.254),Vector3(.065,.065,.009),"black")
		part(Vector3(side*.67,.42,2.16),Vector3(.19,.022,.015),"tail")
	if suv:
		rod(Vector3(-.43,.96,2.12),Vector3(.43,.96,2.12),.012,"tail")
		rod(Vector3(0,1.19,1.80),Vector3(.32,1.24,1.72),.009,"black")
	else:
		rod(Vector3(-.62,.98,1.66),Vector3(.62,.98,1.66),.008,"paint")

func build_details() -> void:
	for side in [-1,1]:
		# Door shut lines bend inwards with the sill and match the body width.
		for z in [-.85,.18,.98]:
			var x: float=side*(body_width(z)+.002)
			var path:=[Vector3(x*.98,.36,z),Vector3(x,.59,z-.025),Vector3(x,.83,z),Vector3(x*.96,belt-.04,z+.015)]
			for i in 3: rod(path[i],path[i+1],.004,"black")
		for z in [-.02,.80]:
			rounded(Vector3(side*(half_width*.987),belt-.14,z),Vector3(.035,.045,.18),.015,"black")
			rounded(Vector3(side*(half_width+.008),belt-.125,z),Vector3(.035,.026,.15),.009,"chrome" if taxi else "paint")
		# Two-tone mirror on a short black stalk; rear face is reflective glass.
		rod(Vector3(side*.79,belt+.05,-.91),Vector3(side*1.0,belt+.10,-.86),.026,"black")
		orb(Vector3(side*1.02,belt+.13,-.86),Vector3(.25,.13,.24),"paint")
		orb(Vector3(side*1.025,belt+.10,-.86),Vector3(.25,.055,.235),"black")
		orb(Vector3(side*1.025,belt+.13,-.741),Vector3(.18,.084,.012),"chrome")
		rod(Vector3(side*.98,belt+.12,-.983),Vector3(side*1.09,belt+.12,-.96),.007,"lamp")
		if style in ["police","ambulance"]:
			var x: float=side*(half_width+.012)
			panel([Vector3(x,.68,-.83),Vector3(x,.68,.96),Vector3(x,.96,.96),Vector3(x,.91,-.83)],"blue" if style=="police" else "tail")
			rod(Vector3(x+side*.004,.97,.96),Vector3(x+side*.004,.92,-.83),.013,"tail")
		if taxi:
			# Heritage skyline graphic built into the lower doors.
			for i in 11:
				var z: float=-.65+i*.13
				var h: float=.12+(.10 if i%3==0 else .03)
				part(Vector3(side*(half_width+.008),.50+h*.5,z),Vector3(.012,h,.09),"taxi")
				orb(Vector3(side*(half_width+.008),.50+h,z),Vector3(.014,.08,.09),"taxi")
			rod(Vector3(side*(half_width+.012),.49,-.72),Vector3(side*(half_width+.012),.49,.79),.009,"taxi")
	# Fuel flap and antenna.
	for i in 24:
		var a:=i*TAU/24
		var b:=(i+1)*TAU/24
		rod(Vector3(half_width*.988,.87+sin(a)*.065,1.05+cos(a)*.065),Vector3(half_width*.988,.87+sin(b)*.065,1.05+cos(b)*.065),.0035,"black")
	orb(Vector3(0,roof_height+.055,roof_rear-.12),Vector3(.06,.10,.18),"black")
	if taxi:
		rounded(Vector3(0,roof_height+.13,.06),Vector3(.49,.20,.28),.035,"taxi")
	elif style in ["police","ambulance"]:
		rounded(Vector3(0,roof_height+.065,.12),Vector3(1.0,.05,.24),.025,"black")
		for side in [-1,1]:
			rounded(Vector3(side*.27,roof_height+.14,.12),Vector3(.44,.11,.22),.04,"tail" if side<0 else "blue")
			for x in 4: part(Vector3(side*(.10+x*.09),roof_height+.145,-.002),Vector3(.042,.035,.01),"lamp")

func build_wheels() -> void:
	for side in [-1,1]:
		for z in wheel_z:
			var wheel:=Node3D.new()
			wheel.position=Vector3(side*wheel_x,tire_radius,z)
			add_child(wheel)
			wheels.append(wheel)
			# Revolved tyre profile makes full-width rubber, shoulder and sidewall.
			var profile: Array=[Vector2(-.115,tire_radius-.105),Vector2(-.12,tire_radius-.045),Vector2(-.087,tire_radius-.009),Vector2(-.063,tire_radius),Vector2(.063,tire_radius),Vector2(.087,tire_radius-.009),Vector2(.12,tire_radius-.045),Vector2(.115,tire_radius-.105)]
			for i in 48:
				var a:=i*TAU/48
				var b:=(i+1)*TAU/48
				for j in range(profile.size()-1):
					var p: Vector2=profile[j]
					var q: Vector2=profile[j+1]
					panel([Vector3(p.x,sin(b)*p.y,cos(b)*p.y),Vector3(q.x,sin(b)*q.y,cos(b)*q.y),Vector3(q.x,sin(a)*q.y,cos(a)*q.y),Vector3(p.x,sin(a)*p.y,cos(a)*p.y)],"rubber")
			var rim_radius:=tire_radius-.072
			var disc:=CylinderMesh.new()
			disc.top_radius=rim_radius*.69
			disc.bottom_radius=disc.top_radius
			disc.height=.025
			disc.radial_segments=32
			disc.rings=1
			append_mesh(disc,Transform3D(Basis(Vector3.FORWARD,PI/2),Vector3(side*.07,0,0)),"alloy")
			for radius in [rim_radius,rim_radius-.022]:
				for i in 40:
					var a:=i*TAU/40
					var b:=(i+1)*TAU/40
					rod(Vector3(side*.116,sin(a)*radius,cos(a)*radius),Vector3(side*.116,sin(b)*radius,cos(b)*radius),.009,"chrome")
			for spoke in (8 if taxi else 5):
				var angle:=spoke*TAU/(8 if taxi else 5)
				for split in [-1,1]:
					var a: float=angle+split*.065
					var b: float=angle+split*.13+.12
					var p:=Vector3(side*.12,sin(a)*.058,cos(a)*.058)
					var q:=Vector3(side*.115,sin(b)*(rim_radius-.015),cos(b)*(rim_radius-.015))
					var d:=Vector3(0,cos(b),-sin(b))*.015
					panel([p-d,q-d,q+d,p+d],"chrome")
					panel([p+d,q+d,q+d-Vector3(side*.025,0,0),p+d-Vector3(side*.025,0,0)],"alloy")
			orb(Vector3(side*.127,0,0),Vector3(.035,.115,.115),"chrome")
			orb(Vector3(side*.148,0,0),Vector3(.008,.055,.055),"black")
			for stud in 5:
				var a:=stud*TAU/5
				orb(Vector3(side*.145,sin(a)*.043,cos(a)*.043),Vector3(.012,.014,.014),"chrome")
			# Fine shoulder tread cuts remain legible at close range.
			for i in 40:
				var a:=i*TAU/40
				for s in [-1,1]:
					rod(Vector3(s*.045,sin(a)*(tire_radius+.001),cos(a)*(tire_radius+.001)),Vector3(s*.082,sin(a+.025)*(tire_radius-.005),cos(a+.025)*(tire_radius-.005)),.003,"black")
			flush(wheel)

func badge(at: Vector3,value: String,height: float,yaw: float,color: Color) -> void:
	var label:=Label3D.new()
	label.text=value
	label.font_size=48
	label.pixel_size=height/48
	label.modulate=color
	label.outline_size=0
	label.position=at
	label.rotation.y=yaw
	label.visibility_range_end=28
	add_child(label)

func flush(parent: Node3D) -> void:
	var combined:=ArrayMesh.new()
	for key in surfaces:
		var st: SurfaceTool=surfaces[key]
		st.generate_normals()
		st.index()
		st.set_material(materials[key])
		st.commit(combined)
	attach_mesh(parent,combined)
	surfaces.clear()

func attach_mesh(parent: Node3D,resource: ArrayMesh) -> void:
	var mesh:=MeshInstance3D.new()
	mesh.mesh=resource
	mesh.visibility_range_end=230
	parent.add_child(mesh)

func animate_wheels(distance: float,turn: float) -> void:
	steering=lerpf(steering,turn*-.38,.18)
	for i in wheels.size():
		var wheel: Node3D=wheels[i]
		wheel.rotation.y=steering if i%2==0 else 0.0
		wheel.get_child(0).rotate_x(-distance/tire_radius)
