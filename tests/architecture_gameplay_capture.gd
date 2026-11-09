extends SceneTree
## In-game HUD and character, plus a close architectural view of the same live world.
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("run")
func ticks(n: int) -> void:
	for i in n: await physics_frame
func shot(path: String) -> void:
	for i in 5: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://designs/13-architecture/"+path+".png")
func run() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	await ticks(20)
	scene.travel_to(scene.world.landmarks.size()+scene.world.services.size())
	await ticks(70)
	await shot("after-restaurant-gameplay")
	scene.hud.map_open=true
	scene.hud.dining_tab=true
	scene.hud.services_tab=false
	await shot("after-dining-atlas")
	scene.hud.map_open=false
	var palace: Dictionary=scene.world.palace_entry
	var p: Vector3=palace.origin
	var b: Basis=palace.basis
	scene.player.position=p+b*Vector3(0,.5,20)
	scene.player.velocity=Vector3.ZERO
	scene.world.update_cells(scene.player.position)
	scene.yaw=-PI/2
	scene.smooth_yaw=scene.yaw
	await ticks(35)
	await shot("after-palace-gameplay")
	var camera:=Camera3D.new()
	scene.add_child(camera)
	camera.make_current()
	camera.fov=67
	camera.position=p+b*Vector3(12,5.5,52)
	camera.look_at(p+b*Vector3(0,5,20))
	scene.world.player_ref=camera
	scene.hud.hide()
	scene.actions.hide()
	await shot("after-palace-gateway")
	quit()
