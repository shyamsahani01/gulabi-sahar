extends Control
## Searchable atlas. Every mapped place and road segment retains its own identity.
var game: Node3D
var hud: Control
var canvas: Control
var sidebar: VBoxContainer
var search: LineEdit
var category: OptionButton
var results: ItemList
var detail: Label
var count_label: Label
var go: Button
var route_button: Button
var entries: Array = []
var filtered: Array = []
var selected: Dictionary = {}
var zoom := 2.5
var centre := Vector2.ZERO
var fingers: Dictionary = {}
var drag_start := Vector2.ZERO
var dragged := false
var mouse_down := false
var categories := ["All places", "Streets / gali", "Theka / wine", "Food / cafes", "Hospitals", "Police", "Shops", "Fuel", "Temples", "Districts"]
var last_open := false
var previous_mouse_emulation := false
var font := ThemeDB.fallback_font

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var theme0 := Theme.new()
	theme0.default_font_size = 16
	for state in ["normal", "hover", "pressed", "focus"]:
		var skin := StyleBoxFlat.new()
		skin.bg_color = Color("25404d") if state == "normal" else Color("366476")
		skin.set_corner_radius_all(10)
		skin.content_margin_left = 12
		skin.content_margin_right = 12
		theme0.set_stylebox(state, "Button", skin)
		theme0.set_stylebox(state, "OptionButton", skin)
	theme = theme0
	canvas = Control.new()
	canvas.clip_contents = true
	add_child(canvas)
	canvas.draw.connect(draw_canvas)
	canvas.gui_input.connect(canvas_input)
	sidebar = VBoxContainer.new()
	sidebar.add_theme_constant_override("separation", 10)
	add_child(sidebar)
	var title := Label.new()
	title.text = "EXPLORE JAIPUR"
	title.add_theme_font_size_override("font_size", 23)
	sidebar.add_child(title)
	search = LineEdit.new()
	search.placeholder_text = "Search name, theka, road, gali…"
	search.clear_button_enabled = true
	search.custom_minimum_size.y = 46
	search.text_changed.connect(func(_value): refresh_results())
	sidebar.add_child(search)
	category = OptionButton.new()
	category.custom_minimum_size.y = 44
	for item in categories: category.add_item(item)
	category.item_selected.connect(func(_index): refresh_results())
	sidebar.add_child(category)
	count_label = Label.new()
	count_label.add_theme_font_size_override("font_size", 13)
	sidebar.add_child(count_label)
	results = ItemList.new()
	results.size_flags_vertical = Control.SIZE_EXPAND_FILL
	results.fixed_icon_size = Vector2(16,16)
	results.add_theme_constant_override("v_separation", 14)
	results.item_selected.connect(func(index): select_entry(filtered[index]))
	sidebar.add_child(results)
	detail = Label.new()
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.custom_minimum_size.y = 75
	detail.text = "Select a place, or tap any street.\nDrag to explore · pinch / scroll to zoom."
	sidebar.add_child(detail)
	var row := HBoxContainer.new()
	sidebar.add_child(row)
	route_button = add_button(row, "Show route", show_route)
	go = add_button(row, "GO HERE →", travel)
	route_button.disabled = true
	go.disabled = true
	var toolbar := HBoxContainer.new()
	toolbar.name = "Toolbar"
	add_child(toolbar)
	add_button(toolbar,"−",func(): zoom_at(zoom/1.5,canvas.size/2))
	add_button(toolbar,"+",func(): zoom_at(zoom*1.5,canvas.size/2))
	add_button(toolbar,"◎ My location",recenter)
	add_button(toolbar,"Fit city",func(): zoom=1; centre=game.world.map_bounds.get_center())
	add_button(toolbar,"Close ×",func(): hud.map_open=false; hud.clear_input())
	resized.connect(layout)
	layout()
	build_entries()
	hide()

