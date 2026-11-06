extends Node3D

var player: CharacterBody3D
var people: Array[Dictionary] = []
var clock := 0.0
var lane_study := false
var world_mode := false
var world: Node3D

func _ready() -> void:
	name = "MarketLife"
	if world_mode:
		spawn_world()
		return
	for index in range(6):
		var side := 1 if index % 2 else -1
		var near_lane := 0.75 if lane_study else 4.0
		var far_lane := 1.65 if lane_study else 4.9
		spawn(Vector3(side * (near_lane if index % 3 == 0 else far_lane), 0.5, -22 + index * 8), index + 1, true, 1 if index % 3 else -1)
	for pos in [Vector3(-6.8, 0.4, 5.8), Vector3(6.8, 0.4, -14.2), Vector3(-6.1, 0.4, -4.0), Vector3(-6.0, 0.4, -5.3)]:
		var vendor_pos: Vector3 = pos
		if lane_study:
			vendor_pos.x = signf(pos.x) * 2.4
		spawn(vendor_pos, people.size() + 1, false, 1)

func footpath_route(x_inner: float, x_outer: float, z_a: float, z_b: float) -> Array:
	return [Vector3(x_inner, 0, z_a), Vector3(x_outer, 0, z_a), Vector3(x_outer, 0, z_b), Vector3(x_inner, 0, z_b)]

func spawn_world() -> void:
	# Hawa Mahal Road: walkers on both footpaths, a tourist queue along the facade railing.
	for i in range(8):
		var side := 1 if i % 2 else -1
		var z := 34.0 - i * 9.0
		spawn(Vector3(side * (10.7 if i % 3 == 0 else 12.0), 0.5, z), i + 1, true, 1 if i % 3 else -1, "adult", footpath_route(side * 10.7, side * 12.3, -36.0, 36.0))
	for i in range(5):
		spawn(Vector3(-10.9, 0.4, -34.0 + i * 2.6), i + 9, false, 1, "child" if i == 2 else "adult", [], -PI / 2)
	spawn(Vector3(-11.3, 0.4, -18.0), 3, false, 1, "adult", [], PI / 2)
	spawn(Vector3(-11.3, 0.4, -9.0), 4, false, 1, "elder", [], PI / 2)
	spawn(Vector3(-9.4, 0.4, 33.0), 5, false, 1, "adult", [], 0.0)
	spawn(Vector3(-9.4, 0.4, 34.2), 6, false, 1, "child", [], 0.0)
	# Old gali: positions in the lane's own frame, converted through its transform.
	if world != null and world.get("gali") != null:
		var gali: Node3D = world.gali
		for i in range(3):
			var side := 1 if i % 2 else -1
			var local := [Vector3(side * 0.75, 0, -23.0), Vector3(side * 1.65, 0, -23.0), Vector3(side * 1.65, 0, 23.0), Vector3(side * 0.75, 0, 23.0)]
			var route: Array = []
			for p in local:
				var g: Vector3 = gali.to_global(p)
				route.append(Vector3(g.x, 0, g.z))
			var start: Vector3 = gali.to_global(Vector3(side * 1.2, 0.5, -18.0 + i * 12.0))
			spawn(start, i + 2, true, 1 if i % 2 else -1, "child" if i == 1 else "adult", route)
		for local in [Vector3(-2.4, 0.4, 5.8), Vector3(2.4, 0.4, -14.2), Vector3(-2.4, 0.4, -4.0)]:
			var g: Vector3 = gali.to_global(local)
			spawn(Vector3(g.x, 0.4, g.z), people.size() + 1, false, 1, "elder" if local.z < 0 else "adult", [], gali.rotation.y + (PI / 2 if local.x < 0 else -PI / 2))
	# Chandpole Bazar and Sikar Road.
	for i in range(5):
		var side := 1 if i % 2 else -1
		spawn(Vector3(side * 11.5, 0.5, -48.0 - i * 10.0), i + 3, true, 1 if i % 2 else -1, "adult", footpath_route(side * 10.7, side * 12.3, -98.0, -44.0))
	spawn(Vector3(11.3, 0.4, -75.0), 7, false, 1, "adult", [], -PI / 2)
	for i in range(4):
		var side := 1 if i % 2 else -1
		spawn(Vector3(side * 12.5, 0.5, -160.0 - i * 30.0), i + 1, true, 1 if i % 2 else -1, "elder" if i == 3 else "adult", footpath_route(side * 11.6, side * 13.2, -292.0, -146.0))
	spawn(Vector3(-12.6, 0.4, -181.5), 8, false, 1, "adult", [], PI / 2)
	# Vidhyadhar Nagar: residents, children in the park, elders by the benches.
	for i in range(3):
		var side := 1 if i % 2 else -1
		spawn(Vector3(side * 10.2, 0.5, -320.0 - i * 40.0), i + 2, true, 1 if i % 2 else -1, "adult", footpath_route(side * 9.6, side * 10.9, -470.0, -310.0))
	for i in range(5):
		var loop := [Vector3(17.0, 0, -384.0), Vector3(35.0, 0, -384.0), Vector3(35.0, 0, -436.0), Vector3(17.0, 0, -436.0)]
		var start: Vector3 = loop[i % 4]
		spawn(Vector3(start.x, 0.6, start.z + (i * 1.3)), i + 1, true, 1 if i % 2 else -1, "child", loop)
	spawn(Vector3(34.5, 0.6, -431.0), 2, false, 1, "child", [], PI)
	spawn(Vector3(17.2, 0.6, -418.0), 6, false, 1, "elder", [], PI / 2)
	spawn(Vector3(17.2, 0.6, -405.0), 1, false, 1, "elder", [], PI / 2)
	spawn(Vector3(-14.0, 0.6, -449.0), 4, false, 1, "adult", [], -PI / 2)
	# Residents of the new eastward artisan branch.
	for i in range(4):
		spawn(Vector3(32 + i * 16, 0.5, -242), i + 1, false, 1, "adult", [], 0.0)
	# Hills: two walkers climbing the steps to the chhatri.
	for i in range(2):
		var hx := -0.8 + i * 1.6
		var hz := -520.0 - i * 20.0
		var ground: float = world.terrain_height(hx, hz) if world != null else 0.0
		spawn(Vector3(hx, ground + 1.0, hz), i + 5, true, -1, "adult" if i == 0 else "child", [Vector3(hx, 0, -514.0), Vector3(hx, 0, -598.0)])

