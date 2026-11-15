extends "res://heritage_kit.gd"
## Photo study: designs/17-sector-2-central-spine. Original 3D geometry, no photo textures.
## Existing compact-map plots are approximate; facade proportions are adapted to those plots.
const CAMERA_SOURCE := Vector2(-1851.0874135,-2656.5950268)
const MAIN_CLINIC_ID := 7698486528
const MAIN_ROAD_ID := 261520097
var featured_count := 0

static func prepare(data: Dictionary) -> void:
	# Local facade corrections retain the map's original clinic identity and footprint.
	# The photograph is a visual reference, not evidence of this clinic's tenancy.
	for a in data.amenities:
		if int(a.get("osm_id",0))!=MAIN_CLINIC_ID: continue
		a["sector2_design"]="rose_tower"
		var toward:=CAMERA_SOURCE-Vector2(a.p[0],a.p[1])
		a.a=atan2(toward.x,toward.y)
		a.front=1
		for b in data.buildings:
			if int(b.get("osm_id",0))==MAIN_CLINIC_ID:
				b.a=a.a
				b.h=23.6
	# Named local map selection keeps the original OSM road ID and vertices.
	for r in data.roads:
		if int(r.get("id",0))==MAIN_ROAD_ID:
			r.name="Central Spine · Sector 2"
			r["name_source"]="Local display label from user Street View reference; OSM name was empty"
	for b in data.buildings:
		if b.has("kind") or b.get("source","")!="infill":continue
		var delta:=Vector2(b.x,b.z)-CAMERA_SOURCE
		if delta.length()<90 and delta.x>25:
			b["sector2_design"]="shop_row"

func tower(a: Dictionary) -> void:
	setup(a)
	featured_count+=1
	var f:=d/2
	var height:=23.6
	# Open central ground-floor passage; the side bays use modeled glazing.
	box(Vector3(0,.08,0),Vector3(w,.16,d),"arch_step",true)
	box(Vector3(0,1.6,-f),Vector3(w,3.2,.2),"arch_cream",true)
	for side in [-1,1]:
		box(Vector3(side*(w/2-.1),1.6,0),Vector3(.2,3.2,d),"arch_cream",true)
		var bw: float=(w-2.2)/2
		box(Vector3(side*(1.1+bw/2),1.5,f),Vector3(bw,2.85,.1),"arch_glazing",true)
		for i in 4:
			box(Vector3(side*(1.1+bw*i/3),1.5,f+.08),Vector3(.06,2.9,.08),"arch_white")
		box(Vector3(side*(w*.31),.16,f+.7),Vector3(w*.34,.3,1.4),"arch_step")
		box(Vector3(side*(w*.31),.31,f+.3),Vector3(w*.34,.3,.7),"arch_step")
	# Retail fascia and a rose podium: open white-column gallery above the shops.
	box(Vector3(0,3.32,0),Vector3(w+.2,.24,d+.25),"heritage_lime",true)
	box(Vector3(0,4.7,-.6),Vector3(w,2.5,d-1.2),"heritage_rose",true)
	for level in [3.45,6.05,7.65]:
		box(Vector3(0,level,f+.18),Vector3(w+.3,.20,.55),"heritage_lime")
	for i in 7:
		var x: float=lerpf(-w*.47,w*.47,i/6.0)
		box(Vector3(x,4.7,f+.2),Vector3(.18,2.45,.28),"arch_white")
		if i<6:
			var mid: float=x+w*.94/12
			box(Vector3(mid,4.9,f-.56),Vector3(w*.94/6-.22,1.8,.06),"arch_glazing")
			jali(Vector3(mid,3.95,f+.28),w*.94/6-.18,.65,"heritage_lime")
	box(Vector3(0,6.9,f+.12),Vector3(w,1.1,.08),"arch_glazing")
	for i in 17:
		box(Vector3(lerpf(-w*.49,w*.49,i/16.0),6.9,f+.20),Vector3(.04,1.14,.04),"arch_white")
	box(Vector3(0,7.6,f+.35),Vector3(w+.5,.1,.9),"heritage_blue")
	# Cream upper tower, rose end panels, paired curved balconies and deep vertical fins.
	box(Vector3(0,(height+7.8)/2,-.25),Vector3(w*.94,height-7.8,d-.5),"arch_cream",true)
	for side in [-1,1]:
		box(Vector3(side*w*.41,15.7,f+.015),Vector3(w*.15,15.8,.10),"heritage_rose")
		for y in range(8,24):
			box(Vector3(side*w*.41,y+.18,f+.085),Vector3(w*.15,.028,.035),"heritage_red")
		for x in [w*.18,w*.29]:
			box(Vector3(side*x,15.65,f+.22),Vector3(.28,15.8,.55),"arch_white")
	for level in 5:
		var y:=8.15+level*3.0
		for side in [-1,1]:
			box(Vector3(side*w*.32,y+1.25,f+.10),Vector3(w*.075,1.55,.10),"arch_glazing")
			box(Vector3(side*w*.32,y+1.25,f+.19),Vector3(.045,1.6,.06),"arch_white")
			box(Vector3(side*w*.41,y+2.65,f+.15),Vector3(w*.16,.20,.27),"heritage_lime")
			curved_balcony(Vector3(side*w*.09,y,f+.12),w*.17,2.5)
			# Small AC compressor boxes belong to the facade, not the road.
			box(Vector3(side*w*.39,y+.5,f+.30),Vector3(.55,.42,.35),"arch_step")
			for l in 4:
				box(Vector3(side*w*.39,y+.37+l*.08,f+.49),Vector3(.45,.025,.02),"arch_frame")
	box(Vector3(0,height+.15,0),Vector3(w+.7,.3,d+.7),"heritage_lime")
	for side in [-1,1]:
		box(Vector3(0,height+.55,side*f),Vector3(w,.65,.18),"arch_cream")
		box(Vector3(side*w/2,height+.55,0),Vector3(.18,.65,d),"arch_cream")
	# Observed sign vocabulary; the neighboring original clinic marker is preserved.
	for spec in [[-w*.29,w*.40,"ICICI BANK","heritage_red"],[w*.10,w*.31,"MONIKA DENTAL","heritage_blue"],[w*.39,w*.23,"SHOPS","heritage_ink"]]:
		box(Vector3(spec[0],2.98,f+.25),Vector3(spec[1],.62,.15),spec[3])
		label(Vector3(spec[0],2.98,f+.35),spec[2],.25,"arch_white",spec[1]-.12)
	label(Vector3(0,2.3,-f+.14),str(a.name).to_upper(),.22,"heritage_ink",w*.8)
	box(Vector3(-w*.25,.65,-f+1),Vector3(w*.3,1.1,.7),"heritage_rose",true)
	# A low, traversable forecourt and parking pockets leave the central entrance clear.
	box(Vector3(0,.025,f+2.3),Vector3(w,.05,4.6),"heritage_tile")
	for side in [-1,1]:
		var at:=Vector3(side*w*.33,0,f+2.5)
		world.parked_vehicle(origin+basis*at,yaw()+.2,"car","white" if side<0 else "dark")
		for edge in [-1,1]:
			box(at+Vector3(edge*1.1,.06,0),Vector3(.06,.025,3.8),"heritage_lime")
		rod(Vector3(side*1.5,0,f+3.9),Vector3(side*1.5,.9,f+3.9),.045,"kerb_yellow")
	world.draw_detail=false