func add_button(parent: Node, title: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size.y = 44
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func layout() -> void:
	var width := clampf(size.x*.29,280,370)
	canvas.position = Vector2(16,76)
	canvas.size = Vector2(size.x-width-48,size.y-132)
	sidebar.position = Vector2(size.x-width-16,22)
	sidebar.size = Vector2(width,size.y-42)
	get_node("Toolbar").position = Vector2(20,18)
	get_node("Toolbar").size.x = canvas.size.x

func _process(_delta: float) -> void:
	visible = hud.map_open
	if visible and not last_open:
		get_viewport().disable_3d=true
		previous_mouse_emulation=Input.emulate_mouse_from_touch
		Input.emulate_mouse_from_touch=true
		hud.clear_input()
		recenter()
		refresh_results()
	if not visible and last_open:
		get_viewport().disable_3d=false
		Input.emulate_mouse_from_touch=previous_mouse_emulation
		fingers.clear()
		mouse_down=false
		search.release_focus()
	last_open = visible
	if visible:
		layout() # Reapply height after wrapped labels finish container sizing.
		queue_redraw()
		canvas.queue_redraw()

func build_entries() -> void:
	entries.clear()
	var seen := {}
	for group in [game.world.landmarks,game.world.services,game.world.dining_destinations,game.world.amenities]:
		for source in group:
			var entry: Dictionary = source.duplicate(true)
			entry.kind = "district" if group==game.world.landmarks else entry.get("kind", "shop")
			entry.name = str(entry.get("name", "")).strip_edges()
			if entry.name.is_empty(): entry.name = str(entry.kind).capitalize()
			var key := "%s:%.0f:%.0f" % [entry.name,entry.p[0],entry.p[1]]
			if seen.has(key): continue
			seen[key] = true
			entry.source = entry.get("source", "game location" if group==game.world.services else "mapped location")
			entries.append(entry)
	for road in game.world.data.roads:
		if road.p.size()<2: continue
		var entry: Dictionary = road.duplicate(true)
		entry.path = road.p
		entry.p = road.p[road.p.size()/2]
		entry.kind = "street"
		entry.name = str(road.get("name", "")).strip_edges()
		if entry.name.is_empty(): entry.name = "Unnamed gali · %s" % str(road.get("id", entries.size()))
		entry.source = road.get("source", "OpenStreetMap")
		entries.append(entry)

func matches(entry: Dictionary) -> bool:
	var kind: String = entry.kind
	if category.selected==0 and kind=="street" and search.text.strip_edges().is_empty(): return false
	var groups := [[],["street"],["theka"],["restaurant","cafe","chai","pub","club"],["hospital","pharmacy"],["police"],["shop","grocery","showroom"],["fuel"],["temple"],["district"]]
	if category.selected>0 and kind not in groups[category.selected]: return false
	var aliases := {"theka":"wine liquor ठेका शराब", "street":"road gali street गली सड़क", "cafe":"coffee chai cafe", "hospital":"clinic hospital अस्पताल"}
	var haystack := (str(entry.name)+" "+kind+" "+str(entry.get("hindi",""))+" "+str(aliases.get(kind,""))).to_lower()
	for word in search.text.to_lower().split(" ",false):
		if not haystack.contains(word): return false
	return true

func refresh_results() -> void:
	filtered = entries.filter(matches)
	var here := Vector2(game.player.position.x,game.player.position.z)
	filtered.sort_custom(func(a,b):return Vector2(a.p[0],a.p[1]).distance_squared_to(here)<Vector2(b.p[0],b.p[1]).distance_squared_to(here))
	results.clear()
	for entry in filtered:
		var distance := int(Vector2(entry.p[0],entry.p[1]).distance_to(here))
		results.add_item("%s   ·   %d m" % [entry.name,distance])
		results.set_item_tooltip(results.item_count-1,"%s · %s" % [entry.kind,entry.source])
	count_label.text = "%d results · nearest first" % filtered.size() if not filtered.is_empty() else "No matching locations in this map"
	selected={}
	go.disabled=true
	route_button.disabled=true
	detail.text="Select a result or tap a street.\nEvery available location is listed."

func scale_map() -> float:
	return minf(canvas.size.x/game.world.map_bounds.size.x,canvas.size.y/game.world.map_bounds.size.y)*zoom
func point(p: Vector2) -> Vector2:
	return canvas.size/2+(p-centre)*scale_map()
func unpoint(p: Vector2) -> Vector2:
	return centre+(p-canvas.size/2)/scale_map()
func recenter() -> void:
	centre=Vector2(game.player.position.x,game.player.position.z)
func zoom_at(value: float, anchor: Vector2) -> void:
	var before := unpoint(anchor)
	zoom=clampf(value,1,32)
	centre+=before-unpoint(anchor)
	clamp_centre()
func clamp_centre() -> void:
	var bounds: Rect2=game.world.map_bounds
	centre=centre.clamp(bounds.position,bounds.end)

func canvas_input(event: InputEvent) -> void:
	# Native UI receives emulated mouse clicks; map gestures use the original touches.
	if event.device==-1 and (event is InputEventMouseButton or event is InputEventMouseMotion): return
	if event is InputEventMouseButton:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN] and event.pressed:
			zoom_at(zoom*(1.25 if event.button_index==MOUSE_BUTTON_WHEEL_UP else .8),event.position)
		elif event.button_index==MOUSE_BUTTON_LEFT:
			mouse_down=event.pressed
			if event.pressed: drag_start=event.position; dragged=false
			elif not dragged: pick(event.position)
	elif event is InputEventMouseMotion and mouse_down:
		if event.position.distance_to(drag_start)>8: dragged=true
		if dragged: centre-=event.relative/scale_map(); clamp_centre()
	elif event is InputEventScreenTouch:
		if event.pressed:
			fingers[event.index]=event.position
			if fingers.size()==1: drag_start=event.position; dragged=false
			else: dragged=true
		else:
			if fingers.size()==1 and not dragged: pick(event.position)
			fingers.erase(event.index)
	elif event is InputEventScreenDrag and fingers.has(event.index):
		if fingers.size()==2:
			var old: Array=fingers.values()
			var before: float=old[0].distance_to(old[1])
			fingers[event.index]=event.position
			var now: Array=fingers.values()
			if before>5: zoom_at(zoom*now[0].distance_to(now[1])/before,(now[0]+now[1])/2)
			dragged=true
		else:
			if event.position.distance_to(drag_start)>8: dragged=true
			if dragged: centre-=event.relative/scale_map(); clamp_centre()
			fingers[event.index]=event.position
	canvas.accept_event()

