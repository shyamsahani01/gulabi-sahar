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
func label(at: Vector3,value: String,height: float,material := "arch_white",max_width := 0.0,script := false) -> void:
	var mesh:=TextMesh.new()
	mesh.font=load("res://assets/fonts/Z003-MediumItalic.otf") if script else load("res://assets/fonts/DejaVuSans-Bold.ttf")
	mesh.font_size=64
	mesh.pixel_size=height/64
	mesh.depth=.018 if script else .045
	mesh.text=value
	var node:=MeshInstance3D.new()
	node.mesh=mesh
	node.material_override=world.mats[material]
	node.transform=Transform3D(basis,origin+basis*at)
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
func light(at: Vector3,energy: float,radius: float) -> void:
	var lamp:=OmniLight3D.new()
	lamp.position=origin+basis*at
	lamp.light_color=Color("ffe5bb")
	lamp.light_energy=energy
	lamp.omni_range=radius
	lamp.shadow_enabled=false
	lamp.distance_fade_enabled=true
	lamp.distance_fade_begin=24
	lamp.distance_fade_length=10
	world.cell(origin).add_child(lamp)
