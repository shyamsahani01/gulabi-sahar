extends "res://tablet_controls.gd"
signal action_pressed(action: String)
signal travel_requested(index: int)
var game: Node3D
var modal := false
var action_fingers: Dictionary = {}
var waypoint := Vector3.ZERO
var navigation: PackedVector3Array = []
var has_waypoint := false
var quest := "EXPLORE VKI + VDN · Visit the district markers"
var health := 100.0
var stamina := 100.0
var driving := false
var speed := 0
# Real amenities drawn on the atlas/radar (OSM, see city_world.amenities).
const AMENITY_STYLE := {"restaurant":["R",Color("d4a574")],"cafe":["C",Color("cba675")],"pub":["P",Color("be86dc")],"club":["N",Color("be86dc")],"shop":["K",Color("9fc489")],"police":["P",Color("4d7fd8")],"hospital":["+",Color("e05a4e")],"showroom":["C",Color("b48ae6")],"theka":["W",Color("5cc26b")],"fuel":["F",Color("f0a040")],"temple":["T",Color("f2b24a")],"bank":["B",Color("4fb8b0")],"school":["S",Color("f0d060")]}
var services_tab := false
var dining_tab := false
var atlas: Control
var combat_controls := false
var context_actions: Array[String] = []
var context_clock := 0.0

func _ready() -> void:
	super._ready()
	atlas=preload("res://city_atlas.gd").new()
	atlas.game=game
	atlas.hud=self
	add_child(atlas)

func _process(delta: float) -> void:
	super._process(delta)
	context_clock-=delta
	if context_clock<=0 and game.actions!=null:
		context_clock=.2
		context_actions.clear()
		if game.vehicle.driving:
			context_actions.append("ride")
		elif not game.seated.is_empty():
			context_actions.append("sit")
		else:
			context_actions.append("combat")
			if game.nearest_drivable().global_position.distance_to(game.player.global_position)<5:
				context_actions.append("ride")
			if not game.actions.nearest(3.5).is_empty(): context_actions.append("talk")
			for seat in game.world.seats:
				if seat.p.distance_to(game.player.position)<2.3:
					context_actions.append("sit")
					break
			if combat_controls: context_actions.append_array(["attack","kick","dodge","guard","crouch"])
	queue_redraw()

func dispatch_action(action: String) -> void:
	if action=="combat": combat_controls=not combat_controls; context_clock=0
	else: action_pressed.emit(action)


func atlas_entries() -> Array:
	return game.world.dining_destinations if dining_tab else (game.world.services if services_tab else game.world.landmarks)

func atlas_offset() -> int:
	return game.world.landmarks.size()+game.world.services.size() if dining_tab else (game.world.landmarks.size() if services_tab else 0)

func action_centers() -> Dictionary:
	var all := {"combat":Vector2(size.x-345,size.y-90),"attack":Vector2(size.x-110,size.y-270),"kick":Vector2(size.x-225,size.y-245),"dodge":Vector2(size.x-330,size.y-190),"guard":Vector2(size.x-450,size.y-190),"talk":Vector2(size.x-110,300),"ride":Vector2(size.x-110,370),"sit":Vector2(size.x-110,440),"crouch":Vector2(size.x-450,size.y-90)}
	var active := {}
	for key in context_actions: active[key]=all[key]
	return active

func _input(event: InputEvent) -> void:
	if map_open:
		if event is InputEventKey and event.pressed and event.keycode in [KEY_M,KEY_ESCAPE] and not atlas.search.has_focus():
			map_open=false
			clear_input()
			get_viewport().set_input_as_handled()
		return
	if modal:
		clear_input()
		return
	if portrait:
		super._input(event)
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
					dispatch_action(action)
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
				dispatch_action(action)
				get_viewport().set_input_as_handled()
				return
	if (event is InputEventScreenTouch or event is InputEventMouseButton) and event.pressed:
		if (driving or not game.seated.is_empty()) and event.position.distance_to(jump_center())<58: return
		if driving and event.position.distance_to(face_center())<42: return
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
		return # Native atlas overlay handles drawing and input.
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
	if modal: return
	if portrait:
		text_at(Vector2(size.x-240,170),"EXPRESSION: "+expression_label,16,ink)
		button_circle(expression_center(),"SMILE",30,Color("394d51"))
		draw_style_box(panel(Color(.1,.15,.16,.9)),Rect2(outfit_center()-Vector2(78,22),Vector2(156,44)))
		text_at(outfit_center()+Vector2(-66,6),"OUTFIT: "+outfit_label.to_upper()+" >",14,ink)
		button_circle(face_center(),"BACK",32,Color("394d51"))
		draw_face_zoom(ink,quiet)
		return
	button_circle(map_center(),"MAP",32,Color("1e333a"))
	if not driving: button_circle(face_center(),"FACE",30,Color("1e333a"))
	draw_circle(center(),86,Color(.06,.1,.12,.4))
	draw_arc(center(),86,0,TAU,48,Color(.8,.8,.7,.4),2,true)
	draw_circle(center()+knob,33,Color(.88,.82,.68,.7))
	if not driving and game.seated.is_empty(): button_circle(jump_center(),"JUMP",49,Color("34494f"))
	if game.seated.is_empty(): button_circle(run_center(),"BRAKE" if driving else "SPRINT",37,Color("866345") if running else Color("25383e"))
	var labels := {"combat":"LESS" if combat_controls else "ACTIONS","attack":"PUNCH","kick":"KICK","dodge":"DODGE","guard":"BLOCK","talk":"TALK","ride":"EXIT" if driving else "DRIVE","sit":"STAND" if not game.seated.is_empty() else "SIT","crouch":"CROUCH"}
	for action in action_centers():
		button_circle(action_centers()[action],labels[action],39,Color("894e42") if action=="attack" else (Color("4d6a52") if action=="sit" and not game.seated.is_empty() else Color("263b41")))
	if driving:
		text_at(Vector2(size.x/2-60,size.y-45),"%03d KM/H"%speed,24,ink)


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
	draw_circle(origin,12,Color(.2,.85,1,.2))
	draw_circle(origin,6,Color("58dcff"))
	text_at(origin+Vector2(9,4),"YOU",10,Color.WHITE)
	draw_line(origin,origin+Vector2(-sin(map_yaw),-cos(map_yaw))*14,Color.WHITE,2)
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
	text_at(Vector2(34,287),"N ↑    VKI / VDN",9,Color("adbdba"))
	if has_waypoint:
		var direction := Vector2(waypoint.x-map_player.x,waypoint.z-map_player.z)
		var at := origin+direction.limit_length(100)*scale
		draw_circle(at,5,Color("75cbbb"))
		text_at(Vector2(28,319),"DESTINATION  %d m"%int(direction.length()),12,Color("91d8c7"))
