extends RefCounted
## Shared local-space construction; custom primitives join the city's instanced batches.
var world: Node3D
var origin: Vector3
var basis := Basis.IDENTITY
var w: float
var d: float
var detail := false
func setup(a: Dictionary) -> void:
	origin=Vector3(a.p[0],world.terrain_height(a.p[0],a.p[1]),a.p[1])
	basis=Basis(Vector3.UP,a.a+(PI if a.get("front",1)<0 else 0))
	w=a.w
	d=a.d
func yaw() -> float:
	return atan2(basis.z.x,basis.z.z)
func box(at: Vector3, size: Vector3, material: String, solid := false, local_basis := Basis.IDENTITY) -> void:
	world.draw_detail=detail
	world.box(origin+basis*at,size,material,solid,(basis*local_basis).get_euler())
func shape(at: Vector3, size: Vector3, material: String, primitive := "cylinder", rotation := Basis.IDENTITY) -> void:
	var position: Vector3=origin+basis*at
	var id: Vector2i=world.cell_key(position)
	var key: String="%d,%d|%s|%d|%s"%[id.x,id.y,material,int(detail),primitive]
	if not world.batches.has(key):
		world.batches[key]=[]
	world.batches[key].append(Transform3D(basis*rotation*Basis.from_scale(size),position))
func rod(a: Vector3,b: Vector3,radius: float,material: String) -> void:
	var direction:=b-a
	if direction.length()<.001:
		return
	shape((a+b)/2,Vector3(radius*2,direction.length(),radius*2),material,"cylinder",Basis(Quaternion(Vector3.UP,direction.normalized())))
func label(at: Vector3,value: String,height: float,material := "arch_white",max_width := 0.0,script := false,turn := 0.0) -> void:
	# `turn` rotates the text about its own vertical axis: +PI/2 faces local +X (a left wall), -PI/2 faces -X.
	var mesh:=TextMesh.new()
	mesh.font=load("res://assets/fonts/Z003-MediumItalic.otf") if script else load("res://assets/fonts/DejaVuSans-Bold.ttf")
	mesh.font_size=64
	mesh.pixel_size=height/64
	mesh.depth=.018 if script else .045
	mesh.text=value
	var node:=MeshInstance3D.new()
	node.mesh=mesh
	node.material_override=world.mats[material]
	node.transform=Transform3D(basis*Basis(Vector3.UP,turn),origin+basis*at)
	var bounds:=mesh.get_aabb()
	if max_width>0 and bounds.size.x>max_width:
		node.scale.x*=max_width/bounds.size.x
	node.visibility_range_end=100
	world.cell(origin).add_child(node)
func pot(at: Vector3,scale_factor := 1.0) -> void:
	shape(at+Vector3(0,.2,0)*scale_factor,Vector3(.39,.4,.39)*scale_factor,"arch_white","pot")
	shape(at+Vector3(0,.405,0)*scale_factor,Vector3(.37,.025,.37)*scale_factor,"arch_soil")
	shape(at+Vector3(0,.38,0)*scale_factor,Vector3(.43,.055,.43)*scale_factor,"arch_white")
	for i in 7:
		var angle:=i*TAU/7
		var tip:=Vector3(sin(angle)*.25,.8+(i%3)*.14,cos(angle)*.25)*scale_factor
		rod(at+Vector3(0,.4,0)*scale_factor,at+tip,.009*scale_factor,"arch_leaf_dark")
		shape(at+tip,Vector3(.12,.34,.06)*scale_factor,"arch_leaf" if i%2 else "arch_leaf_dark","sphere",Basis.from_euler(Vector3(.4,angle,.5)))
func palm(at: Vector3,scale_factor := 1.0) -> void:
	# Indoor areca palm in a white pot: fanned fronds instead of the small pot shrub.
	shape(at+Vector3(0,.22,0)*scale_factor,Vector3(.42,.44,.42)*scale_factor,"arch_white","pot")
	shape(at+Vector3(0,.44,0)*scale_factor,Vector3(.38,.03,.38)*scale_factor,"arch_soil")
	for i in 9:
		var angle:=i*TAU/9+.3
		var reach:=(.55+(i%3)*.12)*scale_factor
		var top:=at+Vector3(sin(angle)*reach*.55,(1.25+(i%2)*.25)*scale_factor,cos(angle)*reach*.55)
		rod(at+Vector3(0,.44,0)*scale_factor,top,.008*scale_factor,"arch_leaf_dark")
		var tip:=top+Vector3(sin(angle)*reach*.6,-.18*scale_factor,cos(angle)*reach*.6)
		shape((top+tip)/2,Vector3(.07,(top-tip).length()*1.1,.22)*scale_factor,"arch_leaf" if i%2 else "arch_leaf_dark","sphere",Basis(Quaternion(Vector3.UP,(tip-top).normalized())))
func spot(at: Vector3,radius := .09) -> void:
	# Recessed ceiling downlight: dark trim ring and a bright warm disc.
	shape(at,Vector3(radius*2.6,.012,radius*2.6),"arch_black")
	shape(at+Vector3(0,-.009,0),Vector3(radius*2,.012,radius*2),"arch_neon")
func cup_logo(at: Vector3,s: float,material := "arch_white") -> void:
	# The cafe mark: a cup on a saucer with two bars and three steam wisps, in the local XY plane.
	shape(at,Vector3(.36,.30,.36)*s,material,"pot")
	shape(at+Vector3(0,-.17,0)*s,Vector3(.62,.035,.62)*s,material)
	for piece in [[Vector3(.27,.0,0),Vector3(.05,.2,.05)],[Vector3(.22,.1,0),Vector3(.14,.045,.05)],[Vector3(.22,-.1,0),Vector3(.14,.045,.05)]]:
		box(at+piece[0]*s,piece[1]*s,material)
	for side in [-1,1]:
		box(at+Vector3(side*.95,-.02,0)*s,Vector3(.75,.05,.05)*s,material)
	for i in 3:
		var x: float=(-.1+i*.1)*s
		rod(at+Vector3(x,.2,0)*s,at+Vector3(x+.05*s*(1 if i%2 else -1),.52,0)*s,.013*s,material)
func seat(at: Vector3,facing: float,height: float,npc := false,pose := "Sit") -> void:
	# Registers a usable seat: feet position on the floor, forward yaw and seat height.
	var entry: Dictionary={"p":origin+basis*at,"yaw":yaw()+facing,"h":height,"pose":pose}
	if npc:
		world.patron_spots.append(entry)
	else:
		world.seats.append(entry)
func collision_ramp(center: float,front: float,width: float,length: float,height: float) -> void:
	# Sloped collision over visible risers lets the character walk up without jumping.
	var points:=PackedVector3Array()
	for x in [center-width/2,center+width/2]:
		for yz in [Vector2(0,front-.15),Vector2(height,front-.15),Vector2(0,front+length)]:
			points.append(Vector3(x,yz.x,yz.y))
	var collider:=CollisionShape3D.new()
	var ramp:=ConvexPolygonShape3D.new()
	ramp.points=points
	collider.shape=ramp
	collider.transform=Transform3D(basis,origin)
	world.cell(origin).get_node("Collision").add_child(collider)
func light(at: Vector3,energy: float,radius: float,color := Color("ffe5bb")) -> void:
	var lamp:=OmniLight3D.new()
	lamp.position=origin+basis*at
	lamp.light_color=color
	lamp.light_energy=energy
	lamp.omni_range=radius
	lamp.shadow_enabled=false
	lamp.distance_fade_enabled=true
	lamp.distance_fade_begin=24
	lamp.distance_fade_length=10
	world.cell(origin).add_child(lamp)
