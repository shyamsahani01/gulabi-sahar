extends Control

signal face_view
signal expression_changed
signal jump
signal look(delta: Vector2)
var movement := Vector2.ZERO
var running := false
var move_id := -1
var look_id := -1
var knob := Vector2.ZERO
var font := ThemeDB.fallback_font
var frames := 0.0
var elapsed := 0.0
var fps := 0
var portrait := false
var expression_label := "Neutral"
var hindi_font: Font = preload("res://assets/fonts/NotoSansDevanagari-Regular.ttf")
var zones: Array = []
var zone_name: Dictionary = {}
var map_open := false
var map_player := Vector3.ZERO
var map_yaw := 0.0
const MAP_SOUTH := 44.0
const MAP_NORTH := -770.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_window().focus_exited.connect(clear_input)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		clear_input()

func clear_input() -> void:
	move_id = -1
	look_id = -1
	movement = Vector2.ZERO
	knob = Vector2.ZERO
	running = false

func center() -> Vector2:
	return Vector2(140, size.y - 135)
func jump_center() -> Vector2:
	return Vector2(size.x - 120, size.y - 130)
func run_center() -> Vector2:
	return Vector2(size.x - 245, size.y - 95)

func face_center() -> Vector2:
	return Vector2(size.x - 78, 124)
func expression_center() -> Vector2:
	return Vector2(size.x - 100, 190)
func map_center() -> Vector2:
	return Vector2(size.x - 78, 212)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if map_open:
				map_open = false
				return
			if event.position.distance_to(face_center()) < 42:
				face_view.emit()
			elif not portrait and event.position.distance_to(map_center()) < 42:
				map_open = true
			elif portrait and event.position.distance_to(expression_center()) < 64:
				expression_changed.emit()
			elif event.position.distance_to(jump_center()) < 58:
				jump.emit()
			elif event.position.distance_to(run_center()) < 45:
				running = not running
			elif event.position.distance_to(center()) < 115 and move_id == -1:
				move_id = event.index
				update_move(event.position)
			elif event.position.x > size.x * 0.4 and event.position.y > 110 and look_id == -1:
				look_id = event.index
		else:
			if event.index == move_id:
				move_id = -1
				movement = Vector2.ZERO
				knob = Vector2.ZERO
			if event.index == look_id:
				look_id = -1
	if event is InputEventScreenDrag:
		if event.index == move_id:
			update_move(event.position)
		elif event.index == look_id:
			look.emit(event.relative)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if map_open:
			map_open = false
		elif event.position.distance_to(face_center()) < 42:
			face_view.emit()
		elif not portrait and event.position.distance_to(map_center()) < 42:
			map_open = true
		elif portrait and event.position.distance_to(expression_center()) < 64:
			expression_changed.emit()
		elif event.position.distance_to(jump_center()) < 58:
			jump.emit()
		elif event.position.distance_to(run_center()) < 45:
			running = not running

func update_move(pos: Vector2) -> void:
	knob = (pos - center()).limit_length(64)
	movement = knob / 64
	if movement.length() < 0.12:
		movement = Vector2.ZERO

func _process(delta: float) -> void:
	frames += 1
	elapsed += delta
	if elapsed > 0.5:
		fps = int(frames / elapsed)
		frames = 0
		elapsed = 0
	queue_redraw()

