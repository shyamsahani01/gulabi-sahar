extends "res://reference_building.gd"
## Permanent storefront from the user's three photographs (opening-day balloons omitted).
const FLOOR := .75
func build(a: Dictionary) -> void:
	setup(a)
	var f:=d/2
	var door: float=-w*.25
	var split: float=w*.10
	var room: float=w*.56
	# Pink upper storey, black surround and a recessed cafe below.
	box(Vector3(0,.375,0),Vector3(w,.75,d),"arch_step",true)
	box(Vector3(0,2.28,-f),Vector3(w,3.1,.2),"arch_plaster",true)
	for side in [-1,1]:
		box(Vector3(side*w/2,2.3,0),Vector3(.2,3.1,d),"arch_plaster",true)
		box(Vector3(side*(w/2-.12),2.3,f),Vector3(.25,3.1,.36),"arch_black",true)
	box(Vector3(0,3.88,0),Vector3(w+.25,.18,d+.3),"arch_white",true)
	box(Vector3(0,5.1,-.15),Vector3(w,2.3,d-.3),"rose",true)
	box(Vector3(0,6.28,0),Vector3(w+.3,.16,d+.2),"arch_step")
	for x in [-w*.30,w*.30]:
		box(Vector3(x,5.25,f-.27),Vector3(1.65,1.4,.12),"arch_walnut")
		box(Vector3(x,5.25,f-.19),Vector3(1.4,1.2,.05),"arch_glazing")
		box(Vector3(x,5.25,f-.14),Vector3(.055,1.2,.06),"arch_frame")
	box(Vector3(0,3.98,f+.24),Vector3(w+.55,.88,.58),"arch_black")
	label(Vector3(.65,3.98,f+.55),(a.name if a.name!="" else "COFFEE HOUSE").to_upper(),.72,"arch_white",w-2)
	# Framed logo plaque on the far left of the fascia.
	box(Vector3(-w/2+.7,3.98,f+.55),Vector3(1.05,.68,.04),"arch_white")
	box(Vector3(-w/2+.7,3.98,f+.58),Vector3(.99,.62,.04),"arch_black")
	label(Vector3(-w/2+.7,4.1,f+.62),"CRAZY" if a.name=="Crazy Coffee" else "FRESH",.19,"arch_white",.9)
	label(Vector3(-w/2+.7,3.86,f+.62),"COFFEE",.19,"arch_white",.9)
	box(Vector3(split,2.22,f),Vector3(.65,3,.34),"arch_black",true)
	# Continuous glass grid with a real left-side entry gap.
	glazing(-w/2+.22,door-.8,f)
	glazing(door+.8,split-.34,f)
	glazing(split+.34,w/2-.22,f)
	# Door held open against its reveal, stainless pull handle.
	box(Vector3(door-.78,2.12,f-.7),Vector3(.035,2.7,1.38),"arch_glass")
	rod(Vector3(door-.75,1.7,f-.9),Vector3(door-.75,2.15,f-.9),.018,"chrome")
	# Five shallow treads on the left; a continuous collision ramp covers the risers.
	box(Vector3(0,.025,f+1.55),Vector3(w+.8,.05,3.2),"arch_step",true)
	for i in 5:
		box(Vector3(door,.075*(i+1),f+2.1-i*.42),Vector3(2.5,.15*(i+1),.44),"arch_step")
		box(Vector3(door,.15*(i+1)+.006,f+2.30-i*.42),Vector3(2.5,.02,.045),"arch_white")
	collision_ramp(door,f,2.5,2.5,FLOOR+.04)
	detail=true
	for side in [-1,1]:
		for i in 4:
			pot(Vector3(door+side*1.46,.15*i,f+2.1-i*.5),.8)
	# Right terrace has round wooden tables, green rope chairs and a white fence.
	var terrace_x: float=w*.30
	box(Vector3(terrace_x,.065,f+1.3),Vector3(w*.37,.06,2.6),"arch_turf")
	for z in [f+.1,f+2.6]:
		for i in 14:
			var x: float=split+.5+i*(w*.36)/13
			rod(Vector3(x,.1,z),Vector3(x,1.05,z+.08),.018,"arch_white")
		rod(Vector3(split+.5,.84,z),Vector3(w/2+.1,.84,z),.026,"arch_white")
	for z in [f+.8,f+1.9]:
		pot(Vector3(w/2-.1,.08,z),1.0)
	table(Vector3(terrace_x,.1,f+1.3),true)
	chair(Vector3(terrace_x-.75,.1,f+1.3),-PI/2,true)
	chair(Vector3(terrace_x+.75,.1,f+1.3),PI/2,true)
	# Wood floorboards, pale plaster, long left counter and right cane-backed seating.
	for i in range(int(w/.24)):
		box(Vector3(-w/2+.13+i*.24,FLOOR+.012,0),Vector3(.232,.024,d-.2),"arch_oak")
	# Partition makes the photographed narrow seating room, with a passage at the back.
	box(Vector3(split,2.25,d*.06),Vector3(.13,3,d*.7),"arch_plaster",true)
	for z in [-d*.27,d*.02,d*.27]:
		box(Vector3(-w/2+.57,FLOOR+.77,z),Vector3(.96,.075,1.25),"arch_walnut",true)
		rod(Vector3(-w/2+.30,FLOOR+.05,z),Vector3(-w/2+.30,FLOOR+.75,z),.035,"arch_black")
		chair(Vector3(-w/2+1.34,FLOOR,z),PI/2,false)
		table(Vector3(split-1.13,FLOOR,z),false)
		chair(Vector3(split-.52,FLOOR,z),-PI/2,false)
	# Cane wall panels with a dark border and woven inset.
	for z in [-d*.2,d*.22]:
		box(Vector3(split-.09,2.55,z),Vector3(.09,.56,d*.32),"arch_walnut")
		box(Vector3(split-.15,2.55,z),Vector3(.025,.44,d*.29),"arch_cane")
		for i in 20:
			box(Vector3(split-.17,2.55,z-d*.145+i*d*.29/19),Vector3(.01,.44,.012),"arch_rope")
	label(Vector3(door,2.55,-f+.14),"Espresso Yourself",.42,"arch_neon",room-.4,true)
	label(Vector3(-w/2+.7,2.6,-f+.16),"COFFEE",.16,"arch_walnut",1.1)
	# Second bay has a coffee counter visible through the front glazing.
	box(Vector3(w*.30,1.25,-d*.2),Vector3(w*.31,1.0,.7),"arch_walnut",true)
	box(Vector3(w*.30,1.79,-d*.2),Vector3(w*.33,.08,.8),"arch_step")
	box(Vector3(w*.31,2.05,-d*.2),Vector3(.65,.43,.4),"arch_black")
	for x in [w*.24,w*.35]:
		shape(Vector3(x,1.88,-d*.2+.3),Vector3(.12,.13,.12),"arch_white")
	for x in [door,w*.30]:
		for z in [-d*.25,d*.25]:
			shape(Vector3(x,3.76,z),Vector3(.15,.025,.15),"arch_neon")
		shape(Vector3(x,3.52,f+.27),Vector3(.15,.025,.15),"arch_neon")
	for z in [-d*.2,d*.22]:
		box(Vector3(split-.22,3.05,z),Vector3(.22,.12,.15),"arch_black")
		shape(Vector3(split-.22,2.96,z),Vector3(.17,.1,.17),"arch_black","pot")
		shape(Vector3(split-.22,2.9,z),Vector3(.15,.02,.15),"arch_neon")
	light(Vector3(door,3,-d*.2),.9,5)
	light(Vector3(w*.27,3,d*.15),.6,4)
	detail=false
	world.draw_detail=false