func curved_balcony(at: Vector3,width: float,height: float) -> void:
	# Arc segments form a projecting curved front, with separate pale rails and glazing.
	box(at+Vector3(0,height*.48,-.12),Vector3(width*.9,height*.92,.08),"arch_glazing")
	for i in range(9):
		var theta: float=PI*i/8
		var x: float=cos(theta)*width/2
		var z: float=sin(theta)*.72
		box(at+Vector3(x,.14,z),Vector3(width/7,.20,.35),"arch_white")
		box(at+Vector3(x,.72,z),Vector3(width/7,.08,.08),"arch_white")
		box(at+Vector3(x,1.0,z),Vector3(.05,.6,.05),"heritage_lime")
		box(at+Vector3(x,height,z),Vector3(width/7,.13,.24),"arch_white")
	for x in [-width*.44,0,width*.44]:
		box(at+Vector3(x,height*.55,.04),Vector3(.045,height-.2,.05),"heritage_lime")

func shop_row(b: Dictionary) -> void:
	setup({"p":[b.x,b.z],"a":b.a,"w":b.w,"d":b.d})
	var height: float=maxf(9,b.h)
	box(Vector3(0,height/2,0),Vector3(w,height,d),"arch_cream",true)
	for side in [-1,1]:
		var saved:=basis
		basis*=Basis(Vector3.UP,PI if side<0 else 0)
		for bay in 3:
			var x: float=(bay-1)*w*.31
			box(Vector3(x,1.4,d/2+.02),Vector3(w*.27,2.6,.08),"arch_glazing")
			for level in range(1,int(height/3)):
				box(Vector3(x,level*3+1.25,d/2+.05),Vector3(w*.24,1.8,.08),"arch_glazing")
				box(Vector3(x,level*3+.25,d/2+.35),Vector3(w*.29,.18,.8),"heritage_lime")
				jali(Vector3(x,level*3+.65,d/2+.7),w*.26,.6)
		for x in [-w*.48,w*.48]:
			box(Vector3(x,height/2,d/2+.14),Vector3(.32,height,.30),"heritage_rose")
		box(Vector3(0,2.85,d/2+.18),Vector3(w*.95,.5,.15),"heritage_blue")
		box(Vector3(0,height+.2,d/2+.15),Vector3(w+.6,.3,.8),"heritage_lime")
		basis=saved
	world.draw_detail=false

