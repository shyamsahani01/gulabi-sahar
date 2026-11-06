extends "res://reference_building.gd"
## Crazy Cafe, rebuilt from the user's exterior and interior reference screenshots (2026-11-06).
## Rust-plaster upper storey with two shuttered windows and the cup mark, black fascia,
## full-height black-framed glazing, lit stone steps, white planters, a fenced turf terrace;
## inside: grey microcement walls, chestnut plank floor, coffee-plant mural, chalkboard menu,
## wall counter with cane stools, cane booths, the back-wall sign and the neon script.
const FLOOR := .75
const BRAND := "CRAZY CAFE"
var split: float
var door: float
var room_x: float
var bay_x: float
func build(a: Dictionary) -> void:
	setup(a)
	var f:=d/2
	door=-w*.25
	split=-w*.04
	room_x=(-w/2+split)/2
	bay_x=(split+w/2)/2
	var brand: String=BRAND if a.get("osm_id",0)==-91001 or a.name=="" else a.name.to_upper()
	# ---- shell: raised floor slab, back and side walls, first-floor slab, rust upper storey, parapet.
	box(Vector3(0,.375,0),Vector3(w,.75,d),"arch_step",true)
	box(Vector3(0,2.28,-f),Vector3(w,3.1,.2),"arch_plaster",true)
	for side in [-1,1]:
		box(Vector3(side*w/2,2.3,0),Vector3(.2,3.1,d),"arch_plaster",true)
		box(Vector3(side*(w/2-.12),2.3,f),Vector3(.25,3.1,.36),"arch_black",true)
	box(Vector3(0,3.88,0),Vector3(w+.25,.18,d+.3),"arch_ceiling",true)
	box(Vector3(0,5.15,-.15),Vector3(w,2.36,d-.3),"arch_rust",true)
	box(Vector3(0,6.42,0),Vector3(w+.5,.26,d+.4),"arch_step")
	for i in 4:
		spot(Vector3(lerpf(-w*.38,w*.38,float(i)/3),6.28,f+.1),.08)
	# Shuttered upper windows: walnut frame, dark glazing, pale horizontal blinds.
	for x in [-w*.30,w*.30]:
		box(Vector3(x,5.25,f-.27),Vector3(1.75,1.45,.12),"arch_walnut")
		box(Vector3(x,5.25,f-.19),Vector3(1.5,1.22,.05),"arch_glazing")
		box(Vector3(x,5.25,f-.15),Vector3(.05,1.22,.06),"arch_walnut")
		for k in 7:
			box(Vector3(x,4.74+k*.17,f-.155),Vector3(1.46,.022,.03),"arch_white")
	cup_logo(Vector3(0,5.35,f-.08),.8)
	# ---- fascia: black band, brand letters, framed logo plaque, under-lights.
	box(Vector3(0,3.98,f+.24),Vector3(w+.55,.92,.58),"arch_black")
	label(Vector3(.9,3.98,f+.55),brand,.64,"arch_white",w-3.2)
	box(Vector3(-w/2+.75,3.98,f+.55),Vector3(1.1,.7,.04),"arch_white")
	box(Vector3(-w/2+.75,3.98,f+.58),Vector3(1.02,.62,.04),"arch_black")
	label(Vector3(-w/2+.75,4.1,f+.62),"CRAZY",.2,"arch_white",.92)
	label(Vector3(-w/2+.75,3.86,f+.62),"CAFE",.2,"arch_white",.92)
	for i in 6:
		spot(Vector3(lerpf(-w*.42,w*.42,float(i)/5),3.52,f+.3),.07)
	light(Vector3(door,3.3,f+.9),.7,5.5)
	# ---- ground-floor glazing with the central black pier and the open double door.
	box(Vector3(split,2.22,f),Vector3(.65,3.1,.34),"arch_black",true)
	glazing(-w/2+.22,door-.8,f)
	glazing(door+.8,split-.34,f)
	glazing(split+.34,w/2-.22,f)
	for side in [-1,1]:
		box(Vector3(door+side*.78,2.12,f-.7),Vector3(.035,2.7,1.38),"arch_glass")
		box(Vector3(door+side*.78,2.12,f-.02),Vector3(.045,2.75,.05),"arch_frame")
		rod(Vector3(door+side*.74,1.55,f-.9),Vector3(door+side*.74,2.3,f-.9),.016,"chrome")
	box(Vector3(door,3.55,f+.02),Vector3(1.66,.06,.06),"arch_frame")
	# ---- pavement, five lit stone treads and planters.
	box(Vector3(0,.025,f+1.55),Vector3(w+.8,.05,3.2),"arch_step",true)
	for i in 5:
		box(Vector3(door,.075*(i+1),f+2.1-i*.42),Vector3(2.6,.15*(i+1),.44),"arch_step")
		box(Vector3(door,.15*(i+1)-.045,f+2.32-i*.42),Vector3(2.4,.025,.012),"arch_strip")
	collision_ramp(door,f,2.6,2.5,FLOOR+.04)
	detail=true
	for side in [-1,1]:
		for i in 4:
			pot(Vector3(door+side*1.55,.15*i,f+2.1-i*.5),.95)
		pot(Vector3(door+side*2.1,0,f+2.75),1.15)
	# Street banner on a lamp post beside the kerb.
	var post:=Vector3(-w/2-.9,0,f+2.9)
	rod(post,post+Vector3(0,5.6,0),.05,"arch_frame")
	rod(post+Vector3(0,5.5,0),post+Vector3(1.4,5.75,0),.035,"arch_frame")
	box(post+Vector3(1.45,5.72,0),Vector3(.5,.12,.3),"arch_frame")
	box(post+Vector3(.42,3.9,0),Vector3(.62,1.35,.03),"arch_banner")
	rod(post+Vector3(0,4.55,0),post+Vector3(.75,4.55,0),.015,"arch_frame")
	cup_logo(post+Vector3(.42,4.12,.03),.3)
	label(post+Vector3(.42,3.62,.03),"CRAZY",.1,"arch_white",.55)
	label(post+Vector3(.42,3.48,.03),"CAFE",.1,"arch_white",.55)
	# ---- right terrace: turf, white picket fence, round table and two white chairs.
	var terrace_x: float=w*.30
	box(Vector3(terrace_x,.065,f+1.3),Vector3(w*.37,.06,2.6),"arch_turf")
	for z in [f+.1,f+2.6]:
		for i in 14:
			var x: float=split+.5+i*(w*.36)/13
			rod(Vector3(x,.1,z),Vector3(x,1.05,z+.06),.018,"arch_white")
		rod(Vector3(split+.5,.84,z),Vector3(w/2+.1,.84,z),.026,"arch_white")
	for z in [f+.8,f+1.9]:
		pot(Vector3(w/2-.1,.08,z),1.0)
	table(Vector3(terrace_x,.1,f+1.3),true)
	chair(Vector3(terrace_x-.75,.1,f+1.3),-PI/2,true)
	chair(Vector3(terrace_x+.75,.1,f+1.3),PI/2,true)
	seat(Vector3(terrace_x-.75,.1,f+1.3),-PI/2,.47)
	seat(Vector3(terrace_x+.75,.1,f+1.3),PI/2,.47)
	# ---- interior: plank floor, partition, ceiling spots, speakers.
	for i in range(int(w/.24)):
		box(Vector3(-w/2+.13+i*.24,FLOOR+.012,0),Vector3(.232,.024,d-.2),"arch_oak")
	box(Vector3(split,2.25,-d*.06),Vector3(.13,3,d*.88),"arch_plaster",true)
	for x in [room_x-1.7,room_x,room_x+1.7]:
		for z in [-d*.36,-d*.12,d*.12,d*.36]:
			spot(Vector3(x,3.78,z))
	for x in [bay_x-1.6,bay_x+1.6]:
		for z in [-d*.3,0.0,d*.3]:
			spot(Vector3(x,3.78,z))
	for x in [-w/2+.35,split-.35]:
		box(Vector3(x,3.5,f-.45),Vector3(.22,.3,.22),"arch_black")
	room_left(f)
	room_back(f)
	room_right(f)
	counter_bay(f)
	light(Vector3(room_x,3.1,-d*.2),.85,5.5)
	light(Vector3(room_x,3.1,d*.22),.65,5)
	light(Vector3(bay_x,3.0,0),.7,5)
	detail=false
	world.draw_detail=false
	if a.get("osm_id",0)==-91001:
		# The atlas landmark for this branch arrives at the steps, facing the door, car parked on the road.
		var entrance:=origin+basis*Vector3(door,0,f+3.6)
		var road: Dictionary=world.nearest_road_point(entrance.x,entrance.z)
		for poi in world.landmarks:
			if poi.name.begins_with("Crazy Cafe"):
				poi.p=[entrance.x,entrance.z]
				poi.rotation=yaw()+PI
				poi.car_p=[road.p.x,road.p.y]
				poi.car_heading=road.heading