func pick(at: Vector2) -> void:
	var best: Dictionary={}
	var distance := 20.0
	for entry in filtered:
		if entry.kind=="street": continue
		var d := point(Vector2(entry.p[0],entry.p[1])).distance_to(at)
		if d<distance: distance=d; best=entry
	if not best.is_empty(): select_entry(best); return
	# Road geometry is selectable even where neither endpoint is on screen.
	distance=28.0
	for road in game.world.data.roads:
		for i in range(road.p.size()-1):
			var a:=Vector2(road.p[i][0],road.p[i][1])
			var b:=Vector2(road.p[i+1][0],road.p[i+1][1])
			var p:=Geometry2D.get_closest_point_to_segment(unpoint(at),a,b)
			var d:=point(p).distance_to(at)
			if d<distance:
				distance=d
				best={"name":(road.get("name", "") if road.get("name", "")!="" else "Unnamed gali"),"kind":"street","p":[p.x,p.y],"source":road.get("source","OpenStreetMap"),"path":road.p}
	if not best.is_empty(): select_entry(best)

func select_entry(entry: Dictionary) -> void:
	selected=entry
	centre=Vector2(entry.p[0],entry.p[1])
	detail.text="%s\n%s · %s" % [entry.name,str(entry.kind).capitalize(),entry.source]
	go.disabled=false
	route_button.disabled=false

func show_route() -> void:
	if selected.is_empty(): return
	var arrival: Dictionary=game.map_arrival(selected)
	var target:=Vector3(arrival.p.x,0,arrival.p.y)
	hud.waypoint=target
	hud.has_waypoint=true
	hud.navigation=game.world.route_between(game.player.position,target)
	detail.text=("%s\nRoute highlighted · GO HERE to travel" if hud.navigation.size()>1 else "%s\nNo connected road route · GO HERE is available") % selected.name

func travel() -> void:
	if selected.is_empty(): return
	game.travel_to_map_entry(selected)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("0b1520"))
	draw_style_box(hud.panel(Color("142430")),Rect2(sidebar.position-Vector2(10,10),sidebar.size+Vector2(20,20)))
	draw_string(font,Vector2(22,size.y-30),"VKI + VIDHYADHAR NAGAR     ·     %.1f× zoom     ·     © OpenStreetMap contributors / ODbL" % zoom,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("a2b4c5"))