func text_at(pos: Vector2, message: String, font_size: int, color: Color) -> void:
	draw_string(font, pos, message, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func hindi_at(pos: Vector2, message: String, font_size: int, color: Color, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1) -> void:
	draw_string(hindi_font, pos, message, align, width, font_size, color)

func _draw() -> void:
	var cream := Color("f4e6d0")
	var muted := Color(0.94, 0.88, 0.77, 0.65)
	draw_style_box(panel(Color(0.09, 0.12, 0.13, 0.85)), Rect2(24, 24, 326, 91))
	draw_rect(Rect2(24, 24, 4, 91), Color("d29b5f"))
	text_at(Vector2(44, 59), "GULABI SAHAR", 27, cream)
	if zone_name.is_empty():
		text_at(Vector2(45, 88), "OLD CITY  /  BAZAAR WALK", 13, muted)
	else:
		hindi_at(Vector2(45, 90), str(zone_name.hindi) + "  /  " + str(zone_name.name).to_upper(), 14, muted)
	if not portrait:
		draw_circle(map_center(), 35, Color(0.1, 0.15, 0.16, 0.85))
		text_at(map_center() + Vector2(-17, 5), "MAP", 15, cream)
	if map_open:
		draw_map()
	draw_style_box(panel(Color(0.09, 0.12, 0.13, 0.75)), Rect2(size.x - 156, 24, 132, 46))
	draw_circle(Vector2(size.x - 133, 47), 4, Color("caa779"))
	text_at(Vector2(size.x - 120, 53), "%d FPS" % fps, 17, cream)
	draw_circle(face_center(), 35, Color(0.1, 0.15, 0.16, 0.85))
	text_at(face_center() + Vector2(-23, 5), "BACK" if portrait else "FACE", 15, cream)
	if portrait:
		draw_style_box(panel(Color(0.1, 0.15, 0.16, 0.9)), Rect2(expression_center() - Vector2(70, 25), Vector2(140, 50)))
		text_at(expression_center() + Vector2(-55, 6), expression_label + " >", 16, cream)
	text_at(Vector2(30, size.y - 22), "WASD  Move    SHIFT  Run    SPACE  Jump    DRAG  Look    R  Reset", 14, muted)
	draw_circle(center(), 94, Color(0.08, 0.12, 0.13, 0.35))
	draw_arc(center(), 94, 0, TAU, 64, Color(0.94, 0.85, 0.69, 0.35), 2, true)
	draw_circle(center() + knob, 38, Color(0.92, 0.83, 0.67, 0.5))
	draw_arc(center() + knob, 38, 0, TAU, 40, cream, 1, true)
	draw_circle(jump_center(), 54, Color(0.1, 0.15, 0.16, 0.65))
	draw_arc(jump_center(), 54, 0, TAU, 48, Color(0.94, 0.85, 0.69, 0.65), 2, true)
	text_at(jump_center() + Vector2(-24, 6), "JUMP", 17, cream)
	draw_circle(run_center(), 40, Color(0.65, 0.39, 0.22, 0.85) if running else Color(0.1, 0.15, 0.16, 0.65))
	text_at(run_center() + Vector2(-18, 5), "RUN", 15, cream)
	text_at(Vector2(size.x - 270, size.y - 221), "DRAG TO LOOK", 12, muted)

func draw_map() -> void:
	# Hand-drawn style tourist map: parchment, pink old city, green colony, brown hills.
	var ink := Color("3a2412")
	var ink_soft := Color(0.23, 0.14, 0.07, 0.6)
	var w := minf(560.0, size.x - 40.0)
	var h := size.y - 60.0
	var origin := Vector2((size.x - w) / 2, 30)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.07, 0.08, 0.55))
	draw_style_box(panel(Color("5a3a22")), Rect2(origin - Vector2(5, 5), Vector2(w + 10, h + 10)))
	draw_style_box(panel(Color("ecdfc4")), Rect2(origin, Vector2(w, h)))
	draw_style_box(panel(Color("e3d3b3")), Rect2(origin + Vector2(8, 8), Vector2(w - 16, h - 16)))
	var top := origin.y + 58.0
	var bottom := origin.y + h - 64.0
	var left := origin.x + 118.0
	var right := origin.x + w - 18.0
	var center_x := (left + right) / 2 + 10.0
	var scale_x := (right - left - 30.0) / 150.0
	var y_of := func(z: float) -> float: return top + (z - MAP_NORTH) / (MAP_SOUTH - MAP_NORTH) * (bottom - top)
	var x_of := func(x: float) -> float: return center_x + x * scale_x
	hindi_at(Vector2(origin.x + 18, origin.y + 32), "गुलाबी सहर", 24, ink)
	text_at(Vector2(origin.x + 150, origin.y + 31), "HAWA MAHAL  →  NAHARGARH", 12, ink_soft)
	text_at(Vector2(origin.x + w - 96, origin.y + 31), "tap to close", 11, ink_soft)
	# Compass rose.
	var rose := Vector2(origin.x + w - 44, origin.y + 92)
	draw_circle(rose, 18, Color("e3d3b3"))
	draw_arc(rose, 18, 0, TAU, 40, ink_soft, 1.5, true)
	draw_colored_polygon(PackedVector2Array([rose + Vector2(0, -22), rose + Vector2(-6, 2), rose + Vector2(6, 2)]), Color("b64e36"))
	draw_colored_polygon(PackedVector2Array([rose + Vector2(0, 22), rose + Vector2(-6, -2), rose + Vector2(6, -2)]), ink_soft)
	text_at(rose + Vector2(-5, -26), "N", 12, ink)
	# Zone bands with a soft tint and a name tab on the left.
	var tints := [Color("d9a08c"), Color("dcae9c"), Color("c8c2b3"), Color("b9cf98"), Color("c7b08e")]
	for i in range(zones.size()):
		var zone: Dictionary = zones[i]
		var y0: float = y_of.call(zone.to)
		var y1: float = y_of.call(zone.from)
		draw_rect(Rect2(left, y0, right - left, y1 - y0), Color(tints[i % tints.size()], 0.55))
		draw_line(Vector2(left, y1), Vector2(right, y1), Color(0.23, 0.14, 0.07, 0.25), 1)
		draw_rect(Rect2(origin.x + 14, y0 + 6, 96, 34), Color(0.95, 0.9, 0.8, 0.8))
		draw_rect(Rect2(origin.x + 14, y0 + 6, 4, 34), tints[i % tints.size()].darkened(0.3))
		hindi_at(Vector2(origin.x + 24, y0 + 21), str(zone.hindi), 11, ink)
		text_at(Vector2(origin.x + 24, y0 + 34), str(zone.name).to_upper(), 8, ink_soft)
	# Hills: contour ridges, rampart and fort.
	for ridge in range(7):
		var z := -500.0 - ridge * 38.0
		var points := PackedVector2Array()
		for k in range(0, 41):
			var x := -75.0 + k * 3.75
			points.append(Vector2(x_of.call(x), y_of.call(z + sin(x * 0.12 + ridge) * 9.0 - absf(x) * 0.08 * ridge)))
		draw_polyline(points, Color(0.42, 0.33, 0.2, 0.35 + ridge * 0.04), 1.5, true)
	var wall := PackedVector2Array()
	for k in range(0, 41):
		var x := -70.0 + k * 3.5
		wall.append(Vector2(x_of.call(x), y_of.call(-700.0 + sin(x * 0.03) * 12.0)))
	draw_polyline(wall, Color("6b5134"), 3.0, true)
	for k in range(0, 41, 4):
		draw_rect(Rect2(wall[k] - Vector2(2, 5), Vector2(4, 5)), Color("6b5134"))
	draw_rect(Rect2(x_of.call(-9.0), y_of.call(-722.0), 18 * scale_x, y_of.call(-706.0) - y_of.call(-722.0)), Color("8a6a46"))
	for dome in [-5.0, 0.0, 5.0]:
		draw_circle(Vector2(x_of.call(dome), y_of.call(-722.0)), 3, Color("8a6a46"))
	# Road, median, side lanes, old gali.
	draw_line(Vector2(x_of.call(0.0), y_of.call(-500.0)), Vector2(x_of.call(0.0), y_of.call(44.0)), Color("4a4b4c"), 11)
	var dash_z := 40.0
	while dash_z > -500.0:
		draw_line(Vector2(x_of.call(0.0), y_of.call(dash_z)), Vector2(x_of.call(0.0), y_of.call(dash_z - 4.0)), Color("ecdfc4"), 1)
		dash_z -= 10.0
	draw_line(Vector2(x_of.call(0.0), y_of.call(-100.0)), Vector2(x_of.call(0.0), y_of.call(40.0)), Color("5f8a3f"), 3)
	draw_line(Vector2(x_of.call(0.0), y_of.call(-480.0)), Vector2(x_of.call(0.0), y_of.call(-300.0)), Color("5f8a3f"), 3)
	for lane_z in [-348.0, -354.0, -420.0]:
		draw_line(Vector2(x_of.call(-12.0), y_of.call(lane_z)), Vector2(x_of.call(-40.0), y_of.call(lane_z)), Color("6e6a62"), 2)
	draw_line(Vector2(x_of.call(-12.0), y_of.call(20.0)), Vector2(x_of.call(-66.0), y_of.call(20.0)), Color("6e6a62"), 4)
	# Building blocks along the road.
	var block_z := 36.0
	while block_z > -300.0:
		var key: Color = Color("c9775f") if block_z > -120.0 else Color("a9a49a")
		var depth := 8.0 if block_z > -120.0 else 12.0
		var skip_west := block_z > -40.0 and block_z < 30.0 and block_z > 5.0
		if not skip_west:
			draw_rect(Rect2(x_of.call(-12.0 - depth), y_of.call(block_z), depth * scale_x, y_of.call(block_z - 8.0) - y_of.call(block_z)), key)
		draw_rect(Rect2(x_of.call(12.0), y_of.call(block_z), depth * scale_x, y_of.call(block_z - 8.0) - y_of.call(block_z)), key)
		block_z -= 10.0
	var plot_z := -318.0
	while plot_z > -470.0:
		draw_rect(Rect2(x_of.call(-23.0), y_of.call(plot_z), 11 * scale_x, y_of.call(plot_z - 10.0) - y_of.call(plot_z)), Color("e7d9b8"))
		if plot_z > -376.0 or plot_z < -446.0:
			draw_rect(Rect2(x_of.call(12.0), y_of.call(plot_z), 11 * scale_x, y_of.call(plot_z - 10.0) - y_of.call(plot_z)), Color("e7d9b8"))
		plot_z -= 12.0
	for bz in [-40.0, -30.0, -20.0, -10.0]:
		draw_rect(Rect2(x_of.call(-70.0), y_of.call(28.0), 54 * scale_x, 4), Color("c9775f"))
		draw_rect(Rect2(x_of.call(-70.0), y_of.call(12.0), 54 * scale_x, 4), Color("c9775f"))
	# Landmarks.
	var hm := Rect2(x_of.call(-20.0), y_of.call(-40.0), 8 * scale_x, y_of.call(0.0) - y_of.call(-40.0))
	draw_rect(hm, Color("b64e36"))
	for row in range(5):
		draw_line(Vector2(hm.position.x + 1, hm.position.y + 3 + row * (hm.size.y / 5)), Vector2(hm.end.x - 1, hm.position.y + 3 + row * (hm.size.y / 5)), Color("f2d6b8"), 1)
	for dome in range(3):
		draw_circle(Vector2(hm.position.x + hm.size.x * (0.2 + dome * 0.3), hm.position.y - 2), 2.5, Color("b64e36"))
	draw_rect(Rect2(x_of.call(-26.0), y_of.call(-114.0), 52 * scale_x, 5), Color("b64e36"))
	draw_rect(Rect2(x_of.call(-26.0), y_of.call(-112.0), 5 * scale_x, 10), Color("b64e36"))
	draw_rect(Rect2(x_of.call(21.0), y_of.call(-112.0), 5 * scale_x, 10), Color("b64e36"))
	draw_rect(Rect2(x_of.call(14.0), y_of.call(-239.0), 12 * scale_x, y_of.call(-221.0) - y_of.call(-239.0)), Color("e9a23a"))
	text_at(Vector2(x_of.call(16.5), y_of.call(-226.0)), "P", 10, Color("ffffff"))
	draw_rect(Rect2(x_of.call(11.0), y_of.call(-444.0), 30 * scale_x, y_of.call(-378.0) - y_of.call(-444.0)), Color("6fa35a"))
	for tree in [[18.0, -390.0], [30.0, -400.0], [22.0, -420.0], [34.0, -432.0], [16.0, -436.0]]:
		draw_circle(Vector2(x_of.call(tree[0]), y_of.call(tree[1])), 3.5, Color("3f6a3a"))
	draw_rect(Rect2(x_of.call(-21.0), y_of.call(-456.0), 8 * scale_x, 7), Color("f6efe0"))
	draw_colored_polygon(PackedVector2Array([Vector2(x_of.call(-17.0), y_of.call(-458.0) - 9), Vector2(x_of.call(-20.0), y_of.call(-456.0)), Vector2(x_of.call(-14.0), y_of.call(-456.0))]), Color("e9742a"))
	var step_z := -512.0
	while step_z > -600.0:
		draw_line(Vector2(x_of.call(-1.5), y_of.call(step_z)), Vector2(x_of.call(1.5), y_of.call(step_z)), Color("8a6a46"), 1)
		step_z -= 6.0
	draw_circle(Vector2(x_of.call(0.0), y_of.call(-604.0)), 4, Color("8a6a46"))
	draw_arc(Vector2(x_of.call(0.0), y_of.call(-604.0)), 6, PI, TAU, 12, Color("8a6a46"), 1.5, true)
	for lamp in [-30.0, -70.0, -210.0, -330.0, -430.0]:
		draw_circle(Vector2(x_of.call(0.0), y_of.call(lamp)), 1.5, Color("d9a441"))
	var labels := [["हवा महल", -58.0, -16.0], ["पुरानी गली", -68.0, 32.0], ["चाँदपोल गेट", 28.0, -124.0], ["पेट्रोल पंप", 28.0, -244.0], ["सेक्टर पार्क", 43.0, -405.0], ["मंदिर", -50.0, -460.0], ["व्यू पॉइंट", 8.0, -604.0], ["नाहरगढ़ किला", 10.0, -730.0]]
	for item in labels:
		hindi_at(Vector2(x_of.call(item[1]), y_of.call(item[2]) + 4), str(item[0]), 10, ink)
	# Scale bar and legend.
	var bar_y := origin.y + h - 40.0
	draw_line(Vector2(origin.x + 20, bar_y), Vector2(origin.x + 20 + (y_of.call(0.0) - y_of.call(100.0)), bar_y), ink, 2)
	text_at(Vector2(origin.x + 20, bar_y + 14), "100 m", 9, ink_soft)
	var legend := [[Color("b64e36"), "पुराना शहर"], [Color("a9a49a"), "सीकर रोड"], [Color("e7d9b8"), "कॉलोनी"], [Color("6fa35a"), "पार्क"], [Color("8a6a46"), "पहाड़ / किला"]]
	var lx := origin.x + 150.0
	for item in legend:
		draw_rect(Rect2(lx, bar_y - 6, 12, 12), item[0])
		hindi_at(Vector2(lx + 16, bar_y + 4), str(item[1]), 10, ink)
		lx += 86.0
	# Player marker with a pulse.
	var p := Vector2(x_of.call(map_player.x), y_of.call(map_player.z))
	var forward := Vector2(-sin(map_yaw), -cos(map_yaw)).normalized()
	var pulse := 10.0 + 6.0 * (0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.004))
	draw_arc(p, pulse, 0, TAU, 32, Color(0.2, 0.45, 0.8, 0.5), 2, true)
	draw_colored_polygon(PackedVector2Array([p + forward * 18, p + forward.rotated(2.6) * 9, p + forward.rotated(-2.6) * 9]), Color("2f6fb5"))
	draw_circle(p, 6, Color("f6efe0"))
	draw_circle(p, 4, Color("2f6fb5"))
	draw_rect(Rect2(p + Vector2(10, -9), Vector2(68, 18)), Color(0.96, 0.94, 0.88, 0.9))
	hindi_at(p + Vector2(14, 4), "आप यहाँ हैं", 10, ink)

func panel(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(8)
	return style