func spawn(at: Vector3, variant: int, walking: bool, direction: int, kind := "adult", route: Array = [], facing := NAN) -> void:
	var body := CharacterBody3D.new()
	body.name = "Pedestrian_%02d" % people.size()
	body.position = at
	body.collision_layer = 2
	body.collision_mask = 3
	body.floor_snap_length = 0.4
	body.floor_max_angle = deg_to_rad(50)
	add_child(body)
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	var scale_factor := 0.62 if kind == "child" else (0.95 if kind == "elder" else 1.0)
	shape.height = 1.68 * scale_factor
	shape.radius = 0.27 * scale_factor
	collision.shape = shape
	collision.position.y = 0.84 * scale_factor
	body.add_child(collision)
	var human := preload("res://human.gd").new()
	human.variant = variant
	human.crowd = true
	human.kind = kind
	human.talking = not walking
	body.add_child(human)
	human.rotation.y = 0 if direction < 0 else PI
	if not walking:
		if is_nan(facing):
			human.rotation.y = PI / 2 if at.x < 0 else -PI / 2
			if at.z < -3 and at.z > -6:
				human.rotation.y = 0 if at.z > -5 else PI
		else:
			human.rotation.y = facing
	if route.is_empty():
		var side := signf(at.x)
		var inner := 0.75 if lane_study else 4.0
		var outer := 1.65 if lane_study else 4.9
		var end := 23.0 if lane_study else 26.0
		route = [Vector3(side * inner, 0, -end), Vector3(side * outer, 0, -end), Vector3(side * outer, 0, end), Vector3(side * inner, 0, end)]
	var greeting := Label3D.new()
	greeting.font = preload("res://assets/fonts/NotoSansDevanagari-Regular.ttf")
	greeting.text = "चाय पियोगे सा?" if variant == 8 else ("हेलो भैया!" if kind == "child" else ("खम्मा घणी सा!" if kind == "elder" else "राम राम सा!"))
	greeting.font_size = 44
	greeting.pixel_size = 0.005
	greeting.position.y = 2.05 * scale_factor
	greeting.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	greeting.modulate = Color("f7e6c6")
	greeting.outline_modulate = Color("263638")
	greeting.outline_size = 8
	greeting.visible = false
	body.add_child(greeting)
	var base_speed := 0.85 + (variant % 3) * 0.14
	if kind == "child":
		base_speed = 1.05 + (variant % 3) * 0.15
	elif kind == "elder":
		base_speed = 0.55 + (variant % 3) * 0.08
	people.append({"greeting":greeting,"greet_time":0.0,"cooldown":0.0,"route":route,"goal":0 if direction < 0 else 2,"body":body,"human":human,"walking":walking,"direction":direction,"lane":at.x,"wait":variant * 0.23,"speed":base_speed,"kind":kind,"active":true})

