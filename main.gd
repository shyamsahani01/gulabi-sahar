extends Node3D

const SPAWN := Vector3(25.0, 1.0, 0.0)

var player: CharacterBody3D
var pivot: Node3D
var avatar: Node3D
var world: Node3D
var yaw := -PI/2
var pitch := -0.14
var touch_move := Vector2.ZERO
var jump_requested := false
var portrait := false
var portrait_angle := 0.0
var portrait_height := 0.0
var portrait_camera: Camera3D
var activity: Node3D
var actions: Control
var dash_time := 0.0
var stamina := 100.0
var attack_cooldown := 0.0
var move_input := Vector2.ZERO
var dodge_direction := Vector3.ZERO
var camera_shake := 0.0
var jump_buffer := 0.0
var coyote_time := 0.0
var smooth_yaw := -PI/2
var smooth_pitch := -0.14
var sound: Node
var player_collider: CollisionShape3D
var vehicle: CharacterBody3D
var traffic: Node3D
var hud: Control

func _ready() -> void:
	world = preload("res://city_world.gd").new()
	world.name = "World"
	add_child(world)
	activity = preload("res://city_life.gd").new()
	activity.world_mode = true
	activity.world = world

	player = CharacterBody3D.new()
	player.name = "Player"
	player.collision_mask = 3
	player.position = SPAWN
	player.floor_snap_length = 0.35
	player.floor_max_angle = deg_to_rad(48)
	add_child(player)
	world.player_ref = player
	activity.player = player
	add_child(activity)
	var animals = preload("res://animals.gd").new()
	add_child(animals)
	animals.player = player
	animals.world = world
	var collision := CollisionShape3D.new()
	player_collider=collision
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
	camera.far = 720
	arm.add_child(camera)
	var canvas := CanvasLayer.new()
	add_child(canvas)
	hud = preload("res://city_hud.gd").new()
	hud.game = self
	canvas.add_child(hud)
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.zones = world.ZONES
	portrait_camera = Camera3D.new()
	portrait_camera.fov = 32
	portrait_camera.near = 0.03
	avatar.add_child(portrait_camera)
	portrait_camera.position = Vector3(0, 1.58, -0.85)
	portrait_camera.rotation.y = PI
	vehicle = preload("res://city_vehicle.gd").new()
	vehicle.game = self
	vehicle.paint = Color("f0ece2")
	vehicle.position = Vector3(25,1,4)
	vehicle.heading = -PI/2
	add_child(vehicle)
	traffic = preload("res://city_traffic.gd").new()
	traffic.game = self
	traffic.name = "Traffic"
	add_child(traffic)
	hud.travel_requested.connect(travel_to)
	actions = preload("res://city_actions.gd").new()
	actions.game = self
	canvas.add_child(actions)
	actions.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sound = preload("res://city_audio.gd").new()
	sound.game = self
	add_child(sound)
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

func nearest_drivable() -> CharacterBody3D:
	# Any visible traffic car works too, not just the player's own car.
	var best := vehicle
	var best_dist := vehicle.global_position.distance_to(player.global_position)
	for car in traffic.cars:
		if not car.node.visible:
			continue
		var d: float = car.node.global_position.distance_to(player.global_position)
		if d < best_dist:
			best = car.node
			best_dist = d
	return best

func reset_player() -> void:
	player.position = SPAWN + Vector3(0, 0.6, 0)
	player.velocity = Vector3.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if event.position.x > 400 and event.position.y < 570:
			if portrait:
				orbit_portrait(event.relative)
				return
			yaw -= event.relative.x * 0.004
			pitch = clampf(pitch - event.relative.y * 0.004, -0.7, 0.18)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Q:
			actions.attack()
		elif event.keycode == KEY_T:
			actions.talk()
		elif event.keycode == KEY_X:
			actions.dash()
		elif event.keycode == KEY_F:
			toggle_portrait()
		elif event.keycode == KEY_E:
			actions.kick()
		elif event.keycode == KEY_B:
			actions.handle_action("guard")
		elif event.keycode == KEY_C:
			actions.handle_action("crouch")
		elif event.keycode == KEY_V:
			actions.handle_action("ride")
		elif event.keycode == KEY_SPACE:
			jump_requested = true
		elif event.keycode == KEY_M:
			hud.map_open = not hud.map_open
		elif event.keycode == KEY_R:
			reset_player()

func travel_to(index: int) -> void:
	if index<0 or index>=world.landmarks.size():
		return
	var poi: Dictionary = world.landmarks[index]
	var destination := Vector3(poi.p[0],world.terrain_height(poi.p[0],poi.p[1])+2.0,poi.p[1])
	vehicle.driving=false
	vehicle.speed=0
	avatar.show()
	player.collision_layer=1
	player.collision_mask=3
	player.position=destination
	player.velocity=Vector3.ZERO
	world.update_cells(destination)
	activity.populate_near(destination)
	vehicle.position=destination+Vector3(4,0,0)
	hud.clear_input()
	hud.map_open=false

