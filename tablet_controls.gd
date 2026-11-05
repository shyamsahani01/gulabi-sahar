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
var map_zoom := 1.0
var map_pan := Vector2.ZERO
var map_drag_id := -1
var map_mouse_drag := false
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

func map_close_center() -> Vector2:
	return Vector2(size.x - 44, 44)
func map_zoom_in_center() -> Vector2:
	return Vector2(size.x - 44, size.y * 0.5 - 34)
func map_zoom_out_center() -> Vector2:
	return Vector2(size.x - 44, size.y * 0.5 + 34)

func map_tap(pos: Vector2) -> bool:
	# Returns true when the tap hit a map control.
	if pos.distance_to(map_close_center()) < 30:
		map_open = false
		return true
	if pos.distance_to(map_zoom_in_center()) < 30:
		set_map_zoom(map_zoom * 1.5)
		return true
	if pos.distance_to(map_zoom_out_center()) < 30:
		set_map_zoom(map_zoom / 1.5)
		return true
	return false

func set_map_zoom(value: float) -> void:
	# Zoom around the player so they stay where they are on screen.
	var before := map_point(map_player.x, map_player.z)
	map_zoom = clampf(value, 1.0, 4.0)
	var after := map_point(map_player.x, map_player.z)
	map_pan += before - after
	clamp_map_pan()

func map_scale() -> float:
	return (size.x - 60.0) / (MAP_SOUTH - MAP_NORTH) * map_zoom

const MAP_STRETCH := 2.2

func map_point(x: float, z: float) -> Vector2:
	# North points right; west is up. The road runs across the wide screen, and the
	# narrow strip of a world is stretched sideways so the sheet fills the screen.
	var s := map_scale()
	return Vector2(30.0 + (MAP_SOUTH - z) * s, size.y * 0.5 + x * s * MAP_STRETCH) + map_pan

func map_rect(x0: float, z0: float, x1: float, z1: float) -> Rect2:
	var a := map_point(minf(x0, x1), maxf(z0, z1))
	var b := map_point(maxf(x0, x1), minf(z0, z1))
	return Rect2(a, b - a)

func clamp_map_pan() -> void:
	var s := map_scale()
	var width := (MAP_SOUTH - MAP_NORTH) * s
	var height := 240.0 * s * MAP_STRETCH
	map_pan.x = clampf(map_pan.x, minf(0.0, size.x - 60.0 - width), 0.0)
	map_pan.y = clampf(map_pan.y, -height / 2 + 40.0, height / 2 - 40.0)

