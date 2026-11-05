extends CharacterBody3D
var game: Node3D
var driving := false
var speed := 0.0
var heading := 0.0
var wheels: Array[Node3D] = []
var body_mesh: Node3D

func part(at: Vector3,dimensions: Vector3,color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = dimensions
	mesh.mesh = box
	mesh.position = at
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = .38
	mat.metallic = .35
	mesh.material_override = mat
	body_mesh.add_child(mesh)
	return mesh

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	floor_snap_length = .6
	body_mesh = Node3D.new()
	add_child(body_mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.75,1.35,3.8)
	collision.shape = shape
	collision.position.y = .85
	add_child(collision)
	part(Vector3(0,.7,0),Vector3(1.75,.5,3.8),Color("e1cbb2"))
	part(Vector3(0,1.17,.2),Vector3(1.5,.65,1.9),Color("3c535e"))
	part(Vector3(0,1.55,.2),Vector3(1.65,.12,2.0),Color("e1cbb2"))
	for side in [-1,1]:
		part(Vector3(side*.82,1.15,.2),Vector3(.09,.7,.12),Color("e1cbb2"))
		part(Vector3(side*.9,.77,-1.2),Vector3(.12,.2,.3),Color("c6ad8a"))
		for z in [-1.25,1.25]:
			var wheel := MeshInstance3D.new()
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = .35
			cylinder.bottom_radius = .35
			cylinder.height = .22
			cylinder.radial_segments = 16
			wheel.mesh = cylinder
			wheel.position = Vector3(side*.88,.37,z)
			wheel.rotation.z = PI/2
			var rubber := StandardMaterial3D.new()
			rubber.albedo_color = Color("22272a")
			wheel.material_override = rubber
			body_mesh.add_child(wheel)
			wheels.append(wheel)
		part(Vector3(side*.58,.83,-1.92),Vector3(.42,.2,.05),Color("fff1c6"))
		part(Vector3(side*.58,.83,1.92),Vector3(.42,.2,.05),Color("a83e32"))
	part(Vector3(0,.55,-1.94),Vector3(1.5,.1,.08),Color("3e4447"))

func toggle_drive() -> void:
	if driving:
		var side := global_basis.x*2.1
		var candidate := global_position+side+Vector3.UP
		var query := PhysicsRayQueryParameters3D.create(global_position+Vector3.UP,candidate,1)
		if not get_world_3d().direct_space_state.intersect_ray(query).is_empty():
			game.actions.notify("Exit blocked · move away from the wall")
			return
		driving = false
		game.player.position = candidate
		game.avatar.show()
		game.player.collision_layer = 1
		game.player.collision_mask = 3
		game.actions.notify("On foot")
	elif global_position.distance_to(game.player.global_position)<5:
		driving = true
		game.avatar.hide()
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
	for wheel in wheels:
		wheel.rotate_y(speed*delta*2.5)
	if driving:
		game.player.global_position = global_position+Vector3(0,.3,0)