func _physics_process(delta: float) -> void:
	if hud==null or actions==null:
		return
	attack_cooldown=maxf(0,attack_cooldown-delta)
	dash_time=maxf(0,dash_time-delta)
	camera_shake=maxf(0,camera_shake-delta)
	var move: Vector2=touch_move+hud.movement
	move.x+=float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
	move.y+=float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	move=move.limit_length()
	var locked: bool=portrait or hud.map_open or actions.dialogue_open
	if locked:
		move=Vector2.ZERO
	move_input=move
	var direction := Basis(Vector3.UP,yaw)*Vector3(move.x,0,move.y)
	var running: bool=(Input.is_physical_key_pressed(KEY_SHIFT) or hud.running) and stamina>3 and not avatar.guarding and not avatar.crouching
	var speed := 6.5 if running else 2.4
	if avatar.crouching:
		speed=1.25
	elif avatar.guarding:
		speed=1.5
	if attack_cooldown>0:
		speed*=.35
	if running and move.length()>.1 and not vehicle.driving:
		stamina=maxf(0,stamina-delta*7)
		if stamina<=3:
			hud.running=false
	elif dash_time<=0 and attack_cooldown<=0:
		stamina=minf(100,stamina+delta*14)
	if dash_time>0 and not locked:
		direction=dodge_direction
		speed=8.5
	if not avatar.crouching and player_collider.shape.height<1.7:
		var overhead:=PhysicsRayQueryParameters3D.create(player.position+Vector3.UP,player.position+Vector3(0,1.8,0),1)
		overhead.exclude=[player.get_rid()]
		if not get_world_3d().direct_space_state.intersect_ray(overhead).is_empty():
			avatar.crouching=true
	player_collider.shape.height=1.2 if avatar.crouching else 1.75
	player_collider.position.y=player_collider.shape.height*.5
	var accel := 18.0 if player.is_on_floor() else 6.0
	if direction.length()<.1:
		accel=24.0
	if not vehicle.driving:
		player.velocity.x=move_toward(player.velocity.x,direction.x*speed,delta*accel)
		player.velocity.z=move_toward(player.velocity.z,direction.z*speed,delta*accel)
		coyote_time=.12 if player.is_on_floor() else maxf(0,coyote_time-delta)
		jump_buffer=maxf(0,jump_buffer-delta)
		if jump_requested and not locked:
			jump_buffer=.15
		jump_requested=false
		if jump_buffer>0 and coyote_time>0:
			player.velocity.y=6.7
			jump_buffer=0
			coyote_time=0
			avatar.play_action("Jump")
		elif not player.is_on_floor():
			player.velocity.y-=20*delta
		else:
			player.velocity.y=-.5
		player.move_and_slide()
		if direction.length()>.08 and attack_cooldown<=0 and dash_time<=0:
			avatar.rotation.y=lerp_angle(avatar.rotation.y,atan2(-direction.x,-direction.z),1-exp(-12*delta))
		avatar.movement_speed=Vector2(player.velocity.x,player.velocity.z).length()
		avatar.grounded=player.is_on_floor()
	else:
		player.velocity=Vector3.ZERO
		jump_requested=false
		if move.length()>.1:
			yaw=lerp_angle(yaw,vehicle.heading,delta*2)
	smooth_yaw=lerp_angle(smooth_yaw,yaw,1-exp(-18*delta))
	smooth_pitch=lerpf(smooth_pitch,pitch,1-exp(-18*delta))
	pivot.rotation=Vector3(smooth_pitch,smooth_yaw,0)
	pivot.position.y=lerpf(pivot.position.y,2.1 if vehicle.driving else (1.2 if avatar.crouching else 1.55),delta*5)
	var arm: SpringArm3D=pivot.get_child(0)
	arm.spring_length=lerpf(arm.spring_length,7.3 if vehicle.driving else 4.5,delta*4)
	var camera: Camera3D=arm.get_child(0)
	camera.fov=lerpf(camera.fov,76.0 if running or vehicle.driving else 68.0,delta*4)
	camera.h_offset=sin(Time.get_ticks_msec()*.12)*camera_shake*.18
	hud.map_player=player.position
	hud.map_yaw=yaw
	hud.zone_name=world.district_at(player.position)
	hud.driving=vehicle.driving
	hud.speed=int(absf(vehicle.speed)*3.6)
	if player.position.y < -10:
		travel_to(0)