func room_left(f: float) -> void:
	var x: float=-w/2+.11
	# Wall-mounted high counter with black brackets and four cane-backed stools.
	box(Vector3(x+.2,FLOOR+1.02,-d*.14),Vector3(.5,.06,d*.52),"arch_walnut",true)
	for z in [-d*.36,-d*.14,d*.08]:
		rod(Vector3(x+.02,FLOOR+.62,z),Vector3(x+.4,FLOOR+.98,z),.018,"arch_black")
		rod(Vector3(x+.02,FLOOR+.62,z),Vector3(x+.02,FLOOR+.98,z),.018,"arch_black")
	for i in 4:
		var z: float=-d*.36+i*d*.15
		stool(Vector3(x+.78,FLOOR,z),PI/2)
		seat(Vector3(x+.78,FLOOR,z),PI/2,.72,i==1,"SitHigh")
	for z in [-d*.3,d*.02]:
		box(Vector3(x+.22,FLOOR+1.055,z),Vector3(.2,.005,.28),"arch_white")
		bottle(Vector3(x+.35,FLOOR+1.05,z+.3))
		flowers(Vector3(x+.1,FLOOR+1.05,z-.3))
	# Coffee-plant mural near the entrance: branches, leaves and red cherries on the wall.
	var mx: float=-w/2+.115
	for branch in [[Vector3(mx,FLOOR+.9,f-.9),Vector3(mx,FLOOR+2.4,f-1.6)],[Vector3(mx,FLOOR+1.5,f-.5),Vector3(mx,FLOOR+2.6,f-1.0)],[Vector3(mx,FLOOR+1.9,f-1.3),Vector3(mx,FLOOR+2.75,f-2.0)]]:
		rod(branch[0],branch[1],.012,"arch_leaf_dark")
		for i in 6:
			var t: float=.12+i*.16
			var on: Vector3=branch[0].lerp(branch[1],t)
			var side: float=1 if i%2 else -1
			shape(on+Vector3(0,.04*side,side*.17),Vector3(.03,.32,.15),"arch_leaf" if i%3 else "arch_leaf_dark","sphere",Basis.from_euler(Vector3(side*.9,0,0)))
			if i%2:
				for k in 3:
					shape(on+Vector3(.015,-.05+k*.045,side*.05+k*.02),Vector3(.055,.055,.055),"arch_berry","sphere")
	# Wall lettering: COFFEE is the Answer, to Matter the Question.
	var tz: float=f-2.9
	label(Vector3(mx+.02,FLOOR+2.55,tz),"COFFEE",.32,"arch_black",1.5,false,PI/2)
	label(Vector3(mx+.02,FLOOR+2.27,tz),"- is the Answer -",.11,"arch_black",1.4,false,PI/2)
	label(Vector3(mx+.02,FLOOR+2.06,tz),"to Matter",.15,"arch_black",1.3,false,PI/2)
	label(Vector3(mx+.02,FLOOR+1.86,tz),"the Question",.14,"arch_black",1.3,false,PI/2)
	shape(Vector3(mx+.02,FLOOR+1.5,tz),Vector3(.18,.16,.05),"arch_black","pot")
	# Chalkboard menu in a walnut frame.
	var bz: float=f-4.6
	box(Vector3(mx+.04,FLOOR+2.05,bz),Vector3(.06,1.3,1.0),"arch_walnut")
	box(Vector3(mx+.075,FLOOR+2.05,bz),Vector3(.02,1.16,.86),"arch_black")
	label(Vector3(mx+.09,FLOOR+2.5,bz),"CRAZY",.1,"arch_white",.8,false,PI/2)
	label(Vector3(mx+.09,FLOOR+2.37,bz),"CAFE",.1,"arch_white",.8,false,PI/2)
	var lines:=["Espresso    Rs 120","Americano  Rs 140","Latte          Rs 180","Cappuccino Rs 190","Mocha        Rs 210"]
	for i in lines.size():
		label(Vector3(mx+.09,FLOOR+2.16-i*.15,bz),lines[i],.065,"arch_white",.78,false,PI/2)
	# Split air conditioner high on the front wall, speaker wire, and a socket plate.
	box(Vector3(mx+.12,3.45,f-1.0),Vector3(.26,.3,.95),"arch_white")
	box(Vector3(mx+.26,3.34,f-1.0),Vector3(.02,.03,.85),"arch_frame")
	box(Vector3(mx+.02,FLOOR+1.25,f-2.9),Vector3(.02,.09,.16),"arch_white")

