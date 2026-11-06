extends SceneTree
## Renders every motion-capture action clip on the hero: three frames (early, middle, late) side
## by side per clip, into designs/12-real-motion/<clip>.png.
## Run: xvfb-run -a -s '-screen 0 1280x800x24' ./play.sh --script res://tests/mocap_review.gd
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
	var floor:=MeshInstance3D.new()
	var plane:=PlaneMesh.new()
	plane.size=Vector2(6,6)
	floor.mesh=plane
	var floor_mat:=StandardMaterial3D.new()
	floor_mat.albedo_color=Color("6f7577")
	floor.material_override=floor_mat
	stage.add_child(floor)
	hero=preload("res://human.gd").new()
	hero.rotation.y=PI
	stage.add_child(hero)
	var camera:=Camera3D.new()
	camera.near=.05
	camera.fov=40
	stage.add_child(camera)
	camera.make_current()
	camera.position=Vector3(1.9,1.25,2.6)
	camera.look_at(Vector3(0,.95,0))
	await wait_frames(15)
	hero.set_process(false)
	hero.apply_outfit(0)
	await wait_frames(4)
	var out:="res://designs/12-real-motion/"
	DirAccess.make_dir_recursive_absolute(out)
	var clips: Array=[]
	for name in hero.animator.get_animation_list():
		if name.begins_with("action/"):
			clips.append(name.trim_prefix("action/"))
	clips.sort()
	var mocap: Array=[]
	for name in hero.animator.get_animation_list():
		if name.begins_with("Mocap"):
			mocap.append(name.trim_prefix("Mocap"))
	print("ACTIONS ",clips," MOCAP ",mocap)
	for clip_name in clips:
		var animation: Animation=hero.animator.get_animation("action/"+clip_name)
		var sheet:=Image.create(3*640,400,false,Image.FORMAT_RGBA8)
		var column:=0
		for fraction in [0.05,0.45,0.85]:
			hero.animation_tree.active=false
			hero.animator.play("action/"+clip_name,0.0)
			hero.animator.seek(fraction*animation.length,true)
			hero.animator.pause()
			await wait_frames(3)
			var shot:=root.get_texture().get_image()
			shot.resize(640,400,Image.INTERPOLATE_BILINEAR)
			sheet.blit_rect(shot,Rect2i(0,0,640,400),Vector2i(column*640,0))
			column+=1
		sheet.save_png(out+clip_name.to_lower()+".png")
		print("CLIP ",clip_name," len %.2f"%animation.length," mocap=",clip_name in mocap)
	quit()
