extends Node3D

var hero: Node3D
var camera: Camera3D
var mode := 0
var orbit := 0.0
var focus := Vector3(0, 1.5, 7.0)
var walking := false
var walkers: Array[Node3D] = []
var info: Label

func _ready() -> void:
	add_child(preload("res://art_review/lane_study.gd").new())
	hero = preload("res://human.gd").new()
	hero.hero_scene = preload("res://assets/characters/shyam_hero_v07.glb")
	hero.position = Vector3(0, 0.03, 7.0)
	hero.rotation.y = PI
	add_child(hero)
	for i in range(8):
		var person = preload("res://human.gd").new()
		person.crowd = true
		person.variant = i + 1
		person.position = Vector3((-1 if i % 2 else 1) * (1.65 if i % 3 else 0.9), 0.03, -18 + i * 3.7)
		person.rotation.y = PI / 2 if i % 3 else 0
		person.movement_speed = 0.7 if i % 3 == 0 else 0.0
		if i % 3 == 0:
			person.rotation.y = PI
			walkers.append(person)
		add_child(person)
	camera = Camera3D.new()
	camera.fov = 42
	camera.near = 0.04
	camera.far = 65
	add_child(camera)
	camera.make_current()
	var canvas := CanvasLayer.new()
	add_child(canvas)
	info = Label.new()
	info.text = "GULABI SAHAR  /  3D ART REVIEW\nF: Face / Full body / Lane    E: Expression    Drag: Orbit\nActual Godot render — candidate for review"
	info.position = Vector2(28, 24)
	info.add_theme_font_size_override("font_size", 17)
	info.add_theme_color_override("font_shadow_color", Color.BLACK)
	info.add_theme_constant_override("shadow_offset_x", 1)
	info.add_theme_constant_override("shadow_offset_y", 2)
	canvas.add_child(info)
	update_camera()

func _process(delta: float) -> void:
	for person in walkers:
		person.position.z += delta * 0.7
		if person.position.z > 18:
			person.position.z = -22

func update_camera() -> void:
	var distance: float = [1.0, 3.6, 7.0][mode]
	var target := hero.position + Vector3(0, 1.59 if mode == 0 else (0.97 if mode == 1 else 1.3), 0)
	camera.fov = 32 if mode == 0 else 46
	camera.position = target + Vector3(sin(orbit) * distance, 0.01 if mode == 0 else 0.40, cos(orbit) * distance)
	camera.look_at(target)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:
			mode = (mode + 1) % 3
			update_camera()
		if event.keycode == KEY_E:
			hero.cycle_expression()
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		orbit += event.relative.x * 0.008
		update_camera()
