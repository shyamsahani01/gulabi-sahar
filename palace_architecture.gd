extends "res://heritage_kit.gd"
## Jaipur-inspired palace courtyard at the existing Nahargarh destination.
## An authored game environment, not an architectural reconstruction of Madhavendra Bhawan.
const FLOOR_LEVEL := .18
func build_palace(p: Vector3) -> void:
	origin=p+Vector3(45,0,0)
	origin.y=world.terrain_height(origin.x,origin.z)
	basis=Basis(Vector3.UP,-PI/2) # Gate faces the existing road and atlas arrival.
	w=48
	d=48
	box(Vector3(0,-.16,0),Vector3(49,.68,49),"heritage_lime",true)
	# Inlaid courtyard: generous walking routes, fountain on the centre axis.
	box(Vector3(0,FLOOR_LEVEL+.01,0),Vector3(46,.02,46),"heritage_tile")
	for x in [-16.0,16.0]:
		box(Vector3(x,.2,0),Vector3(.22,.025,46),"heritage_rose")
	for z in [-16.0,16.0]:
		box(Vector3(0,.2,z),Vector3(46,.025,.22),"heritage_rose")
	for side in [-1,1]:
		# Side galleries: solid perimeter, open courtyard-facing arcade, roof terrace.
		box(Vector3(side*24,3.4,0),Vector3(.65,6.8,48),"heritage_rose",true)
		box(Vector3(side*20.5,5.35,0),Vector3(7.4,.3,48),"heritage_lime",true)
		box(Vector3(side*20.5,6.0,-23.7),Vector3(7.4,1.0,.3),"heritage_rose")
		for i in 7:
			var z: float=-18+i*6
			var saved_origin:=origin
			var saved_basis:=basis
			origin+=basis*Vector3(side*17,.18,z)
			basis*=Basis(Vector3.UP,-side*PI/2)
			arch(Vector3.ZERO,4.7,3.1,1.55,"heritage_lime",.5)
			shape(Vector3(0,3.1,-.12),Vector3(4.7,3.1,.28),"heritage_rose","arch_fill")
			origin=saved_origin
			basis=saved_basis
			box(Vector3(side*17,5.85,z),Vector3(.18,.75,5.8),"heritage_lime")
		# Front wings frame a genuinely open gate, not a painted doorway.
		box(Vector3(side*15,3.1,23.8),Vector3(18,6.2,.7),"heritage_rose",true)
		box(Vector3(side*15,6.3,23.8),Vector3(18.8,.25,1.3),"heritage_lime")
		for x in [side*9.5,side*15.0,side*20.5]:
			framed_window(Vector3(x,2.1,24.2),1.5,2.6)
		pavilion(Vector3(side*20.5,6.5,21),4.3)
	# Gatehouse, carved arch and timber doors opened against the gate cheeks.
	arch(Vector3(0,.18,24),7.8,4.1,2.7,"heritage_lime",1.1)
	shape(Vector3(0,4.28,23.8),Vector3(7.8,5.4,.55),"heritage_rose","arch_fill")
	for side in [-1,1]:
		box(Vector3(side*5,4.0,23.8),Vector3(2.2,8,2.8),"heritage_rose",true)
		box(Vector3(side*3.95,2.0,22.25),Vector3(.14,3.6,3),"arch_walnut",true)
		for j in 6:
			box(Vector3(side*4.04,.5+j*.55,22.25),Vector3(.035,.06,2.8),"heritage_gold")
		lantern(Vector3(side*5,3.6,25.25))
		light(Vector3(side*4,3,24.8),.8,6)
	box(Vector3(0,8.05,23.8),Vector3(12.5,.3,3.6),"heritage_lime")
	box(Vector3(0,7.3,25.28),Vector3(6,.65,.16),"heritage_red")
	label(Vector3(0,7.3,25.4),"NAHARGARH",.47,"heritage_lime",5.5)
	pavilion(Vector3(0,8.2,23.8),3.6)
	collision_ramp(0,24,7.4,3.0,FLOOR_LEVEL+.02)
	box(Vector3(0,.04,26),Vector3(9,.08,3.8),"arch_step",true)
	# Main palace: deep ground-floor loggia, upper jharokha rhythm, layered cornices.
	box(Vector3(0,4.8,-23.7),Vector3(48,9.6,.6),"heritage_rose",true)
	box(Vector3(0,7.5,-20),Vector3(34,4.2,7),"heritage_rose",true)
	box(Vector3(0,5.35,-19.5),Vector3(36,.3,8.4),"heritage_lime",true)
	box(Vector3(0,9.7,-20),Vector3(36,.25,8),"heritage_lime")
	for i in 7:
		var x: float=(i-3)*4.8
		arch(Vector3(x,.18,-15.6),4.05,3.15,1.55,"heritage_lime",.5)
		shape(Vector3(x,3.33,-15.75),Vector3(4.05,3.1,.24),"heritage_rose","arch_fill")
		framed_window(Vector3(x,6.0,-16.42),1.65,2.65)
		box(Vector3(x,5.7,-15.9),Vector3(2.4,.25,1.3),"heritage_lime")
		jali(Vector3(x,6.1,-15.3),2.1,.65)
		lantern(Vector3(x,2.65,-23.3))
		if i%2==0: light(Vector3(x,3.8,-19.2),.7,6)
	for x in [-13.5,13.5]:
		pavilion(Vector3(x,9.85,-20),4.1)
	pavilion(Vector3(0,9.85,-20),5.1)
	# Central fountain with stone coping, water, tiered bowls, and fine water streams.
	shape(Vector3(0,.32,0),Vector3(5.8,.28,5.8),"heritage_lime")
	shape(Vector3(0,.47,0),Vector3(5.35,.14,5.35),"heritage_blue")
	shape(Vector3(0,.55,0),Vector3(5.08,.02,5.08),"heritage_water")
	shape(Vector3(0,.58,0),Vector3(.7,1.25,.7),"heritage_lime","column")
	shape(Vector3(0,1.84,0),Vector3(1.8,.24,1.8),"heritage_lime","pot")
	shape(Vector3(0,1.97,0),Vector3(1.65,.02,1.65),"heritage_water")
	shape(Vector3(0,2.02,0),Vector3(.25,.6,.25),"heritage_gold","cone")
	# A simple solid base prevents walking through the fountain.
	box(Vector3(0,.25,0),Vector3(4.1,.5,4.1),"heritage_lime",true)
	# Basin collision is hidden below the water; restore visible circular water above it.
	detail=true
	for i in 12:
		var a: float=i*TAU/12
		rod(Vector3(cos(a)*.7,1.92,sin(a)*.7),Vector3(cos(a)*1.6,.58,sin(a)*1.6),.012,"heritage_water")
	for side in [-1,1]:
		for z in [-9.0,9.0]:
			var at:=Vector3(side*10,.2,z)
			box(at+Vector3(0,.22,0),Vector3(5,.44,3.5),"heritage_lime",true)
			box(at+Vector3(0,.46,0),Vector3(4.7,.06,3.2),"arch_soil")
			for k in 6:
				shape(at+Vector3(-2+k*.8,.75,0),Vector3(1.1,.8,2.6),"arch_leaf_dark","sphere")
			date_palm(at+Vector3(0,.5,0),1.2)
			var bench:=Vector3(side*14,.18,z)
			box(bench+Vector3(0,.22,0),Vector3(1,.44,2.8),"heritage_lime",true)
			box(bench+Vector3(0,.48,0),Vector3(1,.1,2.8),"heritage_red")
			for k in [-.65,.65]:
				seat(bench+Vector3(0,0,k),side*PI/2,.53)
	# Cypresses outside the side wings break up the bare hillside silhouette.
	for side in [-1,1]:
		for z in [-20.0,-7.0,7.0,20.0]:
			var at:=Vector3(side*28,0,z)
			var point: Vector3=origin+basis*at
			at.y=world.terrain_height(point.x,point.z)-origin.y
			rod(at,at+Vector3(0,3.4,0),.12,"arch_walnut")
			for k in 3:
				shape(at+Vector3(0,2+k*.8,0),Vector3(1.8-k*.35,2.8-k*.4,1.8-k*.35),"arch_leaf_dark","sphere")
	# Courtyard lamps and gallery seats continue the café's human-scale detail language.
	for x in [-21.0,21.0]:
		for z in [-12.0,0.0,12.0]:
			palm(Vector3(x,.18,z),2.0)
	for x in [-10.0,10.0]:
		booth(Vector3(x,.18,-22.7),0,false)
	detail=false
	world.draw_detail=false
	world.palace_entry={"origin":origin,"basis":basis,"floor":FLOOR_LEVEL}