func room_back(f: float) -> void:
	var z: float=-f+.11
	box(Vector3(room_x,FLOOR+2.32,z),Vector3(3.2,.56,.08),"arch_black")
	label(Vector3(room_x,FLOOR+2.32,z+.06),BRAND,.34,"arch_white",2.9)
	cup_logo(Vector3(room_x,FLOOR+2.92,z+.1),.45)
	label(Vector3(room_x,FLOOR+1.78,z+.05),"Espresso Yourself",.44,"arch_neon",3.0,true)
	rod(Vector3(room_x-1.2,FLOOR+1.55,z+.04),Vector3(room_x+1.2,FLOOR+1.55,z+.04),.012,"arch_neon")
	palm(Vector3(-w/2+.75,FLOOR,-f+.7),1.05)
	palm(Vector3(split-.75,FLOOR,-f+.7),.95)

func room_right(f: float) -> void:
	var x: float=split-.075
	# Long cane feature panel with a walnut border and two black cone sconces.
	box(Vector3(x,FLOOR+2.35,-d*.05),Vector3(.09,.62,d*.5),"arch_walnut")
	box(Vector3(x-.03,FLOOR+2.35,-d*.05),Vector3(.03,.5,d*.47),"arch_cane")
	for i in 26:
		box(Vector3(x-.05,FLOOR+2.35,-d*.05-d*.235+i*d*.47/25),Vector3(.01,.5,.012),"arch_rope")
	for z in [-d*.32,d*.2]:
		rod(Vector3(x,FLOOR+2.95,z),Vector3(x-.3,FLOOR+2.95,z),.014,"arch_black")
		shape(Vector3(x-.3,FLOOR+2.82,z),Vector3(.26,.26,.26),"arch_black","cone",Basis.from_euler(Vector3(PI,0,0)))
		shape(Vector3(x-.3,FLOOR+2.69,z),Vector3(.2,.015,.2),"arch_neon")
	# Three booths: cane sofa against the partition, walnut table, cane chair opposite.
	for i in 3:
		var z: float=-d*.33+i*d*.25
		booth(Vector3(x-.4,FLOOR,z),PI/2,i==2)
		table(Vector3(x-1.25,FLOOR,z),false)
		chair(Vector3(x-2.05,FLOOR,z),-PI/2,false)
		seat(Vector3(x-2.05,FLOOR,z),-PI/2,.47,i==0)
		flowers(Vector3(x-1.1,FLOOR+.8,z-.32))

