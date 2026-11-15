extends SceneTree
const OUT := "res://designs/17-sector-2-central-spine/"
func _initialize() -> void:
	Engine.max_fps=0
	RenderingServer.render_loop_enabled=false
	call_deferred("run")
func shot(name: String) -> void:
	RenderingServer.render_loop_enabled=true
	for i in 4:await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+name+".png")
	RenderingServer.render_loop_enabled=false
	print("CAPTURE ",name)
func run() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	for i in 60:await physics_frame
	var a: Dictionary={}
	for entry in scene.world.amenities:
		if entry.get("sector2_design","")=="rose_tower":a=entry
	var at:=Vector3(a.p[0],0,a.p[1])
	scene.player.position=at+Vector3(0,1,18)
	scene.world.update_cells(at)
	scene.hud.hide()
	scene.actions.set_process(false)
	scene.actions.hide()
	var camera:=Camera3D.new()
	scene.add_child(camera)
	camera.make_current()
	camera.fov=65
	var facing:=Basis(Vector3.UP,a.a)
	camera.position=at+facing*Vector3(0,4,37)
	camera.look_at(at+Vector3(0,10,0))
	await shot("engine-01-tower")
	camera.position=at+facing*Vector3(-24,13,32)
	camera.look_at(at+Vector3(0,5,0))
	await shot("engine-02-street")
	camera.position=at+facing*Vector3(4,2.0,a.d/2+9)
	camera.look_at(at+facing*Vector3(0,2.3,a.d/2))
	await shot("engine-03-frontage")
	quit()
