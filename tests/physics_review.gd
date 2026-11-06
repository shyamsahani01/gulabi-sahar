extends SceneTree
## Renders the ragdoll knockdown (kick) on the hero: three moments after the blow, and the
## Street necklace swinging after a sprint stop. Output: designs/12-real-motion/ragdoll.png
var hero: Node3D
func _initialize() -> void:
	call_deferred("capture")
func wait_frames(n: int) -> void:
	for i in n:
		await process_frame
	await RenderingServer.frame_post_draw
func capture() -> void:
	var stage:=Node3D.new()
	root.add_child(stage)
	var env:=WorldEnvironment.new()
	env.environment=Environment.new()
	env.environment.background_mode=Environment.BG_COLOR
	env.environment.background_color=Color("8e989b")
	env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color=Color("d4dde5")
	env.environment.ambient_light_energy=.55
	stage.add_child(env)
	var light:=DirectionalLight3D.new()
	light.rotation_degrees=Vector3(-35,-40,0)
	light.light_energy=.9
	stage.add_child(light)
	var ground:=StaticBody3D.new()
	ground.collision_layer=1
	var shape:=CollisionShape3D.new()
	var box:=BoxShape3D.new()
	box.size=Vector3(8,.2,8)
	shape.shape=box
	shape.position=Vector3(0,-.1,0)
	ground.add_child(shape)
	var floor:=MeshInstance3D.new()
	var plane:=PlaneMesh.new()
	plane.size=Vector2(8,8)
	floor.mesh=plane
	var floor_mat:=StandardMaterial3D.new()
	floor_mat.albedo_color=Color("6f7577")
	floor.material_override=floor_mat
	ground.add_child(floor)
	stage.add_child(ground)
	hero=preload("res://human.gd").new()
	hero.rotation.y=PI
	stage.add_child(hero)
	var camera:=Camera3D.new()
	camera.near=.05
	camera.fov=42
	stage.add_child(camera)
	camera.make_current()
	camera.position=Vector3(2.4,1.4,2.8)
	camera.look_at(Vector3(0,.7,0))
	await wait_frames(20)
	hero.apply_outfit(0)
	await wait_frames(5)
	var out:="res://designs/12-real-motion/"
	DirAccess.make_dir_recursive_absolute(out)
	var sheet:=Image.create(3*640,400,false,Image.FORMAT_RGBA8)
	hero.knock_down(Vector3(-1.5,2.5,3.5))
	var column:=0
	for wait in [8,22,45]:
		await wait_frames(wait)
		var shot:=root.get_texture().get_image()
		shot.resize(640,400,Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(shot,Rect2i(0,0,640,400),Vector2i(column*640,0))
		column+=1
	sheet.save_png(out+"ragdoll.png")
	print("RAGDOLL sheet saved; ragdolling=",hero.ragdolling," time=%.2f"%hero.ragdoll_time)
	hero.get_up()
	await wait_frames(5)
	print("RECOVERED tree_active=",hero.animation_tree.active)
	quit()
