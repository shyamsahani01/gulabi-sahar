extends CharacterBody3D
var game: Node3D
var driving := false
var speed := 0.0
var heading := 0.0
var wheels: Array[Node3D] = []
var body_mesh: Node3D

var paint := Color("e8d9bc")
var style := "sedan"
var design: Node3D

func _ready() -> void:
	collision_layer = 4
	collision_mask = 5
	floor_snap_length = .6
	design = preload("res://vehicle_design.gd").new()
	design.paint = paint
	design.style = style
	body_mesh = design
	add_child(design)
	wheels = design.wheels
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.96 if style=="suv" else 1.86,1.85 if style=="suv" else 1.7,4.42)
	collision.shape = shape
	collision.position.y = .90 if style=="suv" else .79
	add_child(collision)

func toggle_drive() -> void:
	if driving:
		var side := global_basis.x*2.1
		var candidate := global_position+side+Vector3.UP
		var query := PhysicsRayQueryParameters3D.create(global_position+Vector3.UP,candidate,1)
		if not get_world_3d().direct_space_state.intersect_ray(query).is_empty():
			game.actions.notify("Exit blocked · move away from the wall")
			return
		release_driver()
		game.player.position = candidate
		game.actions.notify("On foot")
	elif global_position.distance_to(game.player.global_position)<5:
		heading=rotation.y
		driving = true
		game.avatar.show()
		game.avatar.crouching=false
		game.avatar.guarding=false
		game.avatar.movement_speed=0
		game.avatar.play_action("Drive",3600,.15)
		game.player.velocity=Vector3.ZERO
		update_driver()
		game.pivot.get_child(0).add_excluded_object(get_rid())
		game.player.collision_layer = 0
		game.player.collision_mask = 0
		game.yaw = rotation.y
		game.actions.notify("Driving · joystick steers / accelerates · BRAKE to stop")
	else:
		game.actions.notify("Get closer to the cream car · marked on the map")

func _physics_process(delta: float) -> void:
	var move: Vector2 = game.move_input if driving else Vector2.ZERO
	var target_speed := -move.y*24.0
	if target_speed<0:
		target_speed *= .32
	if driving and game.hud.running:
		target_speed = 0
	speed = move_toward(speed,target_speed,delta*(15 if target_speed==0 else 7))
	if driving and absf(speed)>.2:
		heading -= move.x*signf(speed)*delta*1.25*clampf(absf(speed)/6,.15,1)
	rotation.y = heading
	var forward := -global_basis.z
	velocity.x = forward.x*speed
	velocity.z = forward.z*speed
	velocity.y = -1 if is_on_floor() else velocity.y-22*delta
	move_and_slide()
	if get_slide_collision_count()>0:
		for i in get_slide_collision_count():
			if absf(get_slide_collision(i).get_normal().y)<.4:
				speed *= .7
	design.animate_wheels(speed*delta, move.x if driving else 0.0)
	if driving:
		game.player.global_position = global_position
		update_driver()

func update_driver() -> void:
	# The same hero occupies the right-hand front seat, in car-local coordinates.
	game.avatar.global_transform=global_transform*Transform3D(Basis.IDENTITY,Vector3(.39,.08,.02))
	game.avatar.movement_speed=0
	game.avatar.grounded=false

func release_driver() -> void:
	driving=false
	game.avatar.show()
	game.avatar.transform=Transform3D.IDENTITY
	game.avatar.stop_action(.15)
	game.player.collision_layer=1
	game.player.collision_mask=7
	game.pivot.get_child(0).remove_excluded_object(get_rid())
