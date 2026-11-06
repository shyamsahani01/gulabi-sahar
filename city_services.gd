extends RefCounted
## Authored neighborhood businesses, placed in existing infill footprints.
## These are fictional game locations, not claims about real OSM businesses.
const SPECS := [
	{"kind":"showroom","name":"Gulabi Motors","hindi":"गुलाबी मोटर्स","color":"teal","at":Vector2(42.12,-13.63)},
	{"kind":"hospital","name":"Sahar Hospital","hindi":"सहर अस्पताल","color":"teal","at":Vector2(70.04,-15.14)},
	{"kind":"police","name":"City Police","hindi":"नगर पुलिस थाना","color":"blue","at":Vector2(75.2,-37.11)},
	{"kind":"theka","name":"Theka","hindi":"ठेका · मदिरा दुकान","color":"maroon","at":Vector2(8.37,-55.57)},
	{"kind":"grocery","name":"Sharma Kirana","hindi":"शर्मा किराना स्टोर","color":"green","at":Vector2(-37.43,-74.44)},
	{"kind":"chai","name":"Gulabi Chai","hindi":"गुलाबी चाय घर","color":"saffron","at":Vector2(-86.82,-51.89)}
]
var world: Node3D
var base := Vector3.ZERO
var facing := Basis.IDENTITY
var width := 8.0
var depth := 8.0

func assign(data: Dictionary, compression: float) -> void:
	for spec in SPECS:
		var best: Dictionary = {}
		var distance := INF
		for b in data.buildings:
			if b.has("service"):
				continue
			var d := Vector2(b.x,b.z).distance_to(spec.at*compression)
			if d < distance:
				distance = d
				best = b
		best.service = spec.duplicate()

func box(at: Vector3, size: Vector3, key: String, solid := false) -> void:
	world.box(base+facing*at,size,key,solid,Vector3(0,atan2(facing.z.x,facing.z.z),0))

func label(at: Vector3, text: String, size := 35, color := Color("fff2d8")) -> void:
	var sign := Label3D.new()
	sign.font = world.hindi_font
	sign.text = text
	sign.font_size = size
	sign.pixel_size = .009
	sign.modulate = color
	sign.outline_size = 2
	sign.position = base+facing*at
	sign.rotation.y = atan2(facing.z.x,facing.z.z)
	sign.visibility_range_end = 100
	world.cell(base).add_child(sign)