func counter_bay(f: float) -> void:
	# Service counter across the second bay, seen through the glazing from the street.
	var z: float=f-2.7
	var width: float=(w/2-split)-1.3
	box(Vector3(bay_x,FLOOR+.5,z),Vector3(width,1.0,.75),"arch_walnut",true)
	for i in int(width/.11):
		box(Vector3(bay_x-width/2+.06+i*.11,FLOOR+.5,z+.38),Vector3(.07,.95,.03),"arch_walnut")
	box(Vector3(bay_x,FLOOR+1.03,z),Vector3(width+.1,.07,.85),"arch_quartz",true)
	box(Vector3(bay_x,FLOOR+.985,z+.42),Vector3(width,.02,.02),"arch_strip")
	# Pastry display case with two shelves and a tray of bakes.
	var cx: float=bay_x-width*.26
	box(Vector3(cx,FLOOR+1.35,z),Vector3(1.3,.56,.6),"arch_glass")
	box(Vector3(cx,FLOOR+1.08,z),Vector3(1.3,.03,.6),"arch_quartz")
	box(Vector3(cx,FLOOR+1.33,z),Vector3(1.26,.02,.56),"arch_glass")
	for row in 2:
		for i in 5:
			shape(Vector3(cx-.5+i*.25,FLOOR+1.14+row*.25,z-.1+row*.2),Vector3(.14,.07,.14),"arch_oak" if i%2 else "arch_cane","sphere")
	# Espresso machine, grinder, cups and the back shelves.
	var ex: float=bay_x+width*.25
	box(Vector3(ex,FLOOR+1.3,z),Vector3(.8,.48,.5),"arch_black")
	box(Vector3(ex,FLOOR+1.56,z),Vector3(.82,.05,.52),"chrome")
	for dx in [-.2,.2]:
		shape(Vector3(ex+dx,FLOOR+1.16,z+.26),Vector3(.09,.2,.09),"chrome")
	shape(Vector3(ex+.65,FLOOR+1.28,z),Vector3(.18,.46,.18),"arch_black")
	for i in 5:
		shape(Vector3(ex-.3+i*.15,FLOOR+1.63,z-.1),Vector3(.08,.08,.08),"arch_white")
	for y in [1.65,2.15,2.65]:
		box(Vector3(bay_x,FLOOR+y,-f+.3),Vector3(width,.05,.3),"arch_walnut")
		for i in 9:
			var ix: float=bay_x-width/2+.3+i*(width-.6)/8
			if i%3==2:
				shape(Vector3(ix,FLOOR+y+.14,-f+.3),Vector3(.13,.22,.13),"arch_glass")
			else:
				shape(Vector3(ix,FLOOR+y+.065,-f+.3),Vector3(.09,.085,.09),"arch_white" if i%2 else "arch_cane")
	for i in 3:
		var px: float=bay_x-width*.3+i*width*.3
		rod(Vector3(px,3.79,z),Vector3(px,FLOOR+2.35,z),.008,"arch_black")
		shape(Vector3(px,FLOOR+2.2,z),Vector3(.3,.3,.3),"arch_black","cone",Basis.from_euler(Vector3(PI,0,0)))
		shape(Vector3(px,FLOOR+2.05,z),Vector3(.22,.015,.22),"arch_neon")
	# Chalkboard inside the right wall, readable from the street.
	var bx: float=w/2-.125
	box(Vector3(bx,FLOOR+2.1,f-1.0),Vector3(.05,1.15,.9),"arch_walnut")
	box(Vector3(bx-.035,FLOOR+2.1,f-1.0),Vector3(.02,1.03,.78),"arch_black")
	label(Vector3(bx-.05,FLOOR+2.5,f-1.0),"CRAZY CAFE",.08,"arch_white",.72,false,-PI/2)
	var lines:=["Espresso    Rs 120","Americano  Rs 140","Latte          Rs 180","Cappuccino Rs 190","Mocha        Rs 210"]
	for i in lines.size():
		label(Vector3(bx-.05,FLOOR+2.3-i*.14,f-1.0),lines[i],.06,"arch_white",.7,false,-PI/2)
	seat(Vector3(bay_x,FLOOR,z-1.0),PI,0,true,"Stand")

