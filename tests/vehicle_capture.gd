extends SceneTree
## Review actual runtime meshes from front, side and rear under a neutral sky.
const OUT := "res://designs/15-vehicle-redesign/"
var camera: Camera3D
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("run")
func capture(file: String,at: Vector3,target: Vector3) -> void:
	camera.position=at
	camera.look_at(target)
	for i in 5: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+file+".png")
	print("CAPTURE ",file)
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var stage:=Node3D.new()
	root.add_child(stage)
	var env:=WorldEnvironment.new()
	env.environment=Environment.new()
	env.environment.background_mode=Environment.BG_SKY
	var sky:=Sky.new()
	var sky_mat:=ProceduralSkyMaterial.new()
	sky_mat.sky_top_color=Color("6d8ba6")
	sky_mat.sky_horizon_color=Color("cbd3d9")
	sky_mat.ground_horizon_color=Color("cbd3d9")
	sky_mat.ground_bottom_color=Color("42464c")
	sky_mat.sun_angle_max=20
	sky_mat.sun_curve=.12
	sky.sky_material=sky_mat
	env.environment.sky=sky
	env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_SKY
	env.environment.ambient_light_energy=.38
	env.environment.tonemap_mode=Environment.TONE_MAPPER_ACES
	env.environment.tonemap_exposure=.9
	stage.add_child(env)
	var sun:=DirectionalLight3D.new()
	sun.rotation_degrees=Vector3(-38,-35,0)
	sun.light_energy=.85
	sun.shadow_enabled=true
	sun.directional_shadow_max_distance=40
	stage.add_child(sun)
	var ground:=MeshInstance3D.new()
	var plane:=PlaneMesh.new()
	plane.size=Vector2(200,200)
	ground.mesh=plane
	var mat:=StandardMaterial3D.new()
	mat.albedo_color=Color("555c63")
	mat.roughness=.95
	ground.material_override=mat
	stage.add_child(ground)
	camera=Camera3D.new()
	camera.fov=35
	camera.near=.1
	stage.add_child(camera)
	camera.make_current()
	var colors:=[Color("eee3ca"),Color("171d24"),Color("eef1f2"),Color("125761")]
	var styles:=["sedan","taxi","police","suv"]
	for i in 4:
		var car=load("res://vehicle_design.gd").new()
		car.style=styles[i]
		car.paint=colors[i]
		stage.add_child(car)
		await capture(styles[i]+"-front",Vector3(5.0,2.4,-6.7),Vector3(0,.8,0))
		if "--quick" in OS.get_cmdline_user_args():
			quit()
			return
		await capture(styles[i]+"-rear",Vector3(-5.0,2.3,6.7),Vector3(0,.8,0))
		await capture(styles[i]+"-side",Vector3(9,1.9,0),Vector3(0,.8,0))
		car.queue_free()
		await process_frame
	for i in 4:
		var car=load("res://vehicle_design.gd").new()
		car.style=styles[i]
		car.paint=colors[i]
		car.position.x=(1.5-i)*3.35
		stage.add_child(car)
	camera.fov=36
	await capture("lineup",Vector3(4.5,3.1,-14),Vector3(0,.8,0))
	quit()