func build(b: Dictionary) -> void:
	var spec: Dictionary = b.service
	base = Vector3(b.x,world.terrain_height(b.x,b.z),b.z)
	facing = Basis(Vector3.UP,b.a)
	width = b.w
	depth = b.d
	# Select the side facing the nearest mapped road segment.
	var closest := Vector3.ZERO
	var distance := INF
	var road_heading := 0.0
	for road in world.data.roads:
		for i in range(road.p.size()-1):
			var a := Vector2(road.p[i][0],road.p[i][1])
			var z := Vector2(road.p[i+1][0],road.p[i+1][1])
			var point := Geometry2D.get_closest_point_to_segment(Vector2(b.x,b.z),a,z)
			var d := point.distance_squared_to(Vector2(b.x,b.z))
			if d < distance:
				distance = d
				closest = Vector3(point.x,base.y,point.y)
				road_heading = atan2(-(z.x-a.x),-(z.y-a.y))
	if (closest-base).dot(facing.z)<0:
		facing = facing.rotated(Vector3.UP,PI)
	var front := depth/2
	var entrance := base+facing*Vector3(0,0,front+1.8)
	var destination: Dictionary = spec.duplicate()
	destination.p = [entrance.x,entrance.z]
	destination.building = b
	destination.rotation = atan2(facing.z.x,facing.z.z)
	destination.car_p = [closest.x,closest.z]
	destination.car_heading = road_heading
	world.services.append(destination)
	if spec.kind=="hospital":
		var hospital=preload("res://hospital_reference.gd").new()
		hospital.world=world
		hospital.build({"name":spec.name,"p":[base.x,base.z],"a":atan2(facing.z.x,facing.z.z),"w":width,"d":depth,"front":1})
		return
	var tint: String = spec.color
	var wall := "cream" if spec.kind in ["hospital","showroom"] else "rose"
	box(Vector3(0,.08,0),Vector3(width,.16,depth),"tile",true)
	for x in range(-int(width/2),int(width/2)+1):
		box(Vector3(x,.165,0),Vector3(.012,.005,depth-.2),"grout")
	for z in range(-int(depth/2),int(depth/2)+1):
		box(Vector3(0,.165,z),Vector3(width-.2,.005,.012),"grout")
	box(Vector3(0,1.6,-front+.12),Vector3(width,3.2,.24),wall,true)
	for side in [-1,1]:
		box(Vector3(side*(width/2-.12),1.6,0),Vector3(.24,3.2,depth),wall,true)
		box(Vector3(side*(width/2-.18),1.6,front),Vector3(.36,3.2,.45),"trim",true)
	box(Vector3(0,(b.h+3.2)/2,0),Vector3(width,b.h-3.2,depth),wall,true)
	box(Vector3(0,b.h+.15,0),Vector3(width+.4,.3,depth+.4),"trim")
	for side in [-1,1]:
		box(Vector3(side*(width/2-.10),b.h+.55,0),Vector3(.2,.8,depth),wall)
	for y in range(5,int(b.h),3):
		for x in [-width*.3,0.0,width*.3]:
			box(Vector3(x,y,front+.04),Vector3(1.2,1.7,.10),"glass")
			box(Vector3(x,y+1,front+.23),Vector3(1.55,.13,.62),"trim")
			box(Vector3(x,y-.9,front+.2),Vector3(1.55,.13,.5),"trim")
	box(Vector3(0,3.15,front+.48),Vector3(width+.55,.23,1.25),"trim")
	box(Vector3(0,2.64,front+.12),Vector3(width-.48,.75,.20),tint)
	label(Vector3(0,2.69,front+.24),spec.hindi,48)
	label(Vector3(0,2.35,front+.24),spec.name.to_upper(),24)
	# Glazed bays flank an accessible 2.2 m doorway.
	for side in [-1,1]:
		var bay := (width-2.8)/2
		box(Vector3(side*(1.1+bay/2),1.24,front),Vector3(bay,2.1,.045),"shop_glass",true)
		box(Vector3(side*1.13,1.26,front),Vector3(.075,2.35,.1),"metal")
	box(Vector3(0,.035,front+.7),Vector3(2.3,.07,1.4),"stone",true)

	match spec.kind:
		"showroom":
			for side in [-1,1]:
				box(Vector3(side*width*.25,.20,-.4),Vector3(2.8,.22,4.9),"white")
				car(Vector3(side*width*.25,.32,-.4),Color("bd5146") if side<0 else Color("6c9c9b"),"sedan",PI+.22*side)
			label(Vector3(0,1.8,-front+.3),"GULABI MOTORS\nDESIGNED FOR THE CITY",28)
		"hospital":
			box(Vector3(0,b.h+1,front-.2),Vector3(.38,1.7,.18),"teal")
			box(Vector3(0,b.h+1,front-.2),Vector3(1.25,.38,.18),"teal")
			box(Vector3(0,.65,-front+1.2),Vector3(width*.6,1.15,.75),"white",true)
			label(Vector3(0,1.6,-front+.28),"RECEPTION  /  24H CARE",25)
			label(Vector3(-width*.27,1.8,front+.1),"EMERGENCY",20,Color("a9e7db"))
			bench(Vector3(width*.32,.0,.0))
		"police":
			box(Vector3(0,.65,-front+1.2),Vector3(width*.55,1.1,.8),"wood",true)
			label(Vector3(0,1.85,-front+.3),"HELP DESK  /  POLICE",28)
			car(Vector3(-width*.26,.17,0),Color("e8e9df"),"police",PI)
			box(Vector3(width*.34,1.5,.1),Vector3(.045,3,.045),"chrome")
			for i in 3:
				box(Vector3(width*.34+.35,2.8-i*.2,.1),Vector3(.7,.2,.035),["saffron","white","green"][i])
		"theka", "grocery":
			for x in [-width*.3,width*.3]:
				for y in [.55,1.1,1.65]:
					box(Vector3(x,y,-front+.6),Vector3(width*.3,.08,.65),"wood")
					for i in 7:
						var at := Vector3(x-width*.12+i*width*.04,y+.2,-front+.6)
						box(at,Vector3(.19,.32,.18),"green" if spec.kind=="theka" else ["saffron","maroon","teal"][i%3])
						if spec.kind=="theka":
							box(at+Vector3(0,.2,0),Vector3(.08,.12,.08),"gold")
			box(Vector3(-width*.25,.65,front-1.2),Vector3(width*.36,1.1,.7),"wood",true)
			label(Vector3(0,1.8,-front+.25),"LICENSED STORE" if spec.kind=="theka" else "FRESH DAILY / KIRANA",23)
		"chai":
			box(Vector3(0,.7,-front+1),Vector3(width*.65,1.2,.85),"wood",true)
			label(Vector3(0,1.8,-front+.25),"CHAI  /  KACHORI  /  SAMOSA",25)
			for side in [-1,1]:
				bench(Vector3(side*width*.30,0,.2))
				box(Vector3(side*width*.3,.72,.8),Vector3(1.1,.09,.75),"wood",true)
				box(Vector3(side*width*.3,.37,.8),Vector3(.09,.7,.09),"metal")
				for cup in 3:
					box(Vector3(side*width*.3-.3+cup*.3,.83,.8),Vector3(.10,.14,.1),"terracotta")
	var light:=OmniLight3D.new()
	light.position=base+Vector3(0,2.6,0)
	light.light_color=Color("fff0d8")
	light.light_energy=.65
	light.omni_range=maxf(width,depth)*.65
	light.shadow_enabled=false
	light.distance_fade_enabled=true
	light.distance_fade_begin=35
	light.distance_fade_length=12
	world.cell(base).add_child(light)
	# A shaded threshold, warm interior strips and planters give every frontage depth.
	for side in [-1,1]:
		box(Vector3(side*(width/2-.6),.3,front+.55),Vector3(.65,.6,.65),"terracotta",true)
		world.round_prop(base+facing*Vector3(side*(width/2-.6),.85,front+.55),Vector3(.7,.8,.7),"leaves")
		box(Vector3(side*width*.28,3.02,0),Vector3(.16,.045,depth*.65),"warm_light")

func car(at: Vector3, paint: Color, style: String, yaw: float) -> void:
	var model := preload("res://vehicle_design.gd").new()
	model.paint = paint
	model.style = style
	model.position = base+facing*at
	model.rotation.y = atan2(facing.z.x,facing.z.z)+yaw
	world.cell(base).add_child(model)
	# Parked/display cars are solid but have no driving controller.
	var collider := CollisionShape3D.new()
	var bounds := BoxShape3D.new()
	bounds.size = Vector3(1.8,1.4,4.1)
	collider.shape = bounds
	collider.position = base+facing*(at+Vector3(0,.7,0))
	collider.rotation.y = atan2(facing.z.x,facing.z.z)+yaw
	world.cell(base).get_node("Collision").add_child(collider)

func bench(at: Vector3) -> void:
	box(at+Vector3(0,.5,0),Vector3(1.8,.13,.55),"wood",true)
	box(at+Vector3(0,.85,-.25),Vector3(1.8,.6,.1),"wood")
	for side in [-1,1]:
		box(at+Vector3(side*.65,.24,0),Vector3(.08,.48,.45),"metal")