func streetscape(target: Node3D) -> void:
	world=target
	var centre: Vector2=CAMERA_SOURCE*world.CITY_COMPRESSION
	# Fit the narrow median to the actual gap between the two imported carriageways.
	var north:=Vector2(.444,-.896)
	var east:=Vector2(.896,.444)
	var other: Dictionary={}
	for r in world.data.roads:
		if int(r.get("id",0))==278200313:other=r;break
	if other.is_empty():return
	var nearest:=Vector2.ZERO
	var distance:=INF
	for i in range(other.p.size()-1):
		var a:=Vector2(other.p[i][0],other.p[i][1])
		var b:=Vector2(other.p[i+1][0],other.p[i+1][1])
		var q:=Geometry2D.get_closest_point_to_segment(centre,a,b)
		if q.distance_squared_to(centre)<distance:nearest=q;distance=q.distance_squared_to(centre)
	var median: Vector2=centre.lerp(nearest,.5)
	origin=Vector3(median.x,world.terrain_height(median.x,median.y),median.y)
	basis=Basis(Vector3.UP,atan2(north.x,north.y))
	# Ground-level median detail has no invisible collision walls across the roads.
	for i in range(-20,21):
		box(Vector3(0,.07,i*1.2),Vector3(.72,.14,1.18),"heritage_tile")
		for side in [-1,1]:
			box(Vector3(side*.42,.12,i*1.2),Vector3(.16,.24,1.18),"kerb_black" if i%2==0 else "kerb_yellow")
	for z in [-20.0,0.0,20.0]:
		rod(Vector3(0,0,z),Vector3(0,7,z),.065,"heritage_gold")
		for side in [-1,1]:
			rod(Vector3(0,6.6,z),Vector3(side*1.6,7.5,z),.04,"heritage_gold")
			box(Vector3(side*1.7,7.48,z),Vector3(.5,.10,.20),"arch_frame")
		box(Vector3(0,4.7,z),Vector3(.4,.7,.04),"heritage_red")
	# Feeder pillar and cables are raised above traffic; the large actual pole is simplified.
	rod(Vector3(.1,0,8),Vector3(.1,11,8),.18,"concrete")
	box(Vector3(.1,.65,8),Vector3(.62,1.3,.6),"arch_step")
	for offset in [-.25,0,.25]:
		rod(Vector3(offset,8,-24),Vector3(offset,7.8,0),.012,"arch_frame")
		rod(Vector3(offset,7.8,0),Vector3(offset,8,24),.012,"arch_frame")
	# Opposite-side kiosk and short planted boundary, fitted to clear map space.
	var at: Vector2=centre-east*20-north*6
	if world.clear_arrival(at,3.5):
		origin=Vector3(at.x,world.terrain_height(at.x,at.y),at.y)
		basis=Basis(Vector3.UP,atan2(east.x,east.y))
		box(Vector3(0,1.25,0),Vector3(3.2,2.5,2.0),"heritage_blue",true)
		box(Vector3(0,1.55,1.04),Vector3(2.8,.9,.09),"arch_glazing")
		box(Vector3(0,2.55,0),Vector3(3.5,.14,2.4),"arch_step")
		box(Vector3(0,2.25,1.09),Vector3(3.1,.4,.07),"arch_white")
		label(Vector3(0,2.25,1.15),"JAIPUR DAIRY",.24,"heritage_blue",2.9)
		for x in [-1.5,1.5]:rod(Vector3(x,0,2),Vector3(x,2.4,2),.035,"arch_frame")
		box(Vector3(0,2.42,1.8),Vector3(3.4,.08,2),"heritage_blue")
	var planted:=0
	for step in range(-4,5):
		at=centre-east*24+north*step*10
		if not world.clear_arrival(at,2.8):continue
		world.tree_at(Vector3(at.x,world.terrain_height(at.x,at.y),at.y))
		planted+=1
	world.set_meta("sector2_tree_count",planted)
	world.draw_detail=false
