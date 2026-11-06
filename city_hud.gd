extends "res://tablet_controls.gd"
signal action_pressed(action: String)
signal travel_requested(index: int)
var game: Node3D
var modal := false
var action_fingers: Dictionary = {}
var waypoint := Vector3.ZERO
var navigation: PackedVector3Array = []
var has_waypoint := false
var quest := "EXPLORE JAIPUR · Visit the district markers"
var health := 100.0
var stamina := 100.0
var driving := false
var speed := 0
# Real amenities drawn on the atlas/radar (OSM, see city_world.amenities).
const AMENITY_STYLE := {"police":["P",Color("4d7fd8")],"hospital":["+",Color("e05a4e")],"showroom":["C",Color("b48ae6")],"theka":["W",Color("5cc26b")],"fuel":["F",Color("f0a040")],"temple":["T",Color("f2b24a")],"bank":["B",Color("4fb8b0")],"school":["S",Color("f0d060")]}
var services_tab := false

func action_centers() -> Dictionary:
	return {"attack":Vector2(size.x-110,size.y-270),"kick":Vector2(size.x-225,size.y-245),"dodge":Vector2(size.x-330,size.y-190),"guard":Vector2(size.x-345,size.y-90),"talk":Vector2(size.x-110,300),"ride":Vector2(size.x-110,370),"crouch":Vector2(size.x-450,size.y-90)}

func _input(event: InputEvent) -> void:
	if map_open:
		if (event is InputEventScreenTouch or event is InputEventMouseButton) and event.pressed:
			var pos: Vector2 = event.position
			if Rect2(size.x-282,88,106,36).has_point(pos):
				services_tab=false
				get_viewport().set_input_as_handled()
				return
			if Rect2(size.x-172,88,106,36).has_point(pos):
				services_tab=true
				get_viewport().set_input_as_handled()
				return
			var entries: Array=game.world.services if services_tab else game.world.landmarks
			if Rect2(size.x-280,136,210,entries.size()*58).has_point(pos):
				var index := int((pos.y-136)/58)
				travel_requested.emit(index+game.world.landmarks.size() if services_tab else index)
				map_open=false
				clear_input()
				get_viewport().set_input_as_handled()
				return
		super._input(event)
		return
	if modal:
		clear_input()
		return
	var radar_rect := Rect2(24, 144, 174, 154)
	if (event is InputEventScreenTouch or event is InputEventMouseButton) and event.pressed and radar_rect.has_point(event.position):
		map_open = true
		get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			for action in action_centers():
				if event.position.distance_to(action_centers()[action]) < 43:
					action_fingers[event.index] = action
					action_pressed.emit(action)
					get_viewport().set_input_as_handled()
					return
		elif action_fingers.has(event.index):
			action_fingers.erase(event.index)
			return
	if event is InputEventScreenDrag and action_fingers.has(event.index):
		return
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		for action in action_centers():
			if event.position.distance_to(action_centers()[action])<43:
				action_pressed.emit(action)
				get_viewport().set_input_as_handled()
				return
	super._input(event)

func clear_input() -> void:
	super.clear_input()
	action_fingers.clear()

func map_scale() -> float:
	return minf((size.x-380)/game.world.map_bounds.size.x,(size.y-140)/game.world.map_bounds.size.y)*map_zoom
func map_point(x: float,z: float) -> Vector2:
	var bounds: Rect2 = game.world.map_bounds
	return Vector2(45,100)+(Vector2(x,z)-bounds.position)*map_scale()+map_pan
func clamp_map_pan() -> void:
	var limits: Vector2 = game.world.map_bounds.size*map_scale()
	map_pan.x=clampf(map_pan.x,-limits.x*.8,limits.x*.2)
	map_pan.y=clampf(map_pan.y,-limits.y*.8,limits.y*.2)

