extends SceneTree
const OUT := "res://designs/16-vki-vdn-streets/"
func _initialize() -> void:
	Engine.max_fps=0
	RenderingServer.render_loop_enabled=false
	call_deferred("run")
func shot(file: String) -> void:
	RenderingServer.render_loop_enabled=true
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+file+".png")
	print("CAPTURE ",file)
	RenderingServer.render_loop_enabled=false
func run() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	for i in 70: await physics_frame
	if "--driver-only" not in OS.get_cmdline_user_args(): await shot("01-context-controls")
	scene.hud.map_open=true
	await shot("02-modern-atlas")
	var atlas=scene.hud.atlas
	atlas.search.text="theka"
	atlas.refresh_results()
	await shot("03-all-wine-shops")
	atlas.search.text="Road Number 5"
	atlas.category.selected=1
	atlas.refresh_results()
	atlas.select_entry(atlas.filtered[0])
	atlas.zoom=12
	await shot("04-street-selection")
	atlas.travel()
	for i in 60: await physics_frame
	var camera:=Camera3D.new()
	scene.add_child(camera)
	camera.make_current()
	camera.fov=58
	camera.far=900
	var road: Dictionary={}
	for r in scene.world.data.roads:
		if int(r.get("id",0))==374927752: road=r
	var p: Array=road.p[road.p.size()/2]
	var origin:=Vector3(p[0],0,p[1])
	scene.world.update_cells(origin)
	camera.position=origin+Vector3(28,17,30)
	camera.look_at(origin+Vector3(0,2,0))
	scene.hud.hide()
	scene.actions.set_process(false)
	scene.actions.hide()
	await shot("05-road-5-pilot")
	for building in scene.world.data.buildings:
		if not building.has("street_pilot"): continue
		var base:=Vector3(building.x,0,building.z)
		var facing:=Basis(Vector3.UP,building.a)
		camera.position=base+facing*Vector3(9,3.2,building.d/2+14)
		camera.look_at(base+Vector3(0,2.5,0))
		await shot("08-workshop-frontage")
		break
	# Driver visibility through the actual windshield / side glass.
	scene.travel_to(0)
	for i in 45: await physics_frame
	scene.player.position=scene.vehicle.position+Vector3(2.2,0,0)
	scene.vehicle.toggle_drive()
	for i in 40: await physics_frame
	scene.vehicle.speed=0
	camera.fov=38
	camera.position=scene.vehicle.to_global(Vector3(3,1.9,-3.4))
	camera.look_at(scene.vehicle.to_global(Vector3(.1,1.0,-.1)))
	await shot("06-visible-driver")
	camera.position=scene.vehicle.to_global(Vector3(2.8,1.65,-.4))
	camera.look_at(scene.vehicle.to_global(Vector3(.3,1,.05)))
	await shot("07-driver-side")
	quit()
