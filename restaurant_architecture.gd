extends "res://heritage_kit.gd"
## Three original designs placed at existing OSM restaurants; not surveyed replicas.
const GROUND := .12
var accent: String
func build(a: Dictionary) -> void:
	setup(a)
	var style: int=int(a.get("design_style",absi(int(a.get("osm_id",0)))%3))
	if "Thali" in a.name or "Bhoj" in a.name: style=0
	if a.name=="Kalidoscope": style=1
	if a.name=="Spicy King": style=2
	accent=["heritage_red","heritage_blue","arch_green"][style]
	var wall: String="heritage_rose" if style==0 else "heritage_lime"
	var f:=d/2
	var small:=w<6.5
	var ceiling:=3.5
	# A real room, not a solid box with a dark rectangle pasted on its front.
	box(Vector3(0,GROUND/2,0),Vector3(w,GROUND,d),"heritage_tile",true)
	box(Vector3(0,1.8,-f),Vector3(w,3.6,.22),wall,true)
	for side in [-1,1]:
		box(Vector3(side*w/2,1.8,0),Vector3(.22,3.6,d),wall,true)
		box(Vector3(side*(w/2-.12),.45,0),Vector3(.035,.65,d-.2),accent)
	box(Vector3(0,ceiling+.08,0),Vector3(w+.35,.16,d+.2),"heritage_lime",true)
	box(Vector3(0,ceiling+.24,f+.1),Vector3(w+.55,.16,.7),"heritage_lime")
	# Facade arcades and glass side bays leave the centre doorway open.
	var bays:=1 if small else 3
	var bay_width: float=(w-.6)/bays
	for i in bays:
		var x: float=(i-(bays-1)/2.0)*bay_width
		arch(Vector3(x,GROUND,f),bay_width-.4,2.0,.95,"heritage_lime",.32)
		shape(Vector3(x,GROUND+2.0,f-.1),Vector3(bay_width-.4,1.9,.16),wall,"arch_fill")
		if i!=bays/2:
			box(Vector3(x,1.3,f-.12),Vector3(bay_width-.45,2.35,.035),"arch_glass",true)
			box(Vector3(x,1.3,f-.08),Vector3(.055,2.35,.06),accent)
			box(Vector3(x,.46,f+.06),Vector3(bay_width-.35,.65,.16),accent,true)
			jali(Vector3(x,.48,f+.17),bay_width-.55,.45,"heritage_gold")
		lantern(Vector3(x+bay_width*.43,2.45,f+.25))
	# A shallow raised terrace with an unobstructed centre approach.
	box(Vector3(0,.04,f+.6),Vector3(w+.5,.08,1.35),"arch_step",true)
	collision_ramp(0,f,2.0,1.2,GROUND+.015)
	for side in [-1,1]:
		palm(Vector3(side*(w/2-.45),.08,f+.6),.95)
	# Upper-floor silhouette differentiates the three restaurant families.
	if style==0:
		box(Vector3(0,4.65,-.25),Vector3(w,2.5,d-.5),wall,true)
		for x in [-w*.29,0.0,w*.29]:
			framed_window(Vector3(x,3.9,f-.48),minf(1.35,w*.18),1.55)
		box(Vector3(0,5.98,0),Vector3(w+.5,.18,d+.3),"heritage_lime")
		for i in int(w/.5):
			shape(Vector3(-w/2+.25+i*.5,6.13,f-.08),Vector3(.25,.3,.25),"heritage_lime","dome")
		pavilion(Vector3(0,6.08,-.35),minf(w*.31,2.8))
	elif style==1:
		# A garden pavilion: open roof pergola and blue parapet, no fake inaccessible dining deck.
		for x in [-w/2+.3,w/2-.3]:
			box(Vector3(x,3.95,0),Vector3(.14,.85,d),accent)
		for i in range(int(w/.4)):
			box(Vector3(-w/2+.2+i*.4,4.4,0),Vector3(.1,.16,d+.6),"arch_walnut")
		box(Vector3(0,3.95,-f),Vector3(w,.8,.18),accent)
	else:
		# Modern brasserie: ribbed timber fascia, canvas awning, offset clerestory.
		box(Vector3(-w*.15,4.15,-.7),Vector3(w*.7,1.1,d*.65),"arch_plaster",true)
		for i in int(w/.2):
			box(Vector3(-w/2+.1+i*.2,3.85,f+.12),Vector3(.09,.5,.16),"arch_walnut")
		box(Vector3(0,3.13,f+.55),Vector3(w-.2,.08,1.2),accent,false,Basis(Vector3.RIGHT,.1))
		for i in int(w/.4):
			box(Vector3(-w/2+.2+i*.4,3.02,f+1.12),Vector3(.18,.18,.04),"heritage_lime")
	# In-world signs at architectural scale; long real names fit one restrained fascia.
	box(Vector3(0,3.46,f+.33),Vector3(w*.86,.5,.11),accent)
	var title: String=a.name.to_upper() if a.name!="" else ["GULABI RASOI","NEEL ANGAN","SAHAR KITCHEN"][style]
	label(Vector3(0,3.46,f+.41),title,.31,"heritage_lime",w*.8)
	# Patterned floor in metre-sized tiles, plus a solid perimeter border.
	detail=true
	var cols:=maxi(1,int((w-.4)/.65))
	var rows:=maxi(1,int((d-.4)/.65))
	for x in cols:
		for z in rows:
			if (x+z)%2==0:
				box(Vector3(-w/2+.2+(x+.5)*(w-.4)/cols,GROUND+.009,-f+.2+(z+.5)*(d-.4)/rows),Vector3((w-.4)/cols-.015,.012,(d-.4)/rows-.015),"heritage_ink" if style==1 else "heritage_lime")
	# Timber service counter, stone top, back-bar shelves and ceramic tableware.
	var counter_w: float=w*.62
	box(Vector3(0,GROUND+.5,-f+1.05),Vector3(counter_w,1,.7),accent,true)
	for i in int(counter_w/.16):
		box(Vector3(-counter_w/2+.08+i*.16,GROUND+.5,-f+1.41),Vector3(.06,.9,.03),"heritage_gold" if style==1 else "arch_walnut")
	box(Vector3(0,GROUND+1.04,-f+1.05),Vector3(counter_w+.12,.08,.85),"arch_quartz",true)
	label(Vector3(0,2.7,-f+.15),["DAL  /  BAATI  /  CHURMA","THE GARDEN TABLE","FRESH FROM THE KITCHEN"][style],.18,"heritage_lime" if style==0 else accent,w*.78)
	for y in [1.65,2.15]:
		box(Vector3(0,y,-f+.22),Vector3(counter_w,.06,.4),"arch_walnut")
		for i in 6:
			var x: float=-counter_w*.4+i*counter_w*.16
			shape(Vector3(x,y+.12,-f+.2),Vector3(.13,.2,.13),"arch_white","pot")
	# Keep a clear 1.5 m central aisle; furniture adapts to narrow mapped plots.
	var table_x: float=w*.29
	var table_rows:=1 if d<6.5 else 2
	for side in [-1,1]:
		for row in table_rows:
			var z: float=f-1.7-row*2.3
			var at:=Vector3(side*table_x,GROUND,z)
			table(at,false)
			flowers(at+Vector3(.12,.8,.22))
			for end in [-1,1]:
				var sit_at:=at+Vector3(0,0,end*.86)
				var turn:=0.0 if end>0 else PI
				chair(sit_at,turn,false)
				seat(sit_at,turn,.47,end<0 and row==0)
			shape(at+Vector3(0,2.52,0),Vector3(.48,.28,.48),"arch_cane","cone")
			rod(at+Vector3(0,2.66,0),at+Vector3(0,3.35,0),.013,"heritage_ink")
			spot(at+Vector3(0,2.39,0),.12)
		light(Vector3(side*w*.25,2.9,0),.65,5)
	# Wall panelling and planted rear corners make the room read from the street.
	for side in [-1,1]:
		palm(Vector3(side*(w/2-.6),GROUND,-f+.55),1.1)
		for z in [-d*.15,d*.2]:
			box(Vector3(side*(w/2-.13),1.9,z),Vector3(.03,1.2,.9),accent)
			for k in 5:
				box(Vector3(side*(w/2-.15),1.9,z-.36+k*.18),Vector3(.025,1.05,.025),"heritage_gold")
	detail=false
	world.draw_detail=false
	world.restaurant_entries.append({"name":a.name,"origin":origin,"basis":basis,"w":w,"d":d,"style":style,"floor":GROUND})
