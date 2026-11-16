extends "res://heritage_kit.gd"
## Visible street vocabulary from March 2026 imagery, pack 19. Adapted compact plots.
## This covers the western block only; hidden interiors and the rest of the way are unmodeled.
const START := Vector2(-1801.76,-2775.77)
const END := Vector2(-1655.43,-2696.87)
const ROAD_ID := 261520115

static func prepare(data: Dictionary) -> void:
	var direction := START.direction_to(END)
	for b in data.buildings:
		if b.has("kind") or b.get("source","")!="infill":continue
		var delta:=Vector2(b.x,b.z)-START
		var along: float=delta.dot(direction)/START.distance_to(END)
		var side: float=direction.cross(delta)
		if along<.08 or along>.94 or absf(side)>22:continue
		b["cinestar_street"]="green_gallery" if side<0 else "rose_flats"
		var toward:=Geometry2D.get_closest_point_to_segment(Vector2(b.x,b.z),START,END)-Vector2(b.x,b.z)
		b["street_front"] = 1 if toward.dot(Vector2(sin(b.a),cos(b.a)))>=0 else -1
		# Preserve the footprint and orientation; approximate observed four/five upper floors.
		b.h=16.0 if side<0 else 19.0

func frontage(b: Dictionary) -> void:
	setup({"p":[b.x,b.z],"a":b.a,"w":b.w,"d":b.d,"front":b.street_front})
	var green: bool=b.cinestar_street=="green_gallery"
	var height: float=b.h
	var f:=d/2
	box(Vector3(0,height/2,0),Vector3(w,height,d),"arch_cream" if green else "heritage_rose",true)
	for bay in 3:
		var x: float=(bay-1)*w*.31
		box(Vector3(x,1.4,f+.055),Vector3(w*.28,2.6,.10),"arch_glazing")
		box(Vector3(x,2.92,f+.14),Vector3(w*.29,.55,.15),"heritage_blue" if bay%2 else "heritage_ink")
		for level in range(1,int(height/3)):
			var y: float=level*3.05+.4
			box(Vector3(x,y+1.1,f+.08),Vector3(w*.25,1.9,.12),"arch_glazing")
			for edge in [-1,1]:
				box(Vector3(x+edge*w*.132,y+1.1,f+.18),Vector3(.12,2.05,.15),"arch_white")
			box(Vector3(x,y+.12,f+.37),Vector3(w*.29,.18,.8),"arch_white")
			jali(Vector3(x,y+.61,f+.7),w*.27,.75,"heritage_lime")
			if green:
				box(Vector3(x,y+1.55,f+.72),Vector3(w*.27,.85,.06),"hedge")
			else:
				box(Vector3(x+w*.07,y+1.0,f+.35),Vector3(.5,.38,.4),"arch_step")
	for x in [-w*.48,0,w*.48]:
		box(Vector3(x,(height+3)/2,f+.2),Vector3(.25,height-3,.4),"arch_white")
	box(Vector3(0,height+.12,0),Vector3(w+.3,.24,d+.3),"heritage_lime")
	box(Vector3(0,height+.5,f),Vector3(w,.65,.18),"arch_cream")
	# Secondary elevations are an inferred continuation of the window vocabulary,
	# not a claim that Street View exposed every side wall.
	for side in [-1,1]:
		for bay in 3:
			var z: float=(bay-1)*d*.30
			for level in range(1,int(height/3)):
				var y: float=level*3.05+1.5
				box(Vector3(side*(w/2+.04),y,z),Vector3(.08,1.7,d*.22),"arch_glazing")
				box(Vector3(side*(w/2+.12),y+.9,z),Vector3(.25,.13,d*.25),"arch_white")
				box(Vector3(side*(w/2+.09),y,z),Vector3(.08,1.7,.06),"arch_white")
	# Shops remain exterior shells; no invented business identity or hidden interior.
	box(Vector3(0,.035,f+.8),Vector3(w,.07,1.5),"heritage_tile")
	world.draw_detail=false

func clear_street_space(at: Vector2, radius: float) -> bool:
	if not world.clear_arrival(at,radius):return false
	for road in world.data.roads:
		for i in range(road.p.size()-1):
			var a:=Vector2(road.p[i][0],road.p[i][1])
			var b:=Vector2(road.p[i+1][0],road.p[i+1][1])
			if Geometry2D.get_closest_point_to_segment(at,a,b).distance_to(at)<road.width/2+radius:return false
	return true

func streetscape(target: Node3D) -> void:
	world=target
	var start: Vector2=START*world.CITY_COMPRESSION
	var end: Vector2=END*world.CITY_COMPRESSION
	var direction:=start.direction_to(end)
	var lateral:=Vector2(-direction.y,direction.x)
	var count:=0
	# Individually checked pockets leave every imported road and footway open.
	for step in range(1,10):
		for side in [-1,1]:
			var at: Vector2=start.lerp(end,step/10.0)+lateral*side*7.0
			if not clear_street_space(at,1.8):continue
			origin=Vector3(at.x,world.terrain_height(at.x,at.y),at.y)
			basis=Basis(Vector3.UP,atan2(direction.x,direction.y))
			box(Vector3(0,.025,0),Vector3(2.4,.05,3),"heritage_tile")
			if step%3==0:
				world.parked_vehicle(origin,yaw()+.35,"car","white" if side<0 else "dark")
			else:
				world.tree_at(origin)
				for edge in [-1,1]:
					box(Vector3(edge*.75,.15,0),Vector3(.16,.3,1.6),"heritage_rose")
			count+=1
	# The mobile mast is visible at the eastern junction; position adapted to clear map space.
	var mast: Vector2=end-direction*9-lateral*9
	if clear_street_space(mast,1.1):
		origin=Vector3(mast.x,world.terrain_height(mast.x,mast.y),mast.y)
		basis=Basis.IDENTITY
		rod(Vector3.ZERO,Vector3(0,22,0),.13,"arch_frame")
		for y in range(1,22):
			box(Vector3(.18,y,0),Vector3(.4,.045,.35),"arch_step")
		for angle in [0.0,TAU/3,TAU*2/3]:
			box(Vector3(sin(angle)*.55,20.5,cos(angle)*.55),Vector3(.3,2.2,.2),"arch_white",false,Basis(Vector3.UP,angle))
	world.set_meta("cinestar_street_pockets",count)
	world.draw_detail=false
