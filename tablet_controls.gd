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

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.distance_to(face_center()) < 42:
				face_view.emit()
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

func _draw() -> void:
	var cream := Color("f4e6d0")
	var muted := Color(0.94, 0.88, 0.77, 0.65)
	draw_style_box(panel(Color(0.09, 0.12, 0.13, 0.85)), Rect2(24, 24, 326, 91))
	draw_rect(Rect2(24, 24, 4, 91), Color("d29b5f"))
	text_at(Vector2(44, 59), "GULABI SAHAR", 27, cream)
	text_at(Vector2(45, 88), "OLD CITY  /  BAZAAR WALK", 13, muted)
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

func panel(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(8)
	return style