func _draw() -> void:
	if game==null or game.world==null:
		return
	if map_open:
		draw_map()
		return
	var ink := Color("f5e6d1")
	var quiet := Color("b8c4c6")
	draw_style_box(panel(Color(.045,.065,.075,.88)),Rect2(24,22,350,106))
	text_at(Vector2(42,49),"GULABI SAHAR",21,ink)
	hindi_at(Vector2(42,73),str(zone_name.get("hindi","जयपुर")),17,quiet)
	draw_rect(Rect2(42,88,145,5),Color("39494c"))
	draw_rect(Rect2(42,88,145*health/100,5),Color("d47764"))
	draw_rect(Rect2(203,88,145,5),Color("39494c"))
	draw_rect(Rect2(203,88,145*stamina/100,5),Color("d6bb7f"))
	text_at(Vector2(42,114),"HEALTH %d       STAMINA %d"%[int(health),int(stamina)],12,quiet)
	draw_style_box(panel(Color(.045,.065,.075,.8)),Rect2(400,22,size.x-610,72))
	text_at(Vector2(418,47),"CITY JOURNAL",11,Color("d6bb7f"))
	text_at(Vector2(418,74),quest,14,ink)
	text_at(Vector2(size.x-150,50),"%d FPS"%fps,14,quiet)
	draw_radar()
	if portrait:
		text_at(Vector2(size.x-240,170),"EXPRESSION: "+expression_label,16,ink)
		button_circle(expression_center(),"SMILE",30,Color("394d51"))
		button_circle(face_center(),"BACK",32,Color("394d51"))
		return
	button_circle(map_center(),"MAP",32,Color("1e333a"))
	button_circle(face_center(),"FACE",30,Color("1e333a"))
	draw_circle(center(),86,Color(.06,.1,.12,.4))
	draw_arc(center(),86,0,TAU,48,Color(.8,.8,.7,.4),2,true)
	draw_circle(center()+knob,33,Color(.88,.82,.68,.7))
	button_circle(jump_center(),"JUMP",49,Color("34494f"))
	button_circle(run_center(),"BRAKE" if driving else "SPRINT",37,Color("866345") if running else Color("25383e"))
	var labels := {"attack":"PUNCH","kick":"KICK","dodge":"DODGE","guard":"BLOCK","talk":"TALK","ride":"EXIT" if driving else "DRIVE","crouch":"CROUCH"}
	for action in action_centers():
		button_circle(action_centers()[action],labels[action],39,Color("894e42") if action=="attack" else Color("263b41"))
	if driving:
		text_at(Vector2(size.x/2-60,size.y-45),"%03d KM/H"%speed,24,ink)
	else:
		text_at(Vector2(350,size.y-22),"Q punch · E kick · X dodge · B block · C crouch · T talk · V drive",12,quiet)

func button_circle(at: Vector2,label: String,radius: float,color: Color) -> void:
	draw_circle(at,radius,Color(color,.86))
	draw_arc(at,radius,0,TAU,40,Color("b9aa88"),1.4,true)
	draw_string(font,at+Vector2(-radius,5),label,HORIZONTAL_ALIGNMENT_CENTER,radius*2,12,Color("f3e5d2"))

func draw_radar() -> void:
	var rect := Rect2(24,144,174,154)
	draw_style_box(panel(Color("15282e")),rect)
	var origin := rect.get_center()
	var scale := .52
	for road in game.world.data.roads:
		if road.p.size()<2:
			continue
		var first := Vector2(road.p[0][0],road.p[0][1])
		if first.distance_squared_to(Vector2(map_player.x,map_player.z))>90000:
			continue
		for i in range(road.p.size()-1):
			var a := origin+(Vector2(road.p[i][0],road.p[i][1])-Vector2(map_player.x,map_player.z))*scale
			var b := origin+(Vector2(road.p[i+1][0],road.p[i+1][1])-Vector2(map_player.x,map_player.z))*scale
			if rect.has_point(a) and rect.has_point(b):
				var authored: bool = road.get("source","osm")=="authored"
				draw_line(a,b,Color("e0a44a") if authored else Color("718282"),maxf(1,road.width*scale*.35))
	draw_circle(origin,4,Color("f4dc9e"))
	draw_line(origin,origin+Vector2(-sin(map_yaw),-cos(map_yaw))*14,Color("f4dc9e"),2)
	for a in game.world.amenities:
		if not AMENITY_STYLE.has(a.kind):
			continue
		var at := origin+(Vector2(a.p[0],a.p[1])-Vector2(map_player.x,map_player.z))*scale
		if rect.grow(-6).has_point(at):
			draw_circle(at,3.5,AMENITY_STYLE[a.kind][1])
	for poi in game.world.services:
		var at := origin+(Vector2(poi.p[0],poi.p[1])-Vector2(map_player.x,map_player.z))*scale
		if rect.grow(-10).has_point(at):
			draw_circle(at,3.5,Color("75cbbb"))
	text_at(Vector2(34,287),"N ↑    JAIPUR / 65%",9,Color("adbdba"))
	if has_waypoint:
		var direction := Vector2(waypoint.x-map_player.x,waypoint.z-map_player.z)
		var at := origin+direction.limit_length(100)*scale
		draw_circle(at,5,Color("75cbbb"))
		text_at(Vector2(28,319),"DESTINATION  %d m"%int(direction.length()),12,Color("91d8c7"))

