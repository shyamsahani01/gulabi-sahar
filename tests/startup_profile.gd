extends SceneTree
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("run")
func run() -> void:
	var start := Time.get_ticks_msec()
	var packed := load("res://main.tscn") as PackedScene
	var loaded := Time.get_ticks_msec()
	var scene := packed.instantiate()
	root.add_child(scene)
	var built := Time.get_ticks_msec()
	for i in 5:await physics_frame
	print("STARTUP_PROFILE ",JSON.stringify({"resource_ms":loaded-start,"scene_build_ms":built-loaded,"first_population_ms":Time.get_ticks_msec()-built,"roads":scene.world.data.roads.size(),"buildings":scene.world.data.buildings.size(),"amenities":scene.world.amenities.size()}))
	quit()
