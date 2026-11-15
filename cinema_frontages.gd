extends "res://heritage_kit.gd"
## Observed exterior details: designs/17-sector-2-central-spine/cinema-area.
## Pin is from Google Maps; compact footprint/height and plain lobby are approximations.
const CINESTAR_ID := -92001

static func prepare(data: Dictionary) -> void:
	for a in data.amenities:
		if int(a.get("osm_id",0))==CINESTAR_ID:return
	var a: Dictionary={"name":"Cinestar Multiplex","hindi":"सिनेस्टार सिनेमा","kind":"cinema","p":[-1742.13,-2769.93],"a":-.5,"w":22.0,"d":13.5,"front":1,"osm_id":CINESTAR_ID,"design":"cinestar_exterior","source":"Google Maps place and March 2026 exterior photos; approximate compact footprint","tags":{"amenity":"cinema"}}
	# Replace only overlapping generated infill. Never remove an imported named place.
	var kept: Array=[]
	for b in data.buildings:
		var relative:=Vector2(b.x-a.p[0],b.z-a.p[1]).rotated(a.a)
		var radius: float=sqrt(b.w*b.w+b.d*b.d)/2
		if b.get("source","")=="infill" and absf(relative.x)<a.w/2+radius and absf(relative.y)<a.d/2+radius:continue
		kept.append(b)
	data.buildings=kept
	data.buildings.append({"x":a.p[0],"z":a.p[1],"w":a.w,"d":a.d,"a":a.a,"h":13.8,"source":"reference-design","osm_id":CINESTAR_ID,"kind":"cinema"})
	data.amenities.append(a)

func cinestar(a: Dictionary) -> void:
	setup(a)
	if not world.mats.has("cinema_stone"):
		var mat:=StandardMaterial3D.new()
		mat.albedo_color=Color("c6977f")
		mat.roughness=.9
		mat.albedo_texture=mineral_texture()
		mat.uv1_triplanar=true
		mat.uv1_world_triplanar=true
		world.mats["cinema_stone"]=mat
	var f:=d/2
	var h:=13.8
	# Exterior shell with an accessible central threshold, without inventing an auditorium.
	box(Vector3(0,.25,0),Vector3(w,.5,d),"arch_step",true)
	box(Vector3(0,1.8,-f),Vector3(w,3.6,.22),"cinema_stone",true)
	for side in [-1,1]:
		box(Vector3(side*(w/2-.1),1.8,0),Vector3(.2,3.6,d),"cinema_stone",true)
		var bay: float=(w-2.8)/2
		box(Vector3(side*(1.4+bay/2),1.8,f),Vector3(bay,2.8,.12),"arch_glazing",true)
		for k in 5:
			box(Vector3(side*(1.4+bay*k/4),1.8,f+.09),Vector3(.06,2.8,.07),"arch_frame")
	box(Vector3(0,3.6,0),Vector3(w,.22,d),"cinema_stone",true)
	box(Vector3(0,8.7,-.25),Vector3(w,10,d-.5),"cinema_stone",true)
	# Broad pale gridded panels seen in the reference; clear separation around the columns.
	for side in [-1,1]:
		box(Vector3(side*w*.255,6.75,f+.04),Vector3(w*.39,5.85,.13),"arch_white")
		for k in 6:
			var x: float=side*w*.255-w*.195+k*w*.39/5
			box(Vector3(x,6.75,f+.13),Vector3(.035,5.85,.04),"arch_frame")
		for y in [4.6,5.7,6.8,7.9,9.0]:
			box(Vector3(side*w*.255,y,f+.14),Vector3(w*.39,.035,.04),"arch_frame")
		shape(Vector3(side*1.65,6.3,f+.36),Vector3(.36,6.2,.36),"heritage_gold")
		shape(Vector3(side*1.65,9.45,f+.36),Vector3(.8,.28,.8),"heritage_gold","cone")
	box(Vector3(0,7,f+.05),Vector3(2.8,4.1,.12),"heritage_ink")
	label(Vector3(0,7.2,f+.15),"CINEMA",.46,"arch_white",2.5)
	label(Vector3(0,6.4,f+.15),"JAIPUR",.29,"heritage_gold",2.5)
	# Four large circular upper openings with inset glazing, sill and horizontal railings.
	for x in [-w*.36,-w*.13,w*.13,w*.36]:
		round_opening(Vector3(x,11.55,f+.17),1.22)
	# Stone panel joints, parapet and original text-only rooftop sign.
	for y in [10.0,12.9,13.7]:
		box(Vector3(0,y,f+.025),Vector3(w,.025,.035),"heritage_lime")
	box(Vector3(0,h+.12,0),Vector3(w+.3,.24,d+.3),"heritage_lime")
	box(Vector3(w*.25,h+.78,f-.12),Vector3(w*.46,1.2,.2),"arch_white")
	label(Vector3(w*.25,h+.78,f+.02),"CINESTAR",.76,"heritage_red",w*.43)
	# Side arch motif and stacked landing bands observed beside the main entry.
	var sx:=w*.44
	for y in [1.2,4.3,7.4]:
		box(Vector3(sx,y+.8,f+.17),Vector3(w*.10,1.7,.12),"heritage_ink")
		arch(Vector3(sx,y,f+.28),w*.095,1.0,.65,"cinema_stone",.18,false)
		box(Vector3(sx,y-.1,f+.25),Vector3(w*.13,.18,.5),"heritage_lime")
	# Fascia text follows visible storefronts; no downloaded advertisements or logos.
	for sign in [[-w*.29,"PIZZA HUT","heritage_ink"],[0.0,"CINESTAR","heritage_gold"],[w*.27,"HDFC BANK","heritage_blue"]]:
		box(Vector3(sign[0],3.25,f+.15),Vector3(w*.29,.55,.2),sign[2])
		label(Vector3(sign[0],3.25,f+.28),sign[1],.33,"arch_white",w*.27)
	# The steps are kept within the frontage gap. A ramp collider supports walking.
	for i in 4:
		box(Vector3(0,.065*(i+1),f+1.05-i*.27),Vector3(3.0,.13*(i+1),.3),"arch_step")
	collision_ramp(0,f,2.8,1.3,.52)
	for side in [-1,1]:
		rod(Vector3(side*1.5,.6,f),Vector3(side*1.5,.95,f+1.2),.025,"arch_frame")
		for z in [f,f+1.2]:rod(Vector3(side*1.5,0,z),Vector3(side*1.5,.95,z),.025,"arch_frame")
	# Simple entrance vestibule; interior cinema layout has not been surveyed.
	box(Vector3(0,1.6,f-3.0),Vector3(4,3,.15),"heritage_ink",true)
	label(Vector3(0,2.1,f-2.9),"CINESTAR",.45,"arch_white",3.6)
	world.draw_detail=false

func round_opening(at: Vector3,radius: float) -> void:
	shape(at,Vector3(radius*1.93,.07,radius*1.93),"heritage_ink","cylinder",Basis(Vector3.RIGHT,PI/2))
	for i in 32:
		var t:=TAU*i/32
		var t2:=TAU*(i+1)/32
		rod(at+Vector3(cos(t)*radius,sin(t)*radius,.10),at+Vector3(cos(t2)*radius,sin(t2)*radius,.10),.06,"heritage_lime")
	for y in [-.45,-.18,.09]:
		var span:=sqrt(radius*radius-y*y)*2
		box(at+Vector3(0,y,.15),Vector3(span,.035,.05),"heritage_gold")
	box(at+Vector3(0,-.68,.06),Vector3(radius*1.65,.24,.24),"cinema_stone")
