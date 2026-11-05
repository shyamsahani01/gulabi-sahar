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
	var cream := Color("f4e6d0")
	var w := minf(460.0, size.x - 40.0)
	var h := size.y - 70.0
	var origin := Vector2((size.x - w) / 2, 35)
	draw_style_box(panel(Color(0.07, 0.1, 0.11, 0.94)), Rect2(origin, Vector2(w, h)))
	var top := origin.y + 44.0
	var bottom := origin.y + h - 22.0
	var center_x := origin.x + w * 0.56
	var scale_x := (w - 90.0) / 170.0
	var y_of := func(z: float) -> float: return top + (z - MAP_NORTH) / (MAP_SOUTH - MAP_NORTH) * (bottom - top)
	var x_of := func(x: float) -> float: return center_x + x * scale_x
	hindi_at(Vector2(origin.x + 18, origin.y + 28), "गुलाबी सहर का नक्शा  •  MAP", 18, cream)
	text_at(Vector2(origin.x + w - 118, origin.y + 28), "N ▲   tap to close", 12, Color(0.94, 0.88, 0.77, 0.6))
	var tints := [Color("c9775f"), Color("c38573"), Color("8a8a85"), Color("8fae6a"), Color("8b7a66")]
	for i in range(zones.size()):
		var zone: Dictionary = zones[i]
		var y0: float = y_of.call(zone.to)
		var y1: float = y_of.call(zone.from)
		draw_rect(Rect2(origin.x + 12, y0, w - 24, y1 - y0), Color(tints[i % tints.size()], 0.16))
		draw_line(Vector2(origin.x + 12, y1), Vector2(origin.x + w - 12, y1), Color(0.94, 0.88, 0.77, 0.25), 1)
		hindi_at(Vector2(origin.x + 20, y0 + 20), str(zone.hindi), 14, cream)
		text_at(Vector2(origin.x + 20, y0 + 36), str(zone.name).to_upper(), 10, Color(0.94, 0.88, 0.77, 0.6))
	# Hills, road, median, old gali, landmarks.
	draw_rect(Rect2(origin.x + 12, y_of.call(-770.0), w - 24, y_of.call(-480.0) - y_of.call(-770.0)), Color(0.42, 0.36, 0.28, 0.25))
	draw_line(Vector2(x_of.call(0.0), y_of.call(-510.0)), Vector2(x_of.call(0.0), y_of.call(44.0)), Color(0.35, 0.36, 0.37), 10)
	draw_line(Vector2(x_of.call(0.0), y_of.call(-100.0)), Vector2(x_of.call(0.0), y_of.call(40.0)), Color(0.4, 0.55, 0.3), 2)
	draw_line(Vector2(x_of.call(0.0), y_of.call(-480.0)), Vector2(x_of.call(0.0), y_of.call(-300.0)), Color(0.4, 0.55, 0.3), 2)
	draw_line(Vector2(x_of.call(-12.0), y_of.call(20.0)), Vector2(x_of.call(-66.0), y_of.call(20.0)), Color(0.35, 0.36, 0.37), 4)
	draw_rect(Rect2(x_of.call(-20.0), y_of.call(-40.0), 8 * scale_x, y_of.call(0.0) - y_of.call(-40.0)), Color("e8926e"))
	draw_rect(Rect2(x_of.call(11.0), y_of.call(-444.0), 30 * scale_x, y_of.call(-378.0) - y_of.call(-444.0)), Color("5fa565"))
	draw_rect(Rect2(x_of.call(-21.0), y_of.call(-456.0), 8 * scale_x, 6), Color("f29b3c"))
	draw_rect(Rect2(x_of.call(14.0), y_of.call(-239.0), 12 * scale_x, y_of.call(-221.0) - y_of.call(-239.0)), Color("e9c74a"))
	draw_line(Vector2(x_of.call(-27.0), y_of.call(-118.0)), Vector2(x_of.call(27.0), y_of.call(-118.0)), Color("e8926e"), 4)
	draw_line(Vector2(x_of.call(-70.0), y_of.call(-700.0)), Vector2(x_of.call(70.0), y_of.call(-700.0)), Color("c9b48c"), 3)
	draw_circle(Vector2(x_of.call(0.0), y_of.call(-604.0)), 4, Color("c9b48c"))
	var labels := [["हवा महल", -34.0, -20.0], ["पुरानी गली", -66.0, 14.0], ["चाँदपोल गेट", 30.0, -118.0], ["पेट्रोल पंप", 28.0, -230.0], ["सेक्टर पार्क", 42.0, -411.0], ["मंदिर", -40.0, -452.0], ["व्यू पॉइंट", 10.0, -604.0], ["नाहरगढ़", 10.0, -712.0]]
	for item in labels:
		hindi_at(Vector2(x_of.call(item[1]), y_of.call(item[2]) + 4), str(item[0]), 11, Color(0.94, 0.88, 0.77, 0.8))
	var p := Vector2(x_of.call(map_player.x), y_of.call(map_player.z))
	var forward := Vector2(-sin(map_yaw), -cos(map_yaw)).normalized()
	draw_circle(p, 7, Color("f4e6d0"))
	draw_circle(p, 5, Color("d29b5f"))
	draw_colored_polygon(PackedVector2Array([p + forward * 16, p + forward.rotated(2.5) * 9, p + forward.rotated(-2.5) * 9]), Color("f4e6d0"))
	text_at(p + Vector2(12, 4), "YOU", 11, cream)

func panel(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(8)
	return style