func draw_canvas() -> void:
	canvas.draw_rect(Rect2(Vector2.ZERO,canvas.size),Color("152632"))
	for park in game.world.data.parks:
		var poly:=PackedVector2Array()
		for p in park.p: poly.append(point(Vector2(p[0],p[1])))
		if poly.size()>2: canvas.draw_colored_polygon(poly,Color("234c43"))
	if zoom>=4:
		for b in game.world.data.buildings:
			var at:=point(Vector2(b.x,b.z))
			if not Rect2(Vector2(-80,-80),canvas.size+Vector2(160,160)).has_point(at): continue
			var poly:=PackedVector2Array()
			for corner in [Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)]:
				poly.append(point(Vector2(b.x,b.z)+(corner*Vector2(b.w,b.d)/2).rotated(-b.a)))
			canvas.draw_colored_polygon(poly,Color("2b3d4b"))
	var labels: Array[Vector2]=[]
	for road in game.world.data.roads:
		var line:=PackedVector2Array()
		for p in road.p: line.append(point(Vector2(p[0],p[1])))
		if line.size()<2: continue
		var width:=clampf(road.width*scale_map(),1.5,60)
		canvas.draw_polyline(line,Color("0d1c29"),width+3,true)
		canvas.draw_polyline(line,Color("607b8b") if road.width>=10 else Color("395565"),width,true)
		if zoom>=4 and str(road.get("name", ""))!="":
			var at:=line[line.size()/2]
			var crowded:=false
			for prev in labels:
				if prev.distance_to(at)<90: crowded=true; break
			if not crowded and Rect2(Vector2(20,20),canvas.size-Vector2(40,40)).has_point(at):
				canvas.draw_string(font,at,road.name,HORIZONTAL_ALIGNMENT_LEFT,170,12,Color("cfdae3"))
				labels.append(at)
	if hud.navigation.size()>1:
		var route:=PackedVector2Array()
		for p in hud.navigation: route.append(point(Vector2(p.x,p.z)))
		canvas.draw_polyline(route,Color("47dbc2"),4,true)
	for entry in filtered:
		if entry.kind=="street": continue
		var at:=point(Vector2(entry.p[0],entry.p[1]))
		if not Rect2(Vector2.ZERO,canvas.size).has_point(at): continue
		var style: Array=hud.AMENITY_STYLE.get(entry.kind,["•",Color("c4a6e9")])
		canvas.draw_circle(at,9,Color("0c1922"))
		canvas.draw_circle(at,7,style[1])
		canvas.draw_string(font,at+Vector2(-4,4),style[0],HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("102028"))
	if not selected.is_empty():
		var at:=point(Vector2(selected.p[0],selected.p[1]))
		canvas.draw_arc(at,15,0,TAU,32,Color("ffd18a"),3,true)
		canvas.draw_string(font,at+Vector2(20,-13),selected.name,HORIZONTAL_ALIGNMENT_LEFT,240,15,Color("ffd18a"))
	var here:=point(Vector2(game.player.position.x,game.player.position.z))
	var screen_here:=here.clamp(Vector2(24,36),canvas.size-Vector2(145,24))
	canvas.draw_circle(screen_here,20,Color(.2,.85,1,.15))
	canvas.draw_circle(screen_here,10,Color("58dcff"))
	var forward:=Vector2(-sin(hud.map_yaw),-cos(hud.map_yaw)) if screen_here==here else (here-screen_here).normalized()
	canvas.draw_line(screen_here,screen_here+forward*26,Color.WHITE,3,true)
	canvas.draw_string(font,screen_here+Vector2(15,5),"YOU" if screen_here==here else "YOU (offscreen)",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color.WHITE)
	canvas.draw_string(font,Vector2(20,30),"N ↑   "+str(hud.zone_name.get("name","VKI / VDN")),HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("dbe7ef"))
	var metres:=50.0 if zoom>=8 else 200.0
	var y:=canvas.size.y-22
	canvas.draw_line(Vector2(20,y),Vector2(20+metres*scale_map(),y),Color("dbe7ef"),3)
	canvas.draw_string(font,Vector2(20,y-8),"%d m" % int(metres),HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("dbe7ef"))

func _exit_tree() -> void:
	get_viewport().disable_3d=false
	if last_open: Input.emulate_mouse_from_touch=previous_mouse_emulation