func glazing(left: float,right: float,z: float) -> void:
	if right-left<.1:
		return
	box(Vector3((left+right)/2,2.15,z),Vector3(right-left,2.8,.028),"arch_glass",true)
	var columns:=maxi(1,roundi((right-left)/1.15))
	for i in range(columns+1):
		box(Vector3(lerpf(left,right,float(i)/columns),2.15,z+.025),Vector3(.045,2.8,.06),"arch_frame")
	for y in [.77,3.0,3.55]:
		box(Vector3((left+right)/2,y,z+.025),Vector3(right-left,.045,.06),"arch_frame")
	box(Vector3((left+right)/2,.79,z+.06),Vector3(right-left,.09,.1),"arch_step")

func bottle(at: Vector3) -> void:
	shape(at+Vector3(0,.12,0),Vector3(.07,.24,.07),"arch_glass")
	shape(at+Vector3(0,.27,0),Vector3(.035,.06,.035),"arch_glass")
	shape(at+Vector3(0,.31,0),Vector3(.04,.02,.04),"chrome")

func flowers(at: Vector3) -> void:
	shape(at+Vector3(0,.08,0),Vector3(.06,.16,.06),"arch_glass")
	for i in 4:
		var tip:=at+Vector3(sin(i*1.6)*.06,.26+(i%2)*.04,cos(i*1.6)*.06)
		rod(at+Vector3(0,.14,0),tip,.004,"arch_leaf_dark")
		shape(tip,Vector3(.045,.03,.045),"arch_white","sphere")