func _physics_process(delta: float) -> void:
	clock += delta
	for person in people:
		var body: CharacterBody3D = person.body
		var human: Node3D = person.human
		# Far-away people freeze their animation and physics to keep the tablet fast.
		if world_mode and player != null:
			var near := body.position.distance_to(player.position) < 75.0
			if near != person.active:
				person.active = near
				if human.animator != null:
					human.animator.active = near
			if not near:
				continue
		if person.get("defeated", false):
			person.respawn = maxf(0, person.respawn - delta)
			if person.respawn <= 0:
				person.defeated = false
				person.health = 100
				human.rotation.z = 0
				body.collision_layer = 2
			continue
		if person.get("stun", 0.0) > 0:
			person.stun -= delta
			human.movement_speed = 0
			if person.get("face_player", false) and player != null and not person.get("seated", false):
				var toward: Vector3 = player.position - body.position
				human.rotation.y = lerp_angle(human.rotation.y, atan2(-toward.x, -toward.z), delta * 6)
			continue
		if person.get("seated", false):
			continue
		var speed := 0.0
		person.greet_time = maxf(0, person.greet_time - delta)
		person.cooldown = maxf(0, person.cooldown - delta)
		if not person.walking and player != null and player.position.distance_to(body.position) < 2.5:
			if person.cooldown <= 0:
				person.greet_time = 2.5
				person.cooldown = 12.0
			var facing: Vector3 = player.position - body.position
			human.rotation.y = lerp_angle(human.rotation.y, atan2(-facing.x, -facing.z), delta * 3)
		person.greeting.visible = person.greet_time > 0
		if person.walking:
			person.wait = maxf(0, person.wait - delta)
			var target: Vector3 = person.route[person.goal]
			var offset := Vector3(target.x - body.position.x, 0, target.z - body.position.z)
			if offset.length() < 0.25:
				person.goal = (person.goal + 1) % person.route.size()
				person.wait = 0.3 if person.goal % 2 else 1.0
			var direction := offset.normalized()
			var blocked := player != null and body.position.distance_to(player.position) < 1.1
			for other in people:
				if other.body == body or not other.active:
					continue
				var relative: Vector3 = other.body.position - body.position
				relative.y = 0
				if relative.length() < 0.8 and relative.dot(direction) > 0.25 and absf(relative.cross(direction).y) < 0.5:
					blocked = true
			if person.wait <= 0 and not blocked:
				speed = person.speed
			body.velocity.x = direction.x * speed
			body.velocity.z = direction.z * speed
			if speed > 0:
				human.rotation.y = lerp_angle(human.rotation.y, atan2(-direction.x, -direction.z), delta * 4)
		body.velocity.y = -1 if body.is_on_floor() else body.velocity.y - 22 * delta
		body.move_and_slide()
		human.movement_speed = speed
		human.grounded = body.is_on_floor()
