extends SceneTree
## Actual-engine portraits of the hero: structure views, close-ups and expressions.
## Run: xvfb-run -a -s '-screen 0 1280x800x24' ./play.sh --script res://tests/hero_portraits.gd
## Add `++ --before` to capture the same views into builds/hero-before/ for A/B comparison.
var hero: Node3D
func _initialize() -> void:
	call_deferred("capture")
func wait_frames(n: int) -> void:
	for i in n:
		await process_frame
	await RenderingServer.frame_post_draw
func shoot(camera: Camera3D, out: String, name: String, from: Vector3, at: Vector3) -> void:
	camera.position=from
	camera.look_at(at)
	await wait_frames(3)
	root.get_texture().get_image().save_png(out+name+".png")
	print("PORTRAIT ",name)
func settle_face() -> void:
	for i in 40:hero.update_face(.025)
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
	light.rotation_degrees=Vector3(-25,-30,0)
	light.light_energy=.85
	stage.add_child(light)
	hero=preload("res://human.gd").new()
	hero.rotation.y=PI
	stage.add_child(hero)
	var camera:=Camera3D.new()
	camera.near=.02
	camera.fov=32
	stage.add_child(camera)
	camera.make_current()
	await wait_frames(15)
	hero.animation_tree.active=false
	hero.animator.play("Idle")
	hero.animator.seek(1.4,true)
	hero.animator.pause()
	hero.set_process(false)
	var before:="--before" in OS.get_cmdline_user_args()
	var out:="res://builds/hero-before/" if before else "res://designs/11-face-structure/"
	DirAccess.make_dir_recursive_absolute(out)
	hero.apply_outfit(3)  # Classic: nothing covers the face
	hero.blink_phase=-1
	hero.blink_clock=1000
	await wait_frames(4)
	var face_y:=1.58
	await shoot(camera,out,"hero-front",Vector3(0,face_y,.85),Vector3(0,face_y,0))
	await shoot(camera,out,"hero-three-quarter",Vector3(.57,face_y+.01,.63),Vector3(0,face_y,0))
	await shoot(camera,out,"hero-profile",Vector3(.85,face_y,.06),Vector3(0,face_y,0))
	await shoot(camera,out,"hero-full-body",Vector3(.6,1.1,3.4),Vector3(0,.93,0))
	# Zoomed views: what the in-game FACE zoom shows at 2.5x-4x.
	await shoot(camera,out,"zoom-eyes",Vector3(0,1.595,.32),Vector3(0,1.59,0))
	await shoot(camera,out,"zoom-mouth-chin",Vector3(.12,1.525,.33),Vector3(0,1.52,0))
	await shoot(camera,out,"zoom-nose-three-quarter",Vector3(.26,1.565,.3),Vector3(0,1.555,0))
	await shoot(camera,out,"zoom-jaw-neck",Vector3(.42,1.49,.5),Vector3(0,1.47,0))
	await shoot(camera,out,"zoom-low-angle",Vector3(.2,1.42,.55),Vector3(0,1.53,0))
	# Real eyes: mid-blink and a sideways gaze.
	for side in ["BlinkLeft","BlinkRight"]:
		hero.face.set_blend_shape_value(hero.face.find_blend_shape_by_name(side),0.55)
	await shoot(camera,out,"zoom-eyes-blink",Vector3(0,1.595,.32),Vector3(0,1.59,0))
	for side in ["BlinkLeft","BlinkRight"]:
		hero.face.set_blend_shape_value(hero.face.find_blend_shape_by_name(side),0.0)
	if hero.eye_material!=null:
		hero.eye_material.uv1_offset=hero.eye_base_uv+Vector3(0.03,0,0)
		await shoot(camera,out,"zoom-eyes-gaze",Vector3(0,1.595,.32),Vector3(0,1.59,0))
		hero.eye_material.uv1_offset=hero.eye_base_uv
	for expression in ["Smile","Serious","Surprised"]:
		hero.set_expression(expression,100)
		settle_face()
		await wait_frames(3)
		await shoot(camera,out,"hero-"+expression.to_lower(),Vector3(0,face_y,.85),Vector3(0,face_y,0))
		if expression=="Smile":
			await shoot(camera,out,"smile-three-quarter",Vector3(.5,face_y+.02,.6),Vector3(0,face_y-.01,0))
			await shoot(camera,out,"smile-zoom",Vector3(.08,1.56,.42),Vector3(0,1.555,0))
	# Street outfit (the default in-game): beard, glasses; the beard must fade under the jaw.
	hero.set_expression("Neutral",100)
	settle_face()
	hero.apply_outfit(0)
	await wait_frames(4)
	await shoot(camera,out,"street-front",Vector3(0,face_y,.85),Vector3(0,face_y,0))
	await shoot(camera,out,"street-jaw-neck",Vector3(.42,1.49,.5),Vector3(0,1.47,0))
	hero.set_expression("Smile",100)
	settle_face()
	await wait_frames(3)
	await shoot(camera,out,"street-smile",Vector3(.3,face_y,.7),Vector3(0,face_y,0))
	quit()