func draw_map() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("10242c"))
	text_at(Vector2(36,46),"JAIPUR  /  CITY ATLAS",27,Color("f1ddba"))
	var km: Vector2 = game.world.map_bounds.size/1000.0
	text_at(Vector2(36,74),"%.1f × %.1f km compact Jaipur · roads, parks and %d real places from OpenStreetMap · select a destination to travel"%[km.x,km.y,game.world.amenities.size()],13,Color("9eb5bb"))
	for road in game.world.data.roads:
		var line := PackedVector2Array()
		for p in road.p:
			line.append(map_point(p[0],p[1]))
		if line.size()>1:
			var area:=Rect2(30,100,size.x-370,size.y-150)
			for i in range(line.size()-1):
				if area.has_point(line[i]) and area.has_point(line[i+1]):
					if road.get("source","osm")=="authored":
						draw_dashed_line(line[i],line[i+1],Color("e0a44a"),3,6)
					else:
						draw_line(line[i],line[i+1],Color("81968e") if road.width>=10 else Color("415a60"),2 if road.width>=10 else 1)
	for park_data in game.world.data.parks:
		var poly := PackedVector2Array()
		for p in park_data.p:
			poly.append(map_point(p[0],p[1]))
		if poly.size()>2:
			draw_polyline(poly,Color("6c9c75"),2)
	if navigation.size()>1:
		var line := PackedVector2Array()
		for p in navigation:
			line.append(map_point(p.x,p.z))
		draw_polyline(line,Color("e7c278"),3,true)
	for i in game.world.landmarks.size():
		var poi: Dictionary = game.world.landmarks[i]
		var at := map_point(poi.p[0],poi.p[1])
		draw_circle(at,5,Color("e7c278"))
		text_at(at+Vector2(7,-5),poi.name,11,Color("f3e6cb"))
		# Destination list is drawn below, separately from geographic markers.
	for poi in game.world.services:
		var at := map_point(poi.p[0],poi.p[1])
		draw_circle(at,3,Color("75cbbb"))
		if map_zoom>=3:
			text_at(at+Vector2(6,4),poi.name,10,Color("75cbbb"))
	for tab in 2:
		draw_style_box(panel(Color("47736e") if (tab==1)==services_tab else Color("233c44")),Rect2(size.x-282+tab*110,88,106,36))
		text_at(Vector2(size.x-272+tab*110,112),"SERVICES" if tab else "DISTRICTS",12,Color("f3e6cb"))
	var entries: Array=game.world.services if services_tab else game.world.landmarks
	for i in entries.size():
		draw_style_box(panel(Color("233c44")),Rect2(size.x-280,136+i*58,210,48))
		text_at(Vector2(size.x-265,165+i*58),entries[i].name,14,Color("f3e6cb"))
	if services_tab:
		text_at(Vector2(size.x-280,155+entries.size()*58),"Fictional neighborhood locations",10,Color("9eb5bb"))
	var here := map_point(map_player.x,map_player.z)
	draw_circle(here,7,Color("7de4cf"))
	text_at(here+Vector2(10,5),"YOU",12,Color("7de4cf"))
	var car: Vector3 = game.vehicle.position
	draw_circle(map_point(car.x,car.z),4,Color("d5a7ed"))
	var area:=Rect2(30,100,size.x-370,size.y-150)
	for a in game.world.amenities:
		if not AMENITY_STYLE.has(a.kind):
			continue
		var at := map_point(a.p[0],a.p[1])
		if not area.has_point(at):
			continue
		var style: Array = AMENITY_STYLE[a.kind]
		draw_circle(at,6.5,Color(0,0,0,.45))
		draw_circle(at,5.5,style[1])
		draw_string(font,at+Vector2(-5.5,4),style[0],HORIZONTAL_ALIGNMENT_CENTER,11,9,Color("102028"))
		if map_zoom>=2.0 and a.kind in ["police","hospital","showroom","fuel"] and a.name!="":
			text_at(at+Vector2(8,4),a.name,10,style[1])
	var legend_x := 35.0
	for kind in ["police","hospital","showroom","theka","fuel","temple","bank","school"]:
		var style: Array = AMENITY_STYLE[kind]
		draw_circle(Vector2(legend_x+5,size.y-64),5,style[1])
		var label: String = {"police":"police","hospital":"hospital/clinic","showroom":"car showroom","theka":"wine shop","fuel":"petrol pump","temple":"temple","bank":"bank/ATM","school":"school"}[kind]
		text_at(Vector2(legend_x+14,size.y-60),label,10,Color("c9d6d6"))
		legend_x += 26+label.length()*5.6
	for road in game.world.authored_roads:
		var mid: Array = road.p[road.p.size()/2]
		var at := map_point(mid[0],mid[1])
		draw_circle(at,9,Color("e0a44a",.35))
		draw_circle(at,4,Color("e0a44a"))
		text_at(at+Vector2(8,-7),"GAME CONNECTOR",10,Color("e0a44a"))
	draw_dashed_line(Vector2(35,size.y-44),Vector2(75,size.y-44),Color("e0a44a"),3,6)
	text_at(Vector2(82,size.y-40),"authored game connector (Nahargarh link) · solid lines = OpenStreetMap roads",11,Color("e0a44a"))
	text_at(Vector2(35,size.y-22),"© OpenStreetMap contributors · ODbL 1.0 · artistic terrain/buildings · 06 Nov 2026",11,Color("9eb5bb"))
	button_circle(map_close_center(),"X",26,Color("344a50"))
	button_circle(map_zoom_in_center(),"+",24,Color("344a50"))
	button_circle(map_zoom_out_center(),"−",24,Color("344a50"))
