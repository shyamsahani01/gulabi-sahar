extends "res://heritage_kit.gd"
## VKI workshops and VDN streets: original scenery, not surveyed real businesses.
func factory(target: Node3D, b: Dictionary) -> void:
	world=target
	setup({"p":[b.x,b.z],"a":b.a,"w":b.w,"d":b.d})
	var h:=clampf(float(b.h),4.5,9.5)
	var tone: String=["arch_cream","concrete","heritage_rose"][int(absf(b.x))%3]
	box(Vector3(0,h/2,0),Vector3(w,h,d),tone,true)
	box(Vector3(0,.16,0),Vector3(w+.4,.32,d+.4),"arch_step")
	# Twin pitched sheet-metal roof, ridge cap, gutters and clerestory windows.
	var pitch:=.15
	for side in [-1,1]:
		box(Vector3(side*w*.25,h+w*.038,0),Vector3(w*.51,.16,d+.7),"sky_blue",false,Basis(Vector3.FORWARD,side*pitch))
		box(Vector3(side*(w/2+.16),h-.1,0),Vector3(.16,.19,d+.6),"arch_frame")
		for z in range(0,int(d),2):
			box(Vector3(side*w*.25,h+w*.038+.09,-d/2+z),Vector3(w*.51,.025,.04),"chrome",false,Basis(Vector3.FORWARD,side*pitch))
	box(Vector3(0,h+w*.076,0),Vector3(.3,.12,d+.8),"arch_frame")
	for side in [-1,1]:
		var keep:=basis
		basis*=Basis(Vector3.UP,PI if side<0 else 0)
		var door_w:=minf(4.2,w*.55)
		box(Vector3(0,1.65,d/2+.04),Vector3(door_w,3.3,.10),"arch_frame")
		for k in 14:
			box(Vector3(0,.12+k*.23,d/2+.12),Vector3(door_w-.12,.035,.06),"metal")
		for x in [-w*.34,w*.34]:
			box(Vector3(x,h-1,d/2+.06),Vector3(w*.18,.8,.08),"glass")
			box(Vector3(x,h-1,d/2+.12),Vector3(.05,.8,.06),"chrome")
		box(Vector3(0,3.8,d/2+.1),Vector3(minf(w-.6,8),.65,.16),"heritage_ink")
		if int(absf(b.x+b.z))%4==0:
			label(Vector3(0,3.81,d/2+.20),["VKI  /  ENGINEERING","GULABI  /  FABRICATION","VKI  /  AUTO WORKS"][int(absf(b.z))%3],.25,"heritage_lime",w-.8)
		for x in [-door_w/2-.4,door_w/2+.4]:
			box(Vector3(x,.55,d/2+.45),Vector3(.16,1.1,.16),"kerb_yellow")
			box(Vector3(x,.6,d/2+.45),Vector3(.18,.2,.18),"kerb_black")
		basis=keep
	shape(Vector3(w*.25,h+.8,-d*.2),Vector3(.65,1.6,.65),"chrome")

func clear_verge(at: Vector2) -> bool:
	if not world.map_bounds.grow(-5).has_point(at): return false
	for b in world.data.buildings:
		var local:=Vector2(at.x-b.x,at.y-b.z).rotated(b.a)
		if absf(local.x)<b.w/2+2 and absf(local.y)<b.d/2+2: return false
	for r in world.data.roads:
		for i in range(r.p.size()-1):
			var a:=Vector2(r.p[i][0],r.p[i][1])
			var z:=Vector2(r.p[i+1][0],r.p[i+1][1])
			if Geometry2D.get_closest_point_to_segment(at,a,z).distance_to(at)<r.width/2+1: return false
	return true