func _input(event: InputEvent) -> void:
	if map_open:
		if event is InputEventScreenTouch:
			if event.pressed:
				if not map_tap(event.position) and map_drag_id == -1:
					map_drag_id = event.index
			elif event.index == map_drag_id:
				map_drag_id = -1
		elif event is InputEventScreenDrag and event.index == map_drag_id:
			map_pan += event.relative
			clamp_map_pan()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				map_mouse_drag = not map_tap(event.position)
			else:
				map_mouse_drag = false
		elif event is InputEventMouseMotion and map_mouse_drag:
			map_pan += event.relative
			clamp_map_pan()
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			set_map_zoom(map_zoom * 1.2)
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			set_map_zoom(map_zoom / 1.2)
		return
	if event is InputEventScreenTouch:
		if event.pressed:
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
	if map_open:
		draw_map()
		return
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
	# Full-screen tourist map, north to the right: parchment, pink old city, green colony, brown hills.
	var ink := Color("3a2412")
	var ink_soft := Color(0.23, 0.14, 0.07, 0.6)
	var s := map_scale()
	draw_rect(Rect2(Vector2.ZERO, size), Color("5a3a22"))
	draw_rect(Rect2(Vector2(8, 8), size - Vector2(16, 16)), Color("e3d3b3"))
	# Zone bands.
	var tints := [Color("d9a08c"), Color("dcae9c"), Color("c8c2b3"), Color("b9cf98"), Color("c7b08e")]
	for i in range(zones.size()):
		var zone: Dictionary = zones[i]
		draw_rect(map_rect(-120.0, zone.from, 120.0, zone.to), Color(tints[i % tints.size()], 0.6))
		var edge := map_point(-120.0, zone.from)
		draw_line(edge, map_point(120.0, zone.from), Color(0.23, 0.14, 0.07, 0.3), 1)
		var tab := map_point(-118.0, zone.from - 3.0)
		draw_rect(Rect2(tab, Vector2(118, 36)), Color(0.95, 0.9, 0.8, 0.85))
		draw_rect(Rect2(tab, Vector2(4, 36)), tints[i % tints.size()].darkened(0.3))
		hindi_at(tab + Vector2(10, 15), str(zone.hindi), 11, ink)
		text_at(tab + Vector2(10, 29), str(zone.name).to_upper(), 8, ink_soft)
	draw_rect(map_rect(24, -274, 100, -226), Color("cb9878"))
	draw_line(map_point(12, -250), map_point(99, -250), Color("ede0c9"), 5)
	text_at(map_point(40, -250), "ARTISAN SQUARE", 10, ink)
	# Hills: contour ridges, rampart, fort.
	for ridge in range(8):
		var z := -500.0 - ridge * 34.0
		var points := PackedVector2Array()
		for k in range(0, 49):
			var x := -120.0 + k * 5.0
			points.append(map_point(x + absf(x) * 0.0, z - sin(x * 0.1 + ridge) * 9.0 - absf(x) * 0.12 * ridge))
		draw_polyline(points, Color(0.42, 0.33, 0.2, 0.3 + ridge * 0.04), 1.5, true)
	var wall := PackedVector2Array()
	for k in range(0, 49):
		var x := -120.0 + k * 5.0
		wall.append(map_point(x, -700.0 + sin(x * 0.03) * 12.0))
	draw_polyline(wall, Color("6b5134"), maxf(2.5, 2.0 * s), true)
	for k in range(0, 49, 4):
		draw_rect(Rect2(wall[k] - Vector2(5, 2), Vector2(5, 4)), Color("6b5134"))
	draw_rect(map_rect(-18.0, -706.0, 18.0, -726.0), Color("8a6a46"))
	for dome in [-12.0, 0.0, 12.0]:
		draw_circle(map_point(dome, -726.0), maxf(2.5, 2.0 * s), Color("8a6a46"))
	for scrub in range(40):
		var sx := -110.0 + (scrub * 37) % 220
		var sz := -485.0 - (scrub * 53) % 280
		draw_circle(map_point(sx, sz), maxf(1.5, 1.6 * s), Color(0.33, 0.42, 0.25, 0.7))
	# Road, median, side lanes, old gali.
	draw_line(map_point(0.0, 44.0), map_point(0.0, -500.0), Color("4a4b4c"), maxf(8.0, 17.0 * s))
	var dash_z := 40.0
	while dash_z > -500.0:
		draw_line(map_point(0.0, dash_z), map_point(0.0, dash_z - 4.0), Color("ecdfc4"), 1)
		dash_z -= 10.0
	draw_line(map_point(0.0, 40.0), map_point(0.0, -100.0), Color("5f8a3f"), maxf(2.0, 3.0 * s))
	draw_line(map_point(0.0, -300.0), map_point(0.0, -480.0), Color("5f8a3f"), maxf(2.0, 4.0 * s))
	for lane_z in [-348.0, -354.0, -420.0]:
		draw_line(map_point(-12.0, lane_z), map_point(-40.0, lane_z), Color("6e6a62"), maxf(2.0, 5.0 * s))
	draw_line(map_point(-12.0, 20.0), map_point(-66.0, 20.0), Color("6e6a62"), maxf(3.0, 5.2 * s))
	# Building blocks along the road.
	var block_z := 36.0
	while block_z > -300.0:
		var key: Color = Color("c9775f") if block_z > -120.0 else Color("a9a49a")
		var depth := 8.0 if block_z > -120.0 else 12.0
		if not (block_z <= 30.0 and block_z > 5.0):
			draw_rect(map_rect(-12.0 - depth, block_z, -12.0, block_z - 8.0), key)
		draw_rect(map_rect(12.0, block_z, 12.0 + depth, block_z - 8.0), key)
		block_z -= 10.0
	var plot_z := -318.0
	while plot_z > -470.0:
		draw_rect(map_rect(-23.0, plot_z, -12.0, plot_z - 10.0), Color("e7d9b8"))
		if plot_z > -376.0 or plot_z < -446.0:
			draw_rect(map_rect(12.0, plot_z, 23.0, plot_z - 10.0), Color("e7d9b8"))
		plot_z -= 12.0
	draw_rect(map_rect(-70.0, 30.0, -16.0, 26.0), Color("c9775f"))
	draw_rect(map_rect(-70.0, 14.0, -16.0, 10.0), Color("c9775f"))
	# Landmarks.
	var hm := map_rect(-20.0, 0.0, -12.0, -40.0)
	draw_rect(hm, Color("b64e36"))
	for row in range(5):
		var ry := hm.position.y + 2 + row * (hm.size.y / 5)
		draw_line(Vector2(hm.position.x + 1, ry), Vector2(hm.end.x - 1, ry), Color("f2d6b8"), 1)
	for dome in range(3):
		draw_circle(Vector2(hm.position.x - 2, hm.position.y + hm.size.y * (0.2 + dome * 0.3)), maxf(2.0, 1.5 * s), Color("b64e36"))
	draw_rect(map_rect(-26.0, -116.0, 26.0, -120.0), Color("b64e36"))
	draw_rect(map_rect(-26.0, -113.0, -21.0, -123.0), Color("b64e36"))
	draw_rect(map_rect(21.0, -113.0, 26.0, -123.0), Color("b64e36"))
	var pump := map_rect(14.0, -221.0, 26.0, -239.0)
	draw_rect(pump, Color("e9a23a"))
	text_at(pump.position + Vector2(pump.size.x * 0.5 - 4, pump.size.y * 0.5 + 4), "P", 10, Color("ffffff"))
	draw_rect(map_rect(11.0, -378.0, 41.0, -444.0), Color("6fa35a"))
	for tree in [[18.0, -390.0], [30.0, -400.0], [22.0, -420.0], [34.0, -432.0], [16.0, -436.0]]:
		draw_circle(map_point(tree[0], tree[1]), maxf(2.5, 2.2 * s), Color("3f6a3a"))
	var temple := map_rect(-21.0, -448.0, -13.0, -456.0)
	draw_rect(temple, Color("f6efe0"))
	draw_colored_polygon(PackedVector2Array([temple.position + Vector2(temple.size.x * 0.5, -9), temple.position, temple.position + Vector2(temple.size.x, 0)]), Color("e9742a"))
	var step_z := -512.0
	while step_z > -600.0:
		draw_line(map_point(-1.5, step_z), map_point(1.5, step_z), Color("8a6a46"), 1)
		step_z -= 6.0
	draw_circle(map_point(0.0, -604.0), maxf(3.0, 2.5 * s), Color("8a6a46"))
	for lamp in [-30.0, -70.0, -210.0, -330.0, -430.0]:
		draw_circle(map_point(0.0, lamp), 1.5, Color("d9a441"))
	var labels := [["हवा महल", -34.0, -4.0], ["पुरानी गली", -78.0, 32.0], ["चाँदपोल गेट", 30.0, -108.0], ["पेट्रोल पंप", 29.0, -214.0], ["सेक्टर पार्क", 44.0, -396.0], ["मंदिर", -36.0, -446.0], ["व्यू पॉइंट", 6.0, -596.0], ["नाहरगढ़ किला", 22.0, -706.0]]
	for item in labels:
		hindi_at(map_point(item[1], item[2]), str(item[0]), 10, ink)
	# Player marker with a pulse.
	var p := map_point(map_player.x, map_player.z)
	var forward := Vector2(cos(map_yaw), -sin(map_yaw)).normalized()
	var pulse := 10.0 + 6.0 * (0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.004))
	draw_arc(p, pulse, 0, TAU, 32, Color(0.2, 0.45, 0.8, 0.5), 2, true)
	draw_colored_polygon(PackedVector2Array([p + forward * 18, p + forward.rotated(2.6) * 9, p + forward.rotated(-2.6) * 9]), Color("2f6fb5"))
	draw_circle(p, 6, Color("f6efe0"))
	draw_circle(p, 4, Color("2f6fb5"))
	draw_rect(Rect2(p + Vector2(10, -9), Vector2(68, 18)), Color(0.96, 0.94, 0.88, 0.9))
	hindi_at(p + Vector2(14, 4), "आप यहाँ हैं", 10, ink)
	# Frame: title bar, legend bar and controls drawn over the map edges.
	draw_rect(Rect2(0, 0, size.x, 64), Color("ecdfc4"))
	draw_rect(Rect2(0, size.y - 44, size.x, 44), Color("ecdfc4"))
	draw_line(Vector2(0, 64), Vector2(size.x, 64), Color("5a3a22"), 2)
	draw_line(Vector2(0, size.y - 44), Vector2(size.x, size.y - 44), Color("5a3a22"), 2)
	hindi_at(Vector2(24, 42), "गुलाबी सहर का नक्शा", 24, ink)
	text_at(Vector2(300, 41), "HAWA MAHAL  →  NAHARGARH      drag to move  •  +/− zoom  •  %.1fx" % map_zoom, 12, ink_soft)
	var rose := Vector2(size.x - 110, 36)
	draw_circle(rose, 18, Color("e3d3b3"))
	draw_arc(rose, 18, 0, TAU, 40, ink_soft, 1.5, true)
	draw_colored_polygon(PackedVector2Array([rose + Vector2(22, 0), rose + Vector2(-2, -6), rose + Vector2(-2, 6)]), Color("b64e36"))
	text_at(rose + Vector2(-28, 5), "N", 12, ink)
	draw_circle(map_close_center(), 24, Color("5a3a22"))
	text_at(map_close_center() + Vector2(-5, 6), "X", 16, Color("f6efe0"))
	for pair in [[map_zoom_in_center(), "+"], [map_zoom_out_center(), "−"]]:
		draw_circle(pair[0], 24, Color("5a3a22"))
		text_at(pair[0] + Vector2(-6, 7), str(pair[1]), 20, Color("f6efe0"))
	var bar_y := size.y - 20.0
	draw_line(Vector2(24, bar_y), Vector2(24 + 100.0 * s, bar_y), ink, 2)
	text_at(Vector2(24, bar_y - 6), "100 m", 9, ink_soft)
	var legend := [[Color("b64e36"), "पुराना शहर"], [Color("a9a49a"), "सीकर रोड"], [Color("e7d9b8"), "कॉलोनी"], [Color("6fa35a"), "पार्क"], [Color("8a6a46"), "पहाड़ / किला"], [Color("2f6fb5"), "आप"]]
	var lx := 24 + 100.0 * s + 40.0
	for item in legend:
		draw_rect(Rect2(lx, bar_y - 8, 12, 12), item[0])
		hindi_at(Vector2(lx + 16, bar_y + 3), str(item[1]), 10, ink)
		lx += 96.0

func panel(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(8)
	return style