func table(at: Vector3,outdoor: bool) -> void:
	if outdoor:
		shape(at+Vector3(0,.76,0),Vector3(.98,.075,.98),"arch_walnut")
		shape(at+Vector3(0,.04,0),Vector3(.48,.065,.48),"arch_black")
	else:
		box(at+Vector3(0,.76,0),Vector3(.8,.075,1.05),"arch_walnut",true)
		box(at+Vector3(0,.04,0),Vector3(.5,.055,.6),"arch_black")
	rod(at+Vector3(0,.06,0),at+Vector3(0,.72,0),.045,"arch_black")
	box(at+Vector3(0,.805,0),Vector3(.22,.008,.30),"arch_white")
	for i in 5:
		box(at+Vector3(0,.811,-.10+i*.035),Vector3(.14,.003,.006),"arch_black")
	bottle(at+Vector3(.25,.8,.18))

func stool(at: Vector3,yaw_local: float) -> void:
	var previous_origin:=origin
	var previous_basis:=basis
	origin+=basis*at
	basis*=Basis(Vector3.UP,yaw_local)
	for x in [-.17,.17]:
		for z in [-.17,.17]:
			rod(Vector3(x*1.1,0,z*1.1),Vector3(x,.7,z),.02,"arch_walnut")
	for pair in [[Vector3(-.19,.25,-.19),Vector3(.19,.25,-.19)],[Vector3(-.19,.25,.19),Vector3(.19,.25,.19)],[Vector3(-.19,.25,-.19),Vector3(-.19,.25,.19)],[Vector3(.19,.25,-.19),Vector3(.19,.25,.19)]]:
		rod(pair[0],pair[1],.012,"arch_walnut")
	shape(Vector3(0,.72,0),Vector3(.4,.05,.4),"arch_walnut")
	for x in [-.17,.17]:
		rod(Vector3(x,.7,.17),Vector3(x,1.12,.21),.022,"arch_walnut")
	rod(Vector3(-.17,1.12,.21),Vector3(.17,1.12,.21),.024,"arch_walnut")
	for i in 9:
		rod(Vector3(-.14+i*.035,.78,.19),Vector3(-.14+i*.035,1.1,.21),.006,"arch_cane")
	for i in 6:
		rod(Vector3(-.16,.8+i*.055,.195),Vector3(.16,.8+i*.055,.195),.005,"arch_rope")
	origin=previous_origin
	basis=previous_basis

