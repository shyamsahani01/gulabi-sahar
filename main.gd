extends Node3D

const SPAWN := Vector3(22.0, 1.0, 0.0)

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
var portrait_distance := 0.85
const PORTRAIT_DISTANCE_MIN := 0.2
const PORTRAIT_DISTANCE_MAX := 1.25
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
# Body motion state: jump phases, landings, seats, idle fidgets, lean and head tracking.
var seated: Dictionary = {}
var sit_restore := Vector3.ZERO
var air_time := 0.0
var was_grounded := true
var fall_speed := 0.0
var jump_delay := -1.0
var landing_lock := 0.0
var land_dip := 0.0
var idle_clock := 0.0
var next_idle := 8.0
var lean := Vector2.ZERO
var previous_velocity := Vector3.ZERO
var look_point: Node3D
var last_landing := 0.0

func _ready() -> void:
	world = preload("res://city_world.gd").new()
	world.name = "World"
	add_child(world)
	activity = preload("res://city_life.gd").new()
	activity.world_mode = true
	activity.world = world

	player = CharacterBody3D.new()
	player.name = "Player"
	player.collision_mask = 7
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
	look_point = Node3D.new()
	look_point.name = "LookPoint"
	add_child(look_point)
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
	vehicle.position = Vector3(22,1,4)
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
	hud.face_zoom.connect(zoom_portrait)
	hud.expression_changed.connect(func():
		avatar.cycle_expression()
		hud.expression_label = avatar.expression)
	hud.outfit_changed.connect(func():
		avatar.apply_outfit(avatar.outfit + 1)
		hud.outfit_label = avatar.outfit_name()
		actions.save_progress())
	hud.outfit_label = avatar.outfit_name()
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
		portrait_distance = 0.85
		hud.face_zoom_level = 1.0
		orbit_portrait(Vector2.ZERO)
		portrait_camera.make_current()
	else:
		pivot.get_child(0).get_child(0).make_current()

func orbit_portrait(delta: Vector2) -> void:
	# Drag orbits the head; the vertical drag also moves the point the camera studies
	# (brows at the top, chin and neck at the bottom), scaled down as the zoom gets closer.
	var closeness := portrait_distance / 0.85
	portrait_angle = clampf(portrait_angle - delta.x * 0.006 * closeness, -1.15, 1.15)
	portrait_height = clampf(portrait_height + delta.y * 0.0008 * closeness, -0.11, 0.11)
	var focus := Vector3(0, 1.58 + portrait_height * 0.85, 0)
	portrait_camera.position = focus + Vector3(sin(portrait_angle) * portrait_distance, portrait_height * 0.45, -cos(portrait_angle) * portrait_distance)
	portrait_camera.look_at(avatar.to_global(focus))

func zoom_portrait(factor: float) -> void:
	# Pinch, wheel or the +/- buttons: factor > 1 moves the camera closer to the face.
	if not portrait or factor <= 0:
		return
	portrait_distance = clampf(portrait_distance / factor, PORTRAIT_DISTANCE_MIN, PORTRAIT_DISTANCE_MAX)
	hud.face_zoom_level = 0.85 / portrait_distance
	orbit_portrait(Vector2.ZERO)

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
	if not seated.is_empty():
		stand_up()
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
	if portrait and event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_portrait(1.15)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_portrait(1 / 1.15)
	if event is InputEventKey and event.pressed and not event.echo:
		if portrait and event.keycode in [KEY_EQUAL, KEY_PLUS, KEY_KP_ADD]:
			zoom_portrait(1.25)
		elif portrait and event.keycode in [KEY_MINUS, KEY_KP_SUBTRACT]:
			zoom_portrait(1 / 1.25)
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
		elif event.keycode == KEY_G:
			actions.handle_action("sit")
		elif event.keycode == KEY_O:
			avatar.apply_outfit(avatar.outfit + 1)
			hud.outfit_label = avatar.outfit_name()
			actions.save_progress()
		elif event.keycode == KEY_SPACE:
			jump_requested = true
		elif event.keycode == KEY_M:
			hud.map_open = not hud.map_open
		elif event.keycode == KEY_R:
			reset_player()

