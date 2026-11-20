extends "res://reference_building.gd"
## Game-authored campus architecture; imported names/pins are retained, not a survey.
func build(a: Dictionary) -> void:
	setup(a)
	var back: float=-d*.44
	var front: float=-d*.04
	var width: float=w*.88
	var depth: float=front-back
	var height:=9.6 if "college" in a.name.to_lower() else 7.0
	# Upper teaching block and open ground-floor reception, with a clear centre aisle.
	box(Vector3(0,.06,(back+front)/2),Vector3(width,.12,depth),"arch_step",true)
	box(Vector3(0,(height+3.1)/2,(back+front)/2),Vector3(width,height-3.1,depth),"cream",true)
	box(Vector3(0,1.55,back),Vector3(width,3.1,.22),"cream",true)
	for side in [-1,1]:
		box(Vector3(side*(width/2-.1),1.55,(back+front)/2),Vector3(.2,3.1,depth),"cream",true)
		box(Vector3(side*(width/4+.7),1.55,front),Vector3(width/2-1.4,3.1,.2),"cream",true)
		box(Vector3(side*1.4,1.5,front+.08),Vector3(.12,3,.15),"arch_teal",true)
	box(Vector3(0,3.2,front+.6),Vector3(width+.3,.2,1.5),"arch_teal")
	box(Vector3(0,height+.14,(back+front)/2),Vector3(width+.45,.28,depth+.45),"trim")
	for level in range(1,int(height/3)):
		var y:=3.5+level*2.6
		var count:=maxi(3,int(width/2.8))
		for i in count:
			var x: float=lerpf(-width/2+1.5,width/2-1.5,float(i)/(count-1))
			box(Vector3(x,y-.8,front+.14),Vector3(1.45,1.55,.08),"arch_glazing")
			box(Vector3(x,y-.8,front+.2),Vector3(.07,1.55,.07),"arch_frame")
			box(Vector3(x,y+.07,front+.35),Vector3(1.7,.14,.65),"trim")
	# Boundary has a real central opening, an unobstructed path and two gate leaves.
	var gate: float=d*.45
	box(Vector3(0,.04,(gate+front)/2),Vector3(3.2,.08,gate-front),"stone")
	for side in [-1,1]:
		box(Vector3(side*(w/2-.15),.6,0),Vector3(.3,1.2,d*.9),"cream",true)
		box(Vector3(side*(w/4+.8),.6,gate),Vector3(w/2-1.6,1.2,.3),"cream",true)
		box(Vector3(side*1.8,1.35,gate),Vector3(.4,2.7,.4),"arch_teal",true)
		for i in 10:
			box(Vector3(side*(2.2+i*.16),1.6,gate),Vector3(.035,1.1,.08),"arch_frame")
		pot(Vector3(side*2.6,0,front+1.0),1.7)
		var bench:=Vector3(side*w*.28,0,gate*.55)
		box(bench+Vector3(0,.5,0),Vector3(2,.12,.6),"wood")
		box(bench+Vector3(0,.85,.28),Vector3(2,.6,.09),"wood")
		for dx in [-.75,.75]:box(bench+Vector3(dx,.24,0),Vector3(.12,.48,.5),"metal")
		seat(bench,0,.56)
	label(Vector3(0,3.65,front+.2),a.name.to_upper(),.42,"arch_teal",width-.6)
	box(Vector3(0,1.4,back+.14),Vector3(3.5,1.2,.08),"arch_teal")
	label(Vector3(0,1.4,back+.21),"VISITOR RECEPTION",.25,"arch_white",3.2)
	box(Vector3(-width*.28,.62,back+1),Vector3(2,1.1,.65),"wood",true)
	world.place_interactions.append({"name":a.name,"kind":"school","p":origin+basis*Vector3(0,.12,front+1),"description":"Campus courtyard and visitor reception. Teaching rooms are not open in this build."})
	world.draw_detail=false