func glazing(left: float,right: float,z: float) -> void:
	if right-left<.1:
		return
	box(Vector3((left+right)/2,2.15,z),Vector3(right-left,2.8,.028),"arch_glass",true)
	var columns:=maxi(1,roundi((right-left)/.65))
	for i in range(columns+1):
		box(Vector3(lerpf(left,right,float(i)/columns),2.15,z+.025),Vector3(.045,2.8,.055),"arch_frame")
	for y in [.77,1.36,1.95,2.54,3.13,3.55]:
		box(Vector3((left+right)/2,y,z+.025),Vector3(right-left,.045,.055),"arch_frame")
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
	shape(at+Vector3(.25,.91,.18),Vector3(.075,.22,.075),"arch_glass")
	shape(at+Vector3(.25,1.04,.18),Vector3(.035,.05,.035),"arch_glass")
func chair(at: Vector3,yaw: float,outdoor: bool) -> void:
	var previous_origin:=origin
	var previous_basis:=basis
	origin+=basis*at
	basis*=Basis(Vector3.UP,yaw)
	for x in [-.24,.24]:
		for z in [-.23,.23]:
			rod(Vector3(x*1.15,0,z*1.12),Vector3(x,.47,z),.022,"arch_black" if outdoor else "arch_walnut")
	if outdoor:
		shape(Vector3(0,.46,0),Vector3(.56,.10,.56),"arch_green")
		for i in 14:
			var angle: float=lerpf(-PI*.12,PI*1.12,float(i)/13)
			var next: float=lerpf(-PI*.12,PI*1.12,float(i+1)/13)
			var p:=Vector3(cos(angle)*.32,.83,sin(angle)*.30)
			rod(p,Vector3(cos(next)*.32,.83,sin(next)*.30),.019,"arch_rope")
			rod(Vector3(cos(angle)*.24,.46,sin(angle)*.24),p,.009,"arch_rope")
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