func travel_to(index: int) -> void:
	if index<0 or index>=world.destinations().size():
		return
	if not seated.is_empty():
		stand_up()
	var poi: Dictionary = world.destinations()[index]
	var destination := Vector3(poi.p[0],world.terrain_height(poi.p[0],poi.p[1])+2.0,poi.p[1])
	vehicle.driving=false
	vehicle.speed=0
	avatar.show()
	player.collision_layer=1
	player.collision_mask=7
	player.position=destination
	player.velocity=Vector3.ZERO
	world.update_cells(destination)
	activity.populate_near(destination)
	if poi.has("car_p"):
		vehicle.position=Vector3(poi.car_p[0],world.terrain_height(poi.car_p[0],poi.car_p[1])+1,poi.car_p[1])
		vehicle.heading=poi.car_heading
		yaw=poi.rotation
		smooth_yaw=yaw
	else:
		vehicle.position=destination+Vector3(4,0,0)
	vehicle.velocity=Vector3.ZERO
	hud.clear_input()
	hud.map_open=false

func sit_toggle() -> void:
	if not seated.is_empty():
		stand_up()
		return
	if vehicle.driving or portrait or hud.map_open or actions.dialogue_open or not player.is_on_floor():
		return
	var best: Dictionary = {}
	var best_distance := 2.3
	for seat in world.seats:
		var distance: float = seat.p.distance_to(player.position)
		if distance < best_distance:
			best_distance = distance
			best = seat
	if best.is_empty():
		actions.notify("Walk up to a chair, sofa or bench, then tap SIT")
		return
	sit_restore = player.position
	seated = best
	player.collision_layer = 0
	player.collision_mask = 0
	player.velocity = Vector3.ZERO
	player.position = best.p
	avatar.crouching = false
	avatar.guarding = false
	avatar.rotation.y = best.yaw
	avatar.play_action(best.pose, 3600.0, .4)
	avatar.set_expression("Smile", 3)
	sound.play_effect("sit")
	hud.clear_input()
	actions.notify("Sitting down · push the stick or tap STAND to get up")

func stand_up() -> void:
	if seated.is_empty():
		return
	seated = {}
	player.collision_layer = 1
	player.collision_mask = 7
	player.position = sit_restore + Vector3(0, .05, 0)
	player.velocity = Vector3.ZERO
	avatar.stop_action(.35)
	jump_requested = false
	hud.clear_input()

func land(fall: float) -> void:
	var hard := fall > 11.5
	avatar.play_action("HardLand" if hard else "JumpLand", -1.0, .06)
	land_dip = .22 if hard else .09
	camera_shake = .16 if hard else .05
	landing_lock = .6 if hard else .18
	sound.play_effect("land")
	last_landing = fall
	if hard:
		actions.health = maxf(1, actions.health - (fall - 11.5) * 4)
		actions.notify("Hard landing")

