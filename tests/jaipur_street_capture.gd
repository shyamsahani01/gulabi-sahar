extends SceneTree
func _initialize() -> void:
	Engine.max_fps=0
	RenderingServer.render_loop_enabled=false
	call_deferred("run")
func run() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	for i in 45:await physics_frame
	var kit=load("res://cinestar_street.gd")
	var start: Vector2=kit.START*scene.world.CITY_COMPRESSION
	var end: Vector2=kit.END*scene.world.CITY_COMPRESSION
	scene.hud.hide()
	scene.actions.hide()
	scene.actions.set_process(false)
	var camera:=Camera3D.new()
	scene.add_child(camera)
	camera.make_current()
	camera.fov=78
	for spec in [["west",.12,.8,3.0],["east",.86,.2,3.0],["overview",.5,.51,45.0]]:
		var at:=start.lerp(end,spec[1])
		var target:=start.lerp(end,spec[2])
		scene.player.position=Vector3(at.x,1,at.y)
		scene.world.update_cells(scene.player.position)
		camera.position=Vector3(at.x,spec[3],at.y)
		camera.look_at(Vector3(target.x,3,target.y))
		RenderingServer.render_loop_enabled=true
		for i in 5:await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://designs/20-jaipur-road-and-people/engine-"+spec[0]+".png")
		RenderingServer.render_loop_enabled=false
		print("CAPTURE ",spec[0])
	for spot in scene.world.patron_spots:
		if not spot.get("street_vendor",false):continue
		scene.player.position=spot.p+Vector3(4,1,4)
		scene.world.update_cells(scene.player.position)
		for i in 90:await physics_frame
		camera.position=spot.p+Vector3(6,3.4,7)
		camera.look_at(spot.p+Vector3.UP)
		camera.fov=56
		RenderingServer.render_loop_enabled=true
		for i in 5:await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://designs/20-jaipur-road-and-people/engine-vendor.png")
		print("CAPTURE vendor")
		break
	quit()
