extends SceneTree
func _initialize() -> void:
	Engine.max_fps=0
	RenderingServer.render_loop_enabled=false
	call_deferred("run")
func run() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	for i in 50:await physics_frame
	var site: String="funstar" if "funstar" in OS.get_cmdline_user_args() else "cinestar"
	var design: String="times_square_exterior" if site=="funstar" else "cinestar_exterior"
	var a: Dictionary={}
	for entry in scene.world.amenities:
		if entry.get("design","")==design:a=entry
	var at:=Vector3(a.p[0],0,a.p[1])
	var facing:=Basis(Vector3.UP,a.a+(PI if a.get("front",1)<0 else 0))
	scene.player.position=at+facing*Vector3(0,1,22)
	scene.world.update_cells(at)
	scene.hud.hide()
	scene.actions.hide()
	scene.actions.set_process(false)
	var camera:=Camera3D.new()
	scene.add_child(camera)
	camera.make_current()
	camera.fov=65
	for spec in [["front",Vector3(0,4,maxf(30,a.w*1.4)),Vector3(0,7,0)],["approach",Vector3(a.w*1.1,7,maxf(24,a.d*1.4)),Vector3(0,6,0)],["entrance",Vector3(1,1.8,a.d/2+7),Vector3(0,2.5,a.d/2)]]:
		if "front-only" in OS.get_cmdline_user_args() and spec[0]!="front":continue
		camera.fov=65
		if site=="funstar" and spec[0]=="front":
			# Stay in the real gap before the opposite building; use a wide street-level view.
			spec[1]=Vector3(0,3,22)
			camera.fov=110
		camera.position=at+facing*spec[1]
		camera.look_at(at+facing*spec[2])
		RenderingServer.render_loop_enabled=true
		for i in 4:await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://designs/17-sector-2-central-spine/engine-"+site+"-"+spec[0]+".png")
		RenderingServer.render_loop_enabled=false
		print("CAPTURE ",site," ",spec[0])
	quit()
