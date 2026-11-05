extends SceneTree
var failures := 0
func _initialize() -> void:
	Engine.max_fps = 0
	call_deferred("check")
func expect(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func check() -> void:
	var stage = load("res://art_review/review.tscn").instantiate()
	root.add_child(stage)
	for i in range(30): await physics_frame
	expect(stage.hero.skeleton.get_bone_count() > 40, "Review hero must keep the animated body rig")
	expect(stage.hero.face != null, "Review hero must keep expression morphs")
	for expression in ["Smile", "Serious", "Surprised"]:
		stage.hero.set_expression(expression, 10)
		for i in range(18): await physics_frame
		var index: int = stage.hero.face.find_blend_shape_by_name(expression)
		expect(index >= 0 and stage.hero.face.get_blend_shape_value(index) > 0.9, "Facial state must actually blend: " + expression)
	var initial: Vector3 = stage.walkers[0].position
	for i in range(60): await physics_frame
	expect(stage.walkers[0].position.distance_to(initial) > 0.5, "Lane pedestrians must actually move")
	var query := PhysicsRayQueryParameters3D.create(Vector3(0, 2, 7), Vector3(0, -1, 7))
	expect(not stage.get_world_3d().direct_space_state.intersect_ray(query).is_empty(), "Lane requires physical ground")
	for mode in range(3):
		stage.mode = mode
		stage.update_camera()
		expect(stage.camera.current and stage.camera.position.is_finite(), "Review camera must remain usable in all views")
	print("ART REVIEW RESULT: ", failures, " failures; native rig, expressions, walking NPCs, floor and cameras")
	quit(1 if failures else 0)