func decorate(target: Node3D) -> void:
	world=target
	var occupied: Array[Vector2]=[]
	var count:=0
	for road in world.data.roads:
		if road.kind not in ["primary","secondary","tertiary"]: continue
		for i in range(road.p.size()-1):
			var a:=Vector2(road.p[i][0],road.p[i][1])
			var b:=Vector2(road.p[i+1][0],road.p[i+1][1])
			var delta:=b-a
			if delta.length()<16: continue
			var side:=Vector2(-delta.y,delta.x).normalized()
			var mid:=a.lerp(b,.5)
			for sign0 in [-1,1]:
				var at: Vector2=mid+side*(road.width/2+2.7)*sign0
				var nearby:=false
				for other in occupied:
					if other.distance_squared_to(at)<225: nearby=true; break
				if nearby or count>=220 or not clear_verge(at): continue
				occupied.append(at)
				count+=1
				origin=Vector3(at.x,world.terrain_height(at.x,at.y),at.y)
				basis=Basis(Vector3.UP,atan2(side.x,side.y))
				box(Vector3(0,.15,0),Vector3(2.4,.3,2.4),"heritage_lime")
				box(Vector3(0,.31,0),Vector3(2.1,.06,2.1),"grass")
				world.tree_at(origin+Vector3(0,.3,0))
				if count%3==0:
					box(Vector3(0,.55,1.8),Vector3(1.7,.12,.45),"arch_walnut")
					box(Vector3(0,.85,2.03),Vector3(1.7,.5,.08),"arch_walnut")
					for x in [-.65,.65]:
						box(Vector3(x,.25,1.8),Vector3(.08,.5,.4),"arch_frame")
				if count%5==0:
					rod(Vector3(1.4,0,0),Vector3(1.4,5,0),.05,"arch_frame")
					box(Vector3(1.4,3.8,0),Vector3(.7,1.4,.045),"heritage_red")
					label(Vector3(1.4,3.85,.03),"GULABI\nSAHAR",.18,"heritage_lime",.65)
	# A Jaipur-inspired pavilion in Smriti Park; no distant fort in this edition.
	for park in world.data.parks:
		if park.name!="Smriti Park": continue
		var poly:=PackedVector2Array()
		var centre:=Vector2.ZERO
		for p in park.p:
			var q:=Vector2(p[0],p[1])
			poly.append(q)
			centre+=q
		centre/=poly.size()
		var at:=centre+Vector2(12,0)
		if Geometry2D.is_point_in_polygon(at,poly):
			origin=Vector3(at.x,world.terrain_height(at.x,at.y),at.y)
			basis=Basis.IDENTITY
			pavilion(Vector3.ZERO,4.8)
			for side in [-1,1]:
				pot(Vector3(side*3,0,3),1.1)
			label(Vector3(0,3.2,2.7),"SMRITI  /  VDN",.24,"heritage_ink",3.5)
	boundary_signs()
	world.draw_detail=false

func boundary_signs() -> void:
	var marked: Array[Vector2]=[]
	for road in world.data.roads:
		if road.width<6 or road.p.size()<2: continue
		for end in [0,road.p.size()-1]:
			var p:=Vector2(road.p[end][0],road.p[end][1])
			if world.map_bounds.grow(-.3).has_point(p): continue
			var duplicate:=false
			for q in marked:
				if q.distance_to(p)<20: duplicate=true; break
			if duplicate: continue
			marked.append(p)
			var next: Array=road.p[1 if end==0 else end-1]
			var inward:=(Vector2(next[0],next[1])-p).normalized()
			var at: Vector2=p+inward*9+Vector2(-inward.y,inward.x)*(road.width/2+1)
			origin=Vector3(at.x,world.terrain_height(at.x,at.y),at.y)
			basis=Basis(Vector3.UP,atan2(inward.x,inward.y))
			rod(Vector3.ZERO,Vector3(0,3.8,0),.06,"arch_frame")
			box(Vector3(0,3.1,0),Vector3(2.5,1.0,.12),"heritage_ink")
			label(Vector3(0,3.18,.08),"VKI + VDN",.22,"heritage_lime",2.25)
			label(Vector3(0,2.9,.08),"MAP LIMIT / TURN BACK",.12,"heritage_gold",2.25)
