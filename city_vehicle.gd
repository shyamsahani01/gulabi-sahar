extends CharacterBody3D
# Box-built but properly proportioned vehicles: a compact hatchback (sloped bonnet,
# raked windscreen, glazed cabin, bumpers, lights, mirrors, hubcaps) and a Jaipur
# auto-rickshaw. Referenced from typical Indian hatchback and Bajaj RE proportions.
var game: Node3D
var driving := false
var speed := 0.0
var heading := 0.0
var kind := "car"
var paint := Color("e9e4d6")
var wheels: Array[Node3D] = []
var body_mesh: Node3D
var max_speed := 24.0

static func material(color: Color, rough := .45, metal := .3, glow := 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = rough
	mat.metallic = metal
	if glow > 0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = glow
	return mat

func part(at: Vector3, dimensions: Vector3, mat: StandardMaterial3D, tilt := 0.0) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = dimensions
	mesh.mesh = box
	mesh.position = at
	mesh.rotation.x = tilt
	mesh.material_override = mat
	body_mesh.add_child(mesh)
	return mesh

func wheel(at: Vector3, radius: float, width: float) -> void:
	var tyre := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = width
	cylinder.radial_segments = 18
	tyre.mesh = cylinder
	tyre.position = at
	tyre.rotation.z = PI / 2
	tyre.material_override = material(Color("1f2224"), .9, 0)
	body_mesh.add_child(tyre)
	var hub := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = radius * .55
	disc.bottom_radius = radius * .55
	disc.height = width + .02
	disc.radial_segments = 12
	hub.mesh = disc
	hub.material_override = material(Color("b9bcc0"), .35, .8)
	tyre.add_child(hub)
	wheels.append(tyre)

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	floor_snap_length = .6
	body_mesh = Node3D.new()
	add_child(body_mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.7, 1.4, 3.9) if kind == "car" else Vector3(1.4, 1.7, 2.7)
	collision.shape = shape
	collision.position.y = shape.size.y * .55
	add_child(collision)
	if kind == "auto":
		build_auto()
		max_speed = 14.0
	else:
		build_car()

func build_car() -> void:
	var body := material(paint, .32, .45)
	var glass := material(Color("2f4552"), .12, .7)
	var trim := material(Color("24282b"), .7, .2)
	var chrome := material(Color("d7d9dc"), .25, .9)
	# Lower body, sills and wheel arches.
	part(Vector3(0, .66, 0), Vector3(1.72, .46, 3.95), body)
	part(Vector3(0, .42, 0), Vector3(1.68, .14, 3.7), trim)
	for z in [-1.25, 1.25]:
		part(Vector3(0, .55, z), Vector3(1.78, .3, .95), body)
	# Bonnet slopes down to the nose; boot is short (hatchback).
	part(Vector3(0, .98, -1.25), Vector3(1.6, .18, 1.25), body, -.16)
	part(Vector3(0, .9, 1.55), Vector3(1.6, .34, .8), body)
	# Cabin: raked windscreen, side glass, rear glass, roof, pillars.
	part(Vector3(0, 1.3, -.72), Vector3(1.5, .72, .06), glass, -.55)
	part(Vector3(0, 1.3, 1.5), Vector3(1.46, .62, .06), glass, .62)
	for side in [-1, 1]:
		part(Vector3(side * .76, 1.28, .35), Vector3(.05, .5, 1.75), glass)
		part(Vector3(side * .77, 1.0, .35), Vector3(.06, .14, 1.9), body)
		part(Vector3(side * .76, 1.3, -.52), Vector3(.07, .62, .09), body, -.5)
		part(Vector3(side * .76, 1.3, 1.25), Vector3(.07, .58, .09), body, .55)
		part(Vector3(side * .76, 1.3, .4), Vector3(.07, .6, .08), body)
		# Mirrors, door handles.
		part(Vector3(side * .95, 1.12, -.55), Vector3(.22, .12, .16), body)
		part(Vector3(side * .87, .88, .1), Vector3(.03, .04, .22), chrome)
		part(Vector3(side * .87, .88, 1.0), Vector3(.03, .04, .22), chrome)
	part(Vector3(0, 1.64, .4), Vector3(1.48, .07, 1.7), body)
	# Front: grille, headlamps, bumper, plate. Rear: tail lamps, bumper.
	part(Vector3(0, .62, -1.98), Vector3(1.74, .34, .12), trim)
	part(Vector3(0, .62, 1.98), Vector3(1.74, .34, .12), trim)
	part(Vector3(0, .85, -1.96), Vector3(.9, .2, .05), trim)
	part(Vector3(0, .45, -2.02), Vector3(.5, .14, .02), material(Color("f2f2f0"), .6, 0))
	for side in [-1, 1]:
		part(Vector3(side * .62, .88, -1.95), Vector3(.36, .16, .06), material(Color("fff6dc"), .3, .2, 1.2))
		part(Vector3(side * .64, .9, 1.96), Vector3(.3, .18, .06), material(Color("d6322a"), .3, .2, .9))
		part(Vector3(side * .6, .5, -1.97), Vector3(.22, .08, .05), material(Color("f2b94a"), .3, .2, .6))
	for side in [-1, 1]:
		for z in [-1.25, 1.25]:
			wheel(Vector3(side * .8, .34, z), .34, .22)

func build_auto() -> void:
	var body := material(Color("d9c22e"), .5, .2)
	var green := material(Color("2f6b3a"), .55, .2)
	var glass := material(Color("2f4552"), .12, .7)
	var canvas := material(Color("1e1f1f"), .95, 0)
	var chrome := material(Color("d7d9dc"), .25, .9)
	part(Vector3(0, .5, .2), Vector3(1.34, .3, 2.3), body)
	part(Vector3(0, .9, 1.0), Vector3(1.36, .5, .7), green)
	part(Vector3(0, .95, -.95), Vector3(1.1, .6, .5), body, -.35)
	part(Vector3(0, 1.0, 1.3), Vector3(1.3, .45, .1), green)
	part(Vector3(0, .95, .45), Vector3(1.2, .45, .9), canvas)
	part(Vector3(0, 1.55, -.85), Vector3(1.1, .75, .05), glass, -.18)
	for side in [-1, 1]:
		part(Vector3(side * .62, 1.3, -.55), Vector3(.05, 1.3, .06), body)
		part(Vector3(side * .64, 1.35, 1.2), Vector3(.05, 1.4, .06), body)
		part(Vector3(side * .78, 1.25, -.8), Vector3(.14, .1, .12), chrome)
	part(Vector3(0, 2.0, .2), Vector3(1.4, .07, 2.4), canvas)
	part(Vector3(0, 1.9, .5), Vector3(1.32, .1, 1.5), canvas)
	part(Vector3(0, .9, -1.22), Vector3(.3, .22, .08), material(Color("fff6dc"), .3, .2, 1.2))
	part(Vector3(0, .42, -1.2), Vector3(.5, .08, .04), chrome)
	wheel(Vector3(0, .3, -1.05), .3, .16)
	for side in [-1, 1]:
		wheel(Vector3(side * .62, .3, .85), .3, .16)

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
		game.actions.notify("Get closer to your car · marked on the map")

func _physics_process(delta: float) -> void:
	var move: Vector2 = game.move_input if driving else Vector2.ZERO
	var target_speed := -move.y*max_speed
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
	for w in wheels:
		w.rotate_y(speed*delta*2.5)
	if driving:
		game.player.global_position = global_position+Vector3(0,.3,0)