func _physics_process(delta: float) -> void:
	if hud==null or actions==null:
		return
	attack_cooldown=maxf(0,attack_cooldown-delta)
	dash_time=maxf(0,dash_time-delta)
	camera_shake=maxf(0,camera_shake-delta)
	landing_lock=maxf(0,landing_lock-delta)
	land_dip=maxf(0,land_dip-delta*.5)
	var move: Vector2=touch_move+hud.movement
	move.x+=float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
	move.y+=float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	move=move.limit_length()
	if not seated.is_empty() and (move.length()>.4 or jump_requested):
		stand_up()
	var talking: bool=actions.dialogue_open and not actions.target.is_empty() and actions.target.has("body") and is_instance_valid(actions.target.body)
	var locked: bool=portrait or hud.map_open or actions.dialogue_open or not seated.is_empty()
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
	if landing_lock>0:
		speed*=.3
	if running and move.length()>.1 and not vehicle.driving:
		stamina=maxf(0,stamina-delta*7)
		if stamina<=3:
			hud.running=false
	elif dash_time<=0 and attack_cooldown<=0:
		stamina=minf(100,stamina+delta*(22 if not seated.is_empty() else 14))
	if dash_time>0 and not locked:
		direction=dodge_direction
		speed=8.5
	if seated.is_empty() and not avatar.crouching and player_collider.shape.height<1.7:
		var overhead:=PhysicsRayQueryParameters3D.create(player.position+Vector3.UP,player.position+Vector3(0,1.8,0),1)
		overhead.exclude=[player.get_rid()]
		if not get_world_3d().direct_space_state.intersect_ray(overhead).is_empty():
			avatar.crouching=true
	player_collider.shape.height=1.2 if avatar.crouching else 1.75
	player_collider.position.y=player_collider.shape.height*.5
	var accel := 18.0 if player.is_on_floor() else 6.0
	if direction.length()<.1:
		accel=24.0
	if not seated.is_empty():
		# Pinned to the seat: the body relaxes, health and stamina recover faster.
		player.velocity=Vector3.ZERO
		player.position=seated.p
		if not talking:
			avatar.rotation.y=lerp_angle(avatar.rotation.y,seated.yaw,1-exp(-10*delta))
		avatar.movement_speed=0
		avatar.grounded=true
		jump_requested=false
		actions.health=minf(100,actions.health+delta*3)
		if avatar.action!=seated.pose:
			avatar.play_action(seated.pose,3600.0,.3)
	elif not vehicle.driving:
		player.velocity.x=move_toward(player.velocity.x,direction.x*speed,delta*accel)
		player.velocity.z=move_toward(player.velocity.z,direction.z*speed,delta*accel)
		coyote_time=.12 if player.is_on_floor() else maxf(0,coyote_time-delta)
		jump_buffer=maxf(0,jump_buffer-delta)
		if jump_requested and not locked:
			jump_buffer=.15
		jump_requested=false
		var launch := false
		if jump_buffer>0 and coyote_time>0 and jump_delay<0 and landing_lock<=0 and dash_time<=0:
			# Short anticipation dip before the feet leave the ground.
			jump_delay=.06
			jump_buffer=0
			coyote_time=0
			avatar.crouching=false
			avatar.guarding=false
			avatar.play_action("Jump",-1.0,.05)
		if jump_delay>=0:
			jump_delay-=delta
			if jump_delay<0:
				launch=true
		if launch:
			player.velocity.y=6.7
			if running and move.length()>.3:
				player.velocity.x+=direction.x*1.1
				player.velocity.z+=direction.z*1.1
		elif not player.is_on_floor():
			player.velocity.y-=20*delta
		else:
			player.velocity.y=-.5
		player.move_and_slide()
		var grounded: bool=player.is_on_floor()
		if grounded:
			if not was_grounded and air_time>.18 and dash_time<=0:
				land(fall_speed)
			air_time=0
			fall_speed=0
		else:
			air_time+=delta
			fall_speed=maxf(fall_speed,-player.velocity.y)
			if air_time>.2 and avatar.action_left<=0 and dash_time<=0:
				avatar.play_action("JumpAir",3600.0,.14)
		was_grounded=grounded
		if direction.length()>.08 and attack_cooldown<=0 and dash_time<=0 and not talking:
			avatar.rotation.y=lerp_angle(avatar.rotation.y,atan2(-direction.x,-direction.z),1-exp(-12*delta))
		avatar.movement_speed=Vector2(player.velocity.x,player.velocity.z).length()
		avatar.grounded=grounded
		# Idle fidget: after a quiet spell the hero glances around.
		if grounded and move.length()<.05 and avatar.action=="" and not locked and not avatar.guarding and not avatar.crouching:
			idle_clock+=delta
			if idle_clock>next_idle:
				idle_clock=0
				next_idle=randf_range(7,13)
				avatar.play_action("LookAround",-1.0,.3)
		else:
			idle_clock=0
	else:
		player.velocity=Vector3.ZERO
		jump_requested=false
		if move.length()>.1:
			yaw=lerp_angle(yaw,vehicle.heading,delta*2)
	# Lean into acceleration and turns while on foot.
	var target_lean := Vector2.ZERO
	if seated.is_empty() and not vehicle.driving and player.is_on_floor():
		var change: Vector3=(player.velocity-previous_velocity)/maxf(delta,.001)
		var local: Vector3=avatar.global_basis.inverse()*change
		target_lean=Vector2(clampf(-local.z*.006,-.03,.10),clampf(-local.x*.008,-.12,.12))
		if running and move.length()>.3:
			target_lean.x+=.05
	lean=lean.lerp(target_lean,1-exp(-7*delta))
	avatar.rotation.x=lean.x
	avatar.rotation.z=lean.y
	previous_velocity=player.velocity
	update_head_look(talking)
	# Conversation framing: over the shoulder, facing the resident.
	var spring_target := 4.5
	var fov_target := 68.0
	var pivot_target := 1.55
	if talking:
		var npc: Node3D=actions.target.body
		var away: Vector3=player.global_position-npc.global_position
		away.y=0
		if away.length()>.05:
			yaw=lerp_angle(yaw,atan2(away.x,away.z)+1.05,1-exp(-5*delta))
			avatar.rotation.y=lerp_angle(avatar.rotation.y,atan2(away.x,away.z),1-exp(-8*delta))
		pitch=lerpf(pitch,-.16,1-exp(-5*delta))
		spring_target=3.1
		fov_target=50.0
		pivot_target=1.75
	elif vehicle.driving:
		spring_target=7.3
		fov_target=76.0
		pivot_target=2.1
	elif not seated.is_empty():
		spring_target=3.6
		pivot_target=1.15
	elif avatar.crouching:
		pivot_target=1.2
	elif running:
		fov_target=76.0
	smooth_yaw=lerp_angle(smooth_yaw,yaw,1-exp(-18*delta))
	smooth_pitch=lerpf(smooth_pitch,pitch,1-exp(-18*delta))
	pivot.rotation=Vector3(smooth_pitch,smooth_yaw,0)
	pivot.position.y=lerpf(pivot.position.y,pivot_target-land_dip*1.2,delta*(9 if land_dip>0 else 5))
	var arm: SpringArm3D=pivot.get_child(0)
	arm.spring_length=lerpf(arm.spring_length,spring_target,delta*4)
	var camera: Camera3D=arm.get_child(0)
	camera.fov=lerpf(camera.fov,fov_target,delta*4)
	camera.h_offset=sin(Time.get_ticks_msec()*.12)*camera_shake*.18
	hud.map_player=player.position
	hud.map_yaw=yaw
	hud.zone_name=world.district_at(player.position)
	hud.driving=vehicle.driving
	hud.speed=int(absf(vehicle.speed)*3.6)
	if player.position.y < -10:
		travel_to(0)

func update_head_look(talking: bool) -> void:
	# The hero's head follows the resident being spoken to, or the closest person in front.
	var target: Dictionary={}
	if talking:
		target=actions.target
	elif not vehicle.driving and not portrait:
		var best := 5.0
		var forward: Vector3=-avatar.global_basis.z
		for person in activity.everyone():
			if not is_instance_valid(person.body) or person.get("defeated",false):
				continue
			var offset: Vector3=person.body.global_position-player.global_position
			var distance := offset.length()
			if distance<best and distance>.3 and offset.normalized().dot(forward)>.15:
				best=distance
				target=person
	if not target.is_empty():
		var scale_factor: float=.62 if target.get("kind","adult")=="child" else 1.0
		var height: float=1.52*scale_factor
		if target.get("seated",false):
			height=1.15 if target.get("pose","Sit")=="Sit" else 1.38
		look_point.global_position=target.body.global_position+Vector3(0,height,0)
		avatar.look_target=look_point
	else:
		avatar.look_target=null
