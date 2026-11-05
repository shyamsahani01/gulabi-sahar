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
	expect(scene.player.position.y > 0.3, "Player must jump")
	await ticks(90)
	expect(scene.player.is_on_floor(), "Player must land after jumping")
	scene.player.position = Vector3(0, 0.1, -24)
	scene.player.velocity = Vector3.ZERO
	scene.touch_move = Vector2(0, -1)
	await ticks(90)
	scene.touch_move = Vector2.ZERO
	expect(scene.player.position.z > -27.3, "Boundary must stop the player")
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
	expect(life.people.size() == 10, "Market population must be present")
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
		expect(absf(person.body.position.z) < 30, "NPC must stay inside the street")
	expect(movers >= 4, "Pedestrians must actually walk")
	var vendor = life.people[7]
	scene.player.position = vendor.body.position + Vector3(-1.0, 0.2, 0)
	scene.player.velocity = Vector3.ZERO
	await ticks(5)
	expect(vendor.greeting.visible, "Nearby shopkeeper must greet player")
	scene.player.position = Vector3(0, 0.1, 0)
	if "--soak" in OS.get_cmdline_user_args():
		var distances: Array[float] = []
		for i in range(6): distances.append(0.0)
		for second in range(60):
			var previous: Array[Vector3] = []
			for i in range(6): previous.append(life.people[i].body.position)
			await ticks(60)
			for i in range(6):
				distances[i] += life.people[i].body.position.distance_to(previous[i])
				expect(absf(life.people[i].body.position.z) < 29, "Patrol must remain within map")
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
	print("SMOKE RESULT: ", failures, " failures; ground, movement, jump, boundary, multitouch, camera, focus reset, imported rig, root motion, market population")
	quit(1 if failures else 0)
