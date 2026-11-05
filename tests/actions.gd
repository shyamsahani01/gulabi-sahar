extends SceneTree
var failures := 0
func expect(value: bool, label: String) -> void:
	if not value:
		failures += 1
		push_error(label)
func _initialize() -> void:
	call_deferred("check")
func check() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	for i in range(90):
		await physics_frame
	if scene.world.get_script().resource_path.ends_with("city_world.gd"):
		print("LEGACY TEST SKIPPED: main.tscn now loads the OSM city (city_world.gd). This test targets the v0.6/v0.7 hand-built world.gd scene; run tests/city_smoke.gd and tests/city_combat.gd instead.")
		quit(0)
		return
	var person: Dictionary = scene.activity.people[0]
	person.walking = false
	scene.player.position = person.body.position + Vector3(0, 0, 1.2)
	scene.player.velocity = Vector3.ZERO
	scene.avatar.rotation.y = 0
	await physics_frame
	scene.actions.talk()
	expect(scene.actions.dialogue_open, "Nearby resident opens conversation")
	scene.actions.close_dialogue()
	expect(person.stun == 0, "Closing releases resident")
	for i in range(3):
		scene.attack_cooldown = 0
		scene.actions.attack()
	expect(person.get("defeated", false), "Three hits defeat resident")
	expect(person.body.collision_layer == 0, "Downed resident does not block walking")
	expect(scene.actions.marks.size() == 3, "Blood FX created")
	person.respawn = 0.01
	for i in range(3):
		await physics_frame
	expect(not person.defeated and person.health == 100, "Resident recovers")
	scene.stamina = 100
	scene.actions.dash()
	expect(scene.stamina == 65 and scene.dash_time > 0, "Dash costs stamina")
	scene.player.position = Vector3(65, 1, -250)
	scene.player.velocity = Vector3.ZERO
	for i in range(90):
		await physics_frame
	expect(scene.player.is_on_floor(), "Artisan square has walkable ground")
	print("ACTION RESULT: ", failures, " failures")
	quit(1 if failures else 0)
