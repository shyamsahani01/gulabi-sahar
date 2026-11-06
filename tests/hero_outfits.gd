extends SceneTree
## Renders each wardrobe outfit on the hero: front portrait, three-quarter and full body.
## Run: xvfb-run -a -s '-screen 0 1280x800x24' ./play.sh --script res://tests/hero_outfits.gd
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
	var out:="res://designs/10-hero-outfits/"
	DirAccess.make_dir_recursive_absolute(out)
	var wardrobe=preload("res://hero_wardrobe.gd")
	for i in wardrobe.OUTFITS.size():
		hero.apply_outfit(i)
		var name: String=str(i)+"-"+wardrobe.OUTFITS[i].name.to_lower()
		await wait_frames(6)
		for view in [["front",Vector3(0,1.58,.85),Vector3(0,1.58,0)],["three-quarter",Vector3(.57,1.45,.63),Vector3(0,1.42,0)],["full-body",Vector3(.6,1.1,3.4),Vector3(0,.93,0)]]:
			camera.position=view[1]
			camera.look_at(view[2])
			await wait_frames(3)
			root.get_texture().get_image().save_png(out+name+"-"+view[0]+".png")
		print("OUTFIT ",name)
	quit()
