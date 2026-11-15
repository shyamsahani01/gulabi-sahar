extends SceneTree
func _initialize() -> void:
	Engine.max_fps=0
	RenderingServer.render_loop_enabled=false
	call_deferred("run")
func run() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	for i in 50:await physics_frame
	var a: Dictionary={}
	for entry in scene.world.amenities:
		if entry.get("design","")=="cinestar_exterior":a=entry
	var at:=Vector3(a.p[0],0,a.p[1])
	var facing:=Basis(Vector3.UP,a.a)
	scene.player.position=at+facing*Vector3(0,1,22)
	scene.world.update_cells(at)
	scene.hud.hide()
	scene.actions.hide()
	scene.actions.set_process(false)
	var camera:=Camera3D.new()
	scene.add_child(camera)
	camera.make_current()
	camera.fov=65
	for spec in [["front",Vector3(0,4,30),Vector3(0,7,0)],["approach",Vector3(-23,7,24),Vector3(0,6,0)],["entrance",Vector3(1,1.8,13),Vector3(0,2.5,a.d/2)]]:
		camera.position=at+facing*spec[1]
		camera.look_at(at+facing*spec[2])
		RenderingServer.render_loop_enabled=true
		for i in 4:await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://designs/17-sector-2-central-spine/engine-cinestar-"+spec[0]+".png")
		RenderingServer.render_loop_enabled=false
		print("CAPTURE Cinestar ",spec[0])
	quit()
