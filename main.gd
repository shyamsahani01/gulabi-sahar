extends Node3D

var player: CharacterBody3D
var pivot: Node3D
var avatar: Node3D
var yaw := 0.0
var pitch := -0.14
var touch_move := Vector2.ZERO
var jump_requested := false
var portrait := false
var portrait_angle := 0.0
var portrait_height := 0.0
var portrait_camera: Camera3D
var hud: Control

func _ready() -> void:
	var street = preload("res://art_review/lane_study.gd").new()
	add_child(street)
	var activity = preload("res://market_life.gd").new()
	activity.lane_study = true
	add_child(activity)

	player = CharacterBody3D.new()
	player.name = "Player"
	player.collision_mask = 3
	player.position = Vector3(0, 0.1, 20)
	player.floor_snap_length = 0.35
	player.floor_max_angle = deg_to_rad(48)
	add_child(player)
	activity.player = player
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.75
	collision.shape = capsule
	collision.position.y = 0.88
	player.add_child(collision)
	build_avatar()
	pivot = Node3D.new()
	pivot.position.y = 1.55
	player.add_child(pivot)
	var arm := SpringArm3D.new()
	arm.spring_length = 4.8
	arm.margin = 0.2
	arm.add_excluded_object(player.get_rid())
	pivot.add_child(arm)
	var camera := Camera3D.new()
	camera.current = true
	camera.fov = 68
	camera.near = 0.15
	camera.far = 100
	arm.add_child(camera)
	var canvas := CanvasLayer.new()
	add_child(canvas)
	hud = preload("res://tablet_controls.gd").new()
	canvas.add_child(hud)
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait_camera = Camera3D.new()
	portrait_camera.fov = 32
	portrait_camera.near = 0.03
	avatar.add_child(portrait_camera)
	portrait_camera.position = Vector3(0, 1.58, -0.85)
	portrait_camera.rotation.y = PI
	hud.face_view.connect(toggle_portrait)
	hud.expression_changed.connect(func():
		avatar.cycle_expression()
		hud.expression_label = avatar.expression)
	hud.jump.connect(func(): jump_requested = true)
	hud.look.connect(func(delta: Vector2):
		if portrait:
			orbit_portrait(delta)
			return
		yaw -= delta.x * 0.004
		pitch = clampf(pitch - delta.y * 0.004, -0.7, 0.18))

func toggle_portrait() -> void:
	portrait = not portrait
	hud.portrait = portrait
	hud.clear_input()
	if portrait:
		portrait_angle = 0.0
		portrait_height = 0.0
		orbit_portrait(Vector2.ZERO)
		portrait_camera.make_current()
	else:
		pivot.get_child(0).get_child(0).make_current()

func orbit_portrait(delta: Vector2) -> void:
	portrait_angle = clampf(portrait_angle - delta.x * 0.006, -0.85, 0.85)
	portrait_height = clampf(portrait_height + delta.y * 0.0008, -0.08, 0.10)
	portrait_camera.position = Vector3(sin(portrait_angle) * 0.85, 1.58 + portrait_height, -cos(portrait_angle) * 0.85)
	portrait_camera.look_at(avatar.to_global(Vector3(0, 1.58, 0)))

func build_avatar() -> void:
	avatar = preload("res://human.gd").new()
	player.add_child(avatar)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if event.position.x > 400 and event.position.y < 570:
			if portrait:
				orbit_portrait(event.relative)
				return
			yaw -= event.relative.x * 0.004
			pitch = clampf(pitch - event.relative.y * 0.004, -0.7, 0.18)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:
			toggle_portrait()
		elif event.keycode == KEY_E:
			avatar.cycle_expression()
			hud.expression_label = avatar.expression
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		player.position = Vector3(0, 1, 20)
		player.velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var move: Vector2 = (touch_move + hud.movement).limit_length()
	move.x += float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
	move.y += float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	if portrait:
		move = Vector2.ZERO
	var direction := Basis(Vector3.UP, yaw) * Vector3(move.x, 0, move.y).limit_length()
	var running: bool = Input.is_physical_key_pressed(KEY_SHIFT) or hud.running
	var speed := 5.2 if running else 2.3
	player.velocity.x = move_toward(player.velocity.x, direction.x * speed, delta * 22)
	player.velocity.z = move_toward(player.velocity.z, direction.z * speed, delta * 22)
	if not player.is_on_floor():
		player.velocity.y -= 22 * delta
	elif Input.is_physical_key_pressed(KEY_SPACE) or jump_requested:
		player.velocity.y = 7
	jump_requested = false
	player.move_and_slide()
	pivot.rotation = Vector3(pitch, yaw, 0)
	var moving := direction.length() > 0.05
	if moving:
		avatar.rotation.y = lerp_angle(avatar.rotation.y, atan2(-direction.x, -direction.z), delta * 12)
	avatar.movement_speed = Vector2(player.velocity.x, player.velocity.z).length()
	avatar.grounded = player.is_on_floor()
	if player.position.y < -10:
		player.position = Vector3(0, 2, 20)
		player.velocity = Vector3.ZERO