func booth(at: Vector3,yaw_local: float,corner: bool) -> void:
	# Cane-sided sofa with a grey cushion; its back is against the partition wall.
	var previous_origin:=origin
	var previous_basis:=basis
	origin+=basis*at
	basis*=Basis(Vector3.UP,yaw_local)
	box(Vector3(0,.2,0),Vector3(1.35,.4,.6),"arch_walnut",true)
	box(Vector3(0,.46,0),Vector3(1.35,.13,.6),"arch_cushion")
	box(Vector3(0,.78,.31),Vector3(1.35,.5,.05),"arch_cane")
	box(Vector3(0,1.04,.31),Vector3(1.39,.05,.07),"arch_walnut")
	box(Vector3(0,.72,.24),Vector3(1.3,.38,.09),"arch_cushion")
	for i in 22:
		box(Vector3(-.63+i*.06,.78,.34),Vector3(.012,.46,.01),"arch_rope")
	for side in [-1,1]:
		box(Vector3(side*.69,.72,0),Vector3(.05,.5,.6),"arch_cane")
		box(Vector3(side*.69,.98,0),Vector3(.07,.05,.64),"arch_walnut")
		for i in 9:
			box(Vector3(side*.71,.72,-.27+i*.065),Vector3(.01,.46,.012),"arch_rope")
	if corner:
		box(Vector3(.95,.2,-.5),Vector3(.5,.4,.6),"arch_walnut",true)
		box(Vector3(.95,.46,-.5),Vector3(.5,.13,.6),"arch_cushion")
	seat(Vector3(0,0,0),0,.47,false)
	origin=previous_origin
	basis=previous_basis

func chair(at: Vector3,yaw_local: float,outdoor: bool) -> void:
	var previous_origin:=origin
	var previous_basis:=basis
	origin+=basis*at
	basis*=Basis(Vector3.UP,yaw_local)
	for x in [-.24,.24]:
		for z in [-.23,.23]:
			rod(Vector3(x*1.15,0,z*1.12),Vector3(x,.47,z),.018 if outdoor else .022,"arch_white" if outdoor else "arch_walnut")
	if outdoor:
		shape(Vector3(0,.46,0),Vector3(.5,.05,.5),"arch_white")
		for i in 14:
			var angle: float=lerpf(-PI*.12,PI*1.12,float(i)/13)
			var next: float=lerpf(-PI*.12,PI*1.12,float(i+1)/13)
			var p:=Vector3(cos(angle)*.3,.86,sin(angle)*.28)
			rod(p,Vector3(cos(next)*.3,.86,sin(next)*.28),.014,"arch_white")
			rod(Vector3(cos(angle)*.23,.46,sin(angle)*.23),p,.008,"arch_white")
	else:
		box(Vector3(0,.47,0),Vector3(.55,.10,.53),"arch_cushion")
		for x in [-.27,.27]:
			rod(Vector3(x,.4,.24),Vector3(x,.99,.30),.03,"arch_walnut")
			rod(Vector3(x,.72,-.25),Vector3(x,.74,.27),.027,"arch_walnut")
			rod(Vector3(x,.47,-.25),Vector3(x,.72,-.25),.024,"arch_walnut")
		for y in [.62,.96]:
			rod(Vector3(-.27,y,.28),Vector3(.27,y,.28),.027,"arch_walnut")
		for i in 13:
			var x: float=-.24+i*.04
			rod(Vector3(x,.63,.28),Vector3(x,.95,.28),.007,"arch_cane")
		for i in 9:
			rod(Vector3(-.24,.64+i*.037,.28),Vector3(.24,.64+i*.037,.28),.007,"arch_rope")
	origin=previous_origin
	basis=previous_basis
