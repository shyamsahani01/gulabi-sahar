extends "res://reference_building.gd"
## A readable, enterable hospital/clinic type; names and locations stay in map data.
func build(a: Dictionary) -> void:
	setup(a)
	var clinic: bool=w<16 or "clinic" in a.name.to_lower() or a.get("tags",{}).get("amenity","")=="clinic"
	var floors:=2 if clinic else 4
	var height: float=floors*3.0
	var front: float=d*.28
	var back: float=-d*.43
	var span: float=front-back
	var bw: float=w*.84
	var entrance_width: float=minf(2.8,bw*.38)
	# Solid upper floors with separate ground-floor walls leave a usable reception.
	box(Vector3(0,.06,(front+back)/2),Vector3(bw,.12,span),"arch_white",true)
	box(Vector3(0,(height+3.2)/2,(front+back)/2),Vector3(bw,height-3.2,span),"arch_white",true)
	box(Vector3(0,1.65,back),Vector3(bw,3.3,.2),"arch_white",true)
	for side in [-1,1]:
		box(Vector3(side*(bw/2-.1),1.65,(front+back)/2),Vector3(.2,3.3,span),"arch_white",true)
		var bay: float=(bw-entrance_width)/2
		box(Vector3(side*(entrance_width/2+bay/2),1.55,front),Vector3(bay,2.85,.045),"arch_glass",true)
		box(Vector3(side*entrance_width/2,1.55,front+.04),Vector3(.075,2.85,.1),"arch_frame")
	# Teal vertical service tower and framed windows across each ward floor.
	box(Vector3(-bw*.37,height/2,front+.08),Vector3(bw*.18,height,.28),"arch_teal")
	var columns:=maxi(2,int(bw/2.8))
	for floor_index in range(1,floors):
		var y: float=3.45+floor_index*2.8
		box(Vector3(0,y-1.25,front+.14),Vector3(bw,.16,.4),"arch_step")
		for i in columns:
			var x: float=lerpf(-bw*.18,bw*.38,float(i)/maxi(1,columns-1))
			var width: float=minf(1.7,bw*.50/columns)
			box(Vector3(x,y-.35,front+.12),Vector3(width,1.55,.07),"arch_glazing")
			box(Vector3(x,y-.35,front+.18),Vector3(.045,1.55,.06),"arch_white")
			box(Vector3(x,y+.47,front+.24),Vector3(width+.2,.13,.42),"arch_white")
	box(Vector3(0,height+.12,(front+back)/2),Vector3(bw+.4,.24,span+.4),"arch_white")
	box(Vector3(-bw*.37,height-.85,front+.28),Vector3(.9,.22,.1),"arch_white")
	box(Vector3(-bw*.37,height-.85,front+.28),Vector3(.22,.9,.1),"arch_white")
	# Recessed entry with cantilever canopy, red emergency band and columns.
	var canopy: float=minf(6,bw*.62)
	box(Vector3(0,3.18,front+1.1),Vector3(canopy,.18,2.7),"arch_white")
	box(Vector3(0,3.24,front+2.48),Vector3(canopy,.36,.14),"arch_teal" if clinic else "arch_red")
	label(Vector3(0,3.25,front+2.58),"RECEPTION" if clinic else "EMERGENCY",.30,"arch_white",canopy-.25)
	for side in [-1,1]:
		box(Vector3(side*(canopy/2-.15),1.55,front+2.22),Vector3(.17,3.1,.17),"arch_step",true)
	box(Vector3(0,.035,front+1.4),Vector3(canopy,.07,2.8),"arch_step",true)
	box(Vector3(0,4.0,front+.28),Vector3(bw*.95,.78,.15),"arch_white")
	label(Vector3(0,4.02,front+.39),(a.name if a.name!="" else "CITY CLINIC" if clinic else "CITY HOSPITAL").to_upper(),.42,"arch_teal",bw*.9)
	detail=true
	# Reception desk and a clean central aisle, visible from the street.
	box(Vector3(0,.65,back+1),Vector3(bw*.48,1.05,.7),"arch_teal",true)
	box(Vector3(0,1.22,back+1),Vector3(bw*.51,.08,.8),"arch_white")
	box(Vector3(.3,1.5,back+.9),Vector3(.38,.3,.04),"arch_black")
	label(Vector3(0,2.2,back+.15),"RECEPTION  +  CARE",.26,"arch_teal",bw*.8)
	for side in [-1,1]:
		for i in 3:
			var z: float=lerpf(back+1.6,front-.65,float(i)/2)
			var x: float=side*(bw/2-.65)
			box(Vector3(x,.53,z),Vector3(.6,.12,.56),"arch_teal",true)
			box(Vector3(x, .88,z+.25),Vector3(.6,.6,.07),"arch_teal")
			for dx in [-.23,.23]:
				rod(Vector3(x+dx,.1,z),Vector3(x+dx,.48,z),.02,"chrome")
		pot(Vector3(side*(bw/2-.4),.05,front+.7),1.2)
		shape(Vector3(side*(entrance_width/2+.2),2.92,front+1.1),Vector3(.18,.04,.18),"arch_neon")
	for x in range(-int(bw/2)+1,int(bw/2)):
		box(Vector3(x,.124,(front+back)/2),Vector3(.012,.003,span),"arch_seam")
	for z in range(int(back)+1,int(front)+1):
		box(Vector3(0,.124,z),Vector3(bw,.003,.012),"arch_seam")
	if not clinic:
		label(Vector3(bw*.29,2.4,front+.12),"24 H\nCARE",.27,"arch_teal",bw*.22)
	light(Vector3(0,2.75,(front+back)/2),.45,minf(bw,7))
	world.place_interactions.append({"name":a.name if a.name!="" else "City Clinic","kind":"hospital","p":origin+basis*Vector3(0,.12,back+2.1),"description":"Reception · first aid restores your health and stamina for Rs 25."})
	detail=false
	world.draw_detail=false
