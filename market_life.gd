extends Node3D

var player: CharacterBody3D
var people: Array[Dictionary] = []
var clock := 0.0
var lane_study := false

func _ready() -> void:
	name = "MarketLife"
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

func spawn(at: Vector3, variant: int, walking: bool, direction: int) -> void:
	var body := CharacterBody3D.new()
	body.name = "Pedestrian_%02d" % variant
	body.position = at
	body.collision_layer = 2
	body.collision_mask = 3
	body.floor_snap_length = 0.4
	add_child(body)
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.height = 1.68
	shape.radius = 0.27
	collision.shape = shape
	collision.position.y = 0.84
	body.add_child(collision)
	var human := preload("res://human.gd").new()
	human.variant = variant
	human.crowd = true
	human.talking = not walking
	body.add_child(human)
	human.rotation.y = 0 if direction < 0 else PI
	if not walking:
		human.rotation.y = PI / 2 if at.x < 0 else -PI / 2
		if at.z < -3 and at.z > -6:
			human.rotation.y = 0 if at.z > -5 else PI
	var side := signf(at.x)
	var inner := 0.75 if lane_study else 4.0
	var outer := 1.65 if lane_study else 4.9
	var end := 23.0 if lane_study else 26.0
	var route := [Vector3(side * inner, 0, -end), Vector3(side * outer, 0, -end), Vector3(side * outer, 0, end), Vector3(side * inner, 0, end)]
	var greeting := Label3D.new()
	greeting.font = preload("res://assets/fonts/NotoSansDevanagari-Regular.ttf")
	greeting.text = "चाय पियोगे सा?" if variant == 8 else "राम राम सा!"
	greeting.font_size = 44
	greeting.pixel_size = 0.005
	greeting.position.y = 2.05
	greeting.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	greeting.modulate = Color("f7e6c6")
	greeting.outline_modulate = Color("263638")
	greeting.outline_size = 8
	greeting.visible = false
	body.add_child(greeting)
	people.append({"greeting":greeting,"greet_time":0.0,"cooldown":0.0,"route":route,"goal":0 if direction < 0 else 2,"body":body,"human":human,"walking":walking,"direction":direction,"lane":at.x,"wait":variant * 0.23,"speed":0.85 + (variant % 3) * 0.14})

func _physics_process(delta: float) -> void:
	clock += delta
	for person in people:
		var body: CharacterBody3D = person.body
		var human: Node3D = person.human
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
				if other.body == body:
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
