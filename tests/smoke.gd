extends SceneTree

var failures := 0
func _initialize() -> void:
	Engine.max_fps = 0
	call_deferred("check")
func expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
func ticks(count: int) -> void:
	for i in range(count):
		await physics_frame
func finger(hud: Control, id: int, pos: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = id
	event.position = pos
	event.pressed = pressed
	hud._input(event)
func check() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	await ticks(90)
	expect(scene.player.is_on_floor(), "Player must land on street")
	var start: Vector3 = scene.player.position
	scene.touch_move = Vector2(0, -1)
	await ticks(60)
	scene.touch_move = Vector2.ZERO
	expect(scene.player.position.distance_to(start) > 2, "Player must move")
	scene.jump_requested = true
	await ticks(10)
	expect(scene.player.position.y > 0.5, "Player must jump")
	await ticks(90)
	expect(scene.player.is_on_floor(), "Player must land after jumping")
	# The south gateway closes the block; the road north stays open into Chandpole.
	scene.player.position = Vector3(0, 0.3, 36)
	scene.player.velocity = Vector3.ZERO
	scene.touch_move = Vector2(0, 1)
	await ticks(90)
	scene.touch_move = Vector2.ZERO
	expect(scene.player.position.z < 40.5, "South gateway must stop the player")
	scene.player.position = Vector3(0, 0.3, -36)
	scene.player.velocity = Vector3.ZERO
	scene.touch_move = Vector2(0, -1)
	await ticks(90)
	scene.touch_move = Vector2.ZERO
	expect(scene.player.position.z < -38.5, "Road must continue north into Chandpole")
	# World zones, terrain and the embedded gali.
	var world = scene.world
	expect(world.zone_at(0.0).id == "hawa_mahal", "Hawa Mahal zone must cover the start")
	expect(world.zone_at(-120.0).id == "chandpole", "Chandpole zone must follow")
	expect(world.zone_at(-400.0).id == "vdn", "Vidhyadhar Nagar zone must exist")
	expect(world.zone_at(-700.0).id == "hills", "Hills zone must end the map")
	expect(world.terrain_height(0.0, -700.0) > 50.0, "Ridge must rise behind Vidhyadhar Nagar")
	expect(world.terrain_height(0.0, -495.0) < 0.5, "Viewpoint road must stay flat")
	expect(world.gali != null and world.gali.get_child_count() > 5, "Old gali must be embedded")
	# Hills must be walkable: drop the player on the slope and let physics settle.
	scene.player.position = Vector3(0, world.terrain_height(0.0, -560.0) + 1.5, -560.0)
	scene.player.velocity = Vector3.ZERO
	await ticks(60)
	expect(scene.player.is_on_floor() and scene.player.position.y > 5.0, "Player must stand on the hillside terrain")
	scene.player.position = Vector3(11.3, 0.4, 30.0)
	scene.player.velocity = Vector3.ZERO
	await ticks(10)
	# The imported rig must actually deform, and root motion must remain in place.
	var hero: Node3D = scene.avatar
	expect(hero.skeleton.get_bone_count() > 40, "Human rig must be loaded")
	expect(hero.animator.has_animation("Run") and hero.animator.has_animation("Walk"), "Real locomotion clips must be loaded")
	var walk: Animation = hero.animator.get_animation("Walk")
	for track in range(walk.get_track_count()):
		if walk.track_get_type(track) == Animation.TYPE_POSITION_3D and str(walk.track_get_path(track)) == "Shyam_rig":
			for key in range(walk.track_get_key_count(track)):
				var pos: Vector3 = walk.track_get_key_value(track, key)
				expect(absf(pos.x) < 0.001 and absf(pos.z) < 0.001, "Animation must not drift away from collider")
	expect(hero.face != null, "Hero must expose native facial blendshapes")
	for expression in ["Smile", "Serious", "Surprised"]:
		var index: int = hero.face.find_blend_shape_by_name(expression)
		expect(index >= 0, "Required facial expression must exist: " + expression)
		hero.set_expression(expression, 100)
		await ticks(20)
		expect(hero.face.get_blend_shape_value(index) > 0.9, "Expression must actually deform the mesh")
	scene.toggle_portrait()
	expect(scene.portrait_camera.current, "Face view must select close camera")
	var previous_expression: String = hero.expression
	scene.hud.expression_changed.emit()
	expect(hero.expression != previous_expression, "Expression selector must change the facial state")
	scene.toggle_portrait()
	expect(not scene.portrait_camera.current, "Back must restore gameplay camera")
	hero.set_expression("Neutral")
	var life = scene.get_node("MarketLife")
	expect(life.people.size() >= 40, "World population must be present")
	var kinds := {}
	for person in life.people:
		kinds[person.kind] = kinds.get(person.kind, 0) + 1
	expect(kinds.get("child", 0) >= 8 and kinds.get("elder", 0) >= 4 and kinds.get("adult", 0) >= 20, "Children, elders and adults must all be present")
	var starts: Array[Vector3] = []
	for person in life.people:
		starts.append(person.body.position)
	await ticks(180)
	var movers := 0
	for i in range(life.people.size()):
		var person = life.people[i]
		if person.body.position.distance_to(starts[i]) > 0.5:
			movers += 1
		expect(person.body.position.y > -0.2, "NPC must not fall through ground")
		expect(person.body.position.z < 45 and person.body.position.z > -780, "NPC must stay inside the world")
	expect(movers >= 4, "Pedestrians near the player must actually walk")
	var vendor = null
	for person in life.people:
		if not person.walking and person.body.position.z < 0 and person.body.position.x < -10:
			vendor = person
			break
	expect(vendor != null, "A shopkeeper must stand under Hawa Mahal")
	scene.player.position = vendor.body.position + Vector3(1.0, 0.2, 0)
	scene.player.velocity = Vector3.ZERO
	await ticks(5)
	expect(vendor.greeting.visible, "Nearby shopkeeper must greet player")
	scene.player.position = Vector3(11.3, 0.4, 0)
	# Animals must exist and wander.
	var animals = scene.get_node("Animals")
	expect(animals.creatures.size() >= 25, "Street animals must be present")
	var animal_starts: Array[Vector3] = []
	for c in animals.creatures:
		animal_starts.append(c.root.position)
	await ticks(240)
	var animal_movers := 0
	for i in range(animals.creatures.size()):
		if animals.creatures[i].root.position.distance_to(animal_starts[i]) > 0.3:
			animal_movers += 1
	expect(animal_movers >= 3, "Animals near the player must wander")
	if "--soak" in OS.get_cmdline_user_args():
		var distances: Array[float] = []
		for i in range(6): distances.append(0.0)
		for second in range(60):
			var previous: Array[Vector3] = []
			for i in range(6): previous.append(life.people[i].body.position)
			await ticks(60)
			for i in range(6):
				distances[i] += life.people[i].body.position.distance_to(previous[i])
				expect(absf(life.people[i].body.position.z) < 42, "Patrol must remain within Hawa Mahal Road")
		for distance in distances:
			expect(distance > 20, "Patrol must not become permanently blocked")
		print("Patrol distances over 60 simulated seconds: ", distances)
		for person in life.people:
			if person.walking: print("PATROL ", person.body.name, " ", person.body.position, " goal ", person.goal, " velocity ", person.body.velocity)
	var hud: Control = scene.hud
	finger(hud, 0, hud.center() + Vector2(0, -64), true)
	expect(hud.movement.y < -0.9, "Joystick must move forward")
	finger(hud, 1, hud.jump_center(), true)
	expect(scene.jump_requested, "Second finger must jump while moving")
	finger(hud, 1, hud.jump_center(), false)
	expect(hud.movement.y < -0.9, "Jump release must not cancel movement")
	var look_pos := Vector2(800, 300)
	finger(hud, 2, look_pos, true)
	var drag := InputEventScreenDrag.new()
	drag.index = 2
	drag.position = look_pos
	drag.relative = Vector2(30, 0)
	var previous_yaw: float = scene.yaw
	hud._input(drag)
	expect(scene.yaw < previous_yaw, "Independent camera finger must rotate camera")
	finger(hud, 0, hud.center(), false)
	expect(hud.movement == Vector2.ZERO, "Joystick release must stop movement")
	finger(hud, 3, hud.run_center(), true)
	expect(hud.running, "Run button must enable running")
	hud.clear_input()
	expect(not hud.running and hud.look_id == -1 and hud.move_id == -1, "Focus loss must clear input")
	finger(hud, 4, hud.map_center(), true)
	expect(hud.map_open, "MAP button must open the map")
	expect(not hud.zone_name.is_empty(), "HUD must show the current zone")
	finger(hud, 4, hud.map_center(), false)
	finger(hud, 5, Vector2(600, 400), true)
	expect(not hud.map_open, "Tapping the map must close it")
	print("SMOKE RESULT: ", failures, " failures; ground, movement, jump, gateway, open road, zones, terrain, gali, hillside, multitouch, camera, focus reset, imported rig, root motion, population, animals, map")
	quit(1 if failures else 0)
