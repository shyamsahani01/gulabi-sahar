extends SceneTree
## Actual runtime meshes, same mobile-compatible renderer as desktop play.
const OUT:="res://designs/14-compact-city/"
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("run")
func capture(camera: Camera3D,at: Vector3,target: Vector3,file: String) -> void:
	camera.position=at
	camera.look_at(target)
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+file+".png")
	print("CAPTURE ",file," draws=",Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var world=load("res://city_world.gd").new()
	root.add_child(world)
	var camera:=Camera3D.new()
	root.add_child(camera)
	camera.make_current()
	camera.far=1400
	camera.near=.6
	world.player_ref=camera
	var p: Vector3=world.spawn_point
	world.update_cells(p)
	camera.fov=58
	await capture(camera,p+Vector3(95,100,125),p+Vector3(0,3,-55),"01-vdn-aerial")
	var showroom: Dictionary=world.services[0]
	p=Vector3(showroom.building.x,0,showroom.building.z)
	var b:=Basis(Vector3.UP,showroom.rotation)
	await capture(camera,p+b*Vector3(14,4,showroom.building.d/2+18),p+Vector3(0,2,0),"02-vdn-showroom")
	for entry in world.services:
		if entry.kind=="chai":
			p=Vector3(entry.building.x,0,entry.building.z)
			b=Basis(Vector3.UP,entry.rotation)
			await capture(camera,p+b*Vector3(8,3.8,entry.building.d/2+13),p+Vector3(0,2,0),"03-vdn-street")
	var vki: Dictionary=world.landmarks[2]
	p=Vector3(vki.p[0],0,vki.p[1])
	await capture(camera,p+Vector3(100,85,120),p+Vector3(0,2,-20),"04-vki-aerial")
	# Vehicle review stage uses the actual runtime design, at full real-world scale.
	world.player_ref=null
	world.hide()
	var stage:=Node3D.new()
	root.add_child(stage)
	var ground:=MeshInstance3D.new()
	var plane:=PlaneMesh.new()
	plane.size=Vector2(200,200)
	ground.mesh=plane
	ground.material_override=world.mats.tarmac
	stage.add_child(ground)
	var env:=WorldEnvironment.new()
	for child in world.get_children():
		if child is WorldEnvironment: env.environment=child.environment.duplicate(true)
	stage.add_child(env)
	var sun:=DirectionalLight3D.new()
	sun.rotation_degrees=Vector3(-32,-35,0)
	sun.light_energy=1.1
	sun.light_color=Color("ffe6c7")
	sun.shadow_enabled=true
	sun.directional_shadow_max_distance=70
	stage.add_child(sun)
	camera.fov=38
	var colors:=[Color("e9dcc3"),Color("151a20"),Color("ecf0ee"),Color("196d77")]
	for i in 4:
		var model=load("res://vehicle_design.gd").new()
		model.style=["sedan","taxi","police","suv"][i]
		model.paint=colors[i]
		stage.add_child(model)
		await capture(camera,Vector3(5.7,2.6,-7.3),Vector3(0,.8,0),"vehicle-"+model.style)
		model.queue_free()
		await process_frame
	for i in 4:
		var model=load("res://vehicle_design.gd").new()
		model.style=["sedan","taxi","police","suv"][i]
		model.paint=colors[i]
		model.position=Vector3((i-1.5)*3.7,0,0)
		stage.add_child(model)
	camera.fov=48
	await capture(camera,Vector3(8,5,-17),Vector3(0,.8,0),"05-vehicle-lineup")
	stage.queue_free()
	world.queue_free()
	await process_frame
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	for i in 90: await physics_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"06-gameplay.png")
	scene.hud.map_open=true
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"07-atlas.png")
	quit()
