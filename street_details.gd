extends RefCounted
## Finite, nearby detail pass: no per-frame generation or downloaded photographs.
var world: Node3D
var base:=Vector3.ZERO
var rotation_y:=0.0
var frame:=Basis.IDENTITY
func box(at: Vector3, dimensions: Vector3, material: String, solid:=false) -> void:
	world.box(base+frame*at,dimensions,material,solid,Vector3(0,rotation_y,0))
func build(b: Dictionary, yaw: float, index: int) -> void:
	base=Vector3(b.x,world.terrain_height(b.x,b.z),b.z)
	rotation_y=yaw
	frame=Basis(Vector3.UP,yaw)
	var front: float=b.d/2
	var side: float=-1 if index%2 else 1
	# AC housing, vent fins, drainpipe and utility meter: common Jaipur shop details.
	box(Vector3(side*(b.w/2-.65),3.85,front+.28),Vector3(.95,.62,.50),"concrete")
	for i in 7:
		box(Vector3(side*(b.w/2-.65),3.62+i*.067,front+.54),Vector3(.76,.022,.025),"metal")
	box(Vector3(-side*(b.w/2-.16),2.5,front+.15),Vector3(.065,5,.065),"grey")
	box(Vector3(-side*(b.w/2-.48),1.6,front+.15),Vector3(.32,.46,.18),"metal")
	box(Vector3(0,.20,front+.025),Vector3(b.w,.25,.05),"grey")
	# Narrow awning with a scalloped valance; leave the central doorway clear.
	for stripe in 20:
		var x: float=-b.w/2+(stripe+.5)*b.w/20
		box(Vector3(x,3.38,front+.72),Vector3(b.w/20,.055,1.4),"cream" if stripe%2 else ("teal" if index%2 else "maroon"))
		box(Vector3(x,3.25,front+1.4),Vector3(b.w/20,.24,.045),"cream" if stripe%2 else ("teal" if index%2 else "maroon"))
	# Drain grates stay flush with the pavement, away from the entry threshold.
	for i in 9:
		box(Vector3(side*b.w*.34,.08,front+1.6+i*.055),Vector3(.55,.025,.025),"metal")
	# A parked scooter beside the shop, outside the walkable doorway.
	var scooter:=preload("res://scooter_design.gd").new()
	scooter.paint=Color(["d5cec0","648a91","9c4f43","d2bb8c"][index%4])
	var parking:=Vector3(side*(b.w/2+1),.08,front-.1)
	scooter.position=base+frame*parking
	scooter.rotation.y=yaw+.35*side
	world.cell(base).add_child(scooter)
	var collider:=CollisionShape3D.new()
	var shape:=BoxShape3D.new()
	shape.size=Vector3(.6,1.2,1.6)
	collider.shape=shape
	collider.position=scooter.position+Vector3(0,.62,0)
	collider.rotation.y=scooter.rotation.y
	world.cell(base).get_node("Collision").add_child(collider)
	# Recessed goods and a bin add recognizable human scale without cluttering roads.
	box(Vector3(-side*(b.w/2+.65),.42,front-.4),Vector3(.55,.84,.55),"bin_green",true)
	box(Vector3(-side*(b.w/2+.65),.87,front-.4),Vector3(.6,.08,.6),"metal")
