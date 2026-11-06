extends RefCounted
## Screenshot-derived architecture; dimensions are an artistic reconstruction.
var world: Node3D
var origin: Vector3
var basis: Basis
var w: float
var d: float
func box(at: Vector3, size: Vector3, material: String, solid := false) -> void:
	world.box(origin+basis*at,size,material,solid,Vector3(0,basis.get_euler().y,0))
func text(at: Vector3, value: String, size: int, color := Color.WHITE) -> void:
	var label := Label3D.new()
	label.text=value
	var font := FontVariation.new()
	font.base_font=world.hindi_font
	font.variation_embolden=1.2 if size>=70 else 0.0
	label.font=font
	label.font_size=size
	label.pixel_size=.008
	label.modulate=color
	label.outline_size=0
	if size>=70:
		label.scale.x=minf(2.4,(w-2.3)/maxf(.1,font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x*.008))
	label.position=origin+basis*at
	label.rotation.y=basis.get_euler().y
	label.visibility_range_end=95
	world.cell(origin).add_child(label)
func build(a: Dictionary) -> void:
	origin=Vector3(a.p[0],world.terrain_height(a.p[0],a.p[1]),a.p[1])
	basis=Basis(Vector3.UP,a.a+(PI if a.get("front",1)<0 else 0))
	w=a.w
	d=a.d
	var f:=d/2
	box(Vector3(0,.035,f+1.6),Vector3(w+.5,.07,3.2),"cafe_plaster",true)
	# Raised wood floor, gray walls and an open central entrance.
	box(Vector3(0,.225,0),Vector3(w,.45,d),"cafe_wood",true)
	box(Vector3(0,2.4,-f),Vector3(w,3.9,.2),"cafe_plaster",true)
	for side in [-1,1]:
		box(Vector3(side*w/2,2.4,0),Vector3(.2,3.9,d),"cafe_plaster",true)
		box(Vector3(side*(w/2-.18),2.4,f),Vector3(.36,4,.4),"cafe_charcoal",true)
	box(Vector3(0,4.5,0),Vector3(w+.3,.25,d+.4),"cream",true)
	# Wide matte black fascia with large, white raised lettering.
	box(Vector3(0,4.05,f+.18),Vector3(w+.65,.95,.48),"cafe_charcoal")
	text(Vector3(.4,4.07,f+.44),(a.name if a.name != "" else "COFFEE HOUSE").to_upper(),100)
	text(Vector3(-w*.41,4.07,f+.45),"CRAZY\nCOFFEE" if a.name == "Crazy Coffee" else "COFFEE",21)
	# Glazing has an actual 2.4 m opening, with a square metal grid.
	var bay: float=(w-2.4)/2
	for side in [-1,1]:
		var cx: float=side*(1.2+bay/2)
		box(Vector3(cx,2.05,f),Vector3(bay,3.1,.035),"shop_glass",true)
		for i in range(5):
			box(Vector3(side*(1.2+bay*i/4),2.05,f+.035),Vector3(.055,3.15,.065),"cafe_frame")
		for y in [1.05,1.8,2.55,3.5]:
			box(Vector3(cx,y,f+.04),Vector3(bay,.055,.07),"cafe_frame")
		box(Vector3(side*1.2,2.05,f),Vector3(.075,3.1,.12),"cafe_frame")
	# Three shallow steps and pots flank the unobstructed approach.
	for i in range(3):
		box(Vector3(0,.075*(i+1),f+1.5-i*.5),Vector3(2.8,.15*(i+1),.5),"stone",true)
	for side in [-1,1]:
		for i in range(3):
			var at:=Vector3(side*1.7,.15+i*.15,f+1.5-i*.5)
			box(at+Vector3(0,.18,0),Vector3(.38,.36,.38),"white",true)
			world.round_prop(origin+basis*(at+Vector3(0,.63,0)),Vector3(.45,.6,.45),"leaves")
		# Green terrace, white picket edge, timber tables and green seating.
		box(Vector3(side*(w/4+1),.025,f+1),Vector3(maxf(.5,w/2-2.3),.05,2),"cafe_turf")
		for i in range(9):
			box(Vector3(side*(w/2-.2),.55,f+.1+i*.23),Vector3(.055,1.1,.055),"white")
		box(Vector3(side*(w/2-.2),.85,f+1),Vector3(.08,.07,2.2),"white")
		table(Vector3(side*w*.32,.05,f+.9),true)
		# Compact interior seats leave a central walking aisle.
		for z in [-d*.28,d*.12]:
			table(Vector3(side*w*.30,.45,z),false)
		for x in [-w*.3,0.0,w*.3]:
			box(Vector3(x,3.51,f+.14),Vector3(.17,.035,.17),"warm_light")
		box(Vector3(side*(w/2-.16),2.4,-d*.2),Vector3(.08,.65,d*.55),"cafe_cane")
		box(Vector3(side*(w/2-.22),3.1,-d*.2),Vector3(.15,.18,.18),"cafe_charcoal")
		box(Vector3(side*(w/2-.23),3,-d*.2),Vector3(.16,.035,.18),"warm_light")
	text(Vector3(0,2.5,-f+.15),"Espresso Yourself",31,Color("ffe1a0"))
	var light:=OmniLight3D.new()
	light.position=origin+basis*Vector3(0,3,0)
	light.light_color=Color("ffe0ac")
	light.light_energy=.8
	light.omni_range=maxf(w,d)
	light.shadow_enabled=false
	light.distance_fade_enabled=true
	light.distance_fade_begin=25
	light.distance_fade_length=15
	world.cell(origin).add_child(light)
func table(at: Vector3, outdoor: bool) -> void:
	box(at+Vector3(0,.78,0),Vector3(1.05,.09,.7),"cafe_wood",true)
	box(at+Vector3(0,.39,0),Vector3(.12,.78,.12),"cafe_charcoal")
	for side in [-1,1]:
		var seat:=at+Vector3(0,0,side*.65)
		box(seat+Vector3(0,.44,0),Vector3(.52,.1,.5),"green" if outdoor else "cafe_cane",true)
		box(seat+Vector3(0,.8,side*.24),Vector3(.54,.58,.065),"cafe_cane")
		for x in [-.23,.23]:
			box(seat+Vector3(x,.22,0),Vector3(.045,.44,.42),"cafe_wood")
	box(at+Vector3(.25,.94,0),Vector3(.07,.23,.07),"shop_glass")
