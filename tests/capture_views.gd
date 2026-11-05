extends SceneTree
# Captures real engine renders of the world for design review.
# Run: xvfb-run -s "-screen 0 1280x800x24" ./play.sh --fixed-fps 60 --script res://tests/capture_views.gd

const VIEWS := [
	{"name": "01-hawa-mahal-road", "pos": Vector3(9.0, 1.7, 34.0), "look": Vector3(-8.0, 6.0, -10.0)},
	{"name": "02-hawa-mahal-facade", "pos": Vector3(4.0, 1.7, -8.0), "look": Vector3(-12.0, 7.0, -22.0)},
	{"name": "03-old-gali-mouth", "pos": Vector3(-6.0, 1.7, 21.0), "look": Vector3(-40.0, 3.0, 20.0)},
	{"name": "04-inside-gali", "pos": Vector3(-20.0, 1.7, 20.0), "look": Vector3(-60.0, 3.0, 20.0)},
	{"name": "05-chandpole-bazar", "pos": Vector3(8.0, 1.7, -50.0), "look": Vector3(-4.0, 6.0, -118.0)},
	{"name": "06-chandpole-gate", "pos": Vector3(0.0, 1.7, -100.0), "look": Vector3(0.0, 9.0, -118.0)},
	{"name": "07-sikar-road", "pos": Vector3(-9.0, 1.7, -150.0), "look": Vector3(6.0, 6.0, -230.0)},
	{"name": "08-petrol-pump", "pos": Vector3(4.0, 1.7, -215.0), "look": Vector3(20.0, 4.0, -232.0)},
	{"name": "09-vdn-houses", "pos": Vector3(-7.0, 1.7, -322.0), "look": Vector3(-16.0, 4.0, -350.0)},
	{"name": "10-vdn-park", "pos": Vector3(9.0, 1.7, -390.0), "look": Vector3(30.0, 3.0, -420.0)},
	{"name": "11-temple-and-hills", "pos": Vector3(6.0, 1.7, -440.0), "look": Vector3(-14.0, 8.0, -500.0)},
	{"name": "12-view-point", "pos": Vector3(0.0, 2.0, -500.0), "look": Vector3(0.0, 40.0, -640.0)},
	{"name": "13-from-the-chhatri", "pos": Vector3(6.0, 2.2, -598.0), "look": Vector3(0.0, 0.0, -300.0)},
	{"name": "14-nahargarh-wall", "pos": Vector3(20.0, 2.0, -660.0), "look": Vector3(0.0, 0.0, -712.0)},
]

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	for i in range(30):
		await process_frame
	var camera := Camera3D.new()
	camera.fov = 66
	camera.near = 0.15
	camera.far = 900
	root.add_child(camera)
	camera.make_current()
	scene.hud.visible = false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://designs/03-world"))
	for view in VIEWS:
		var pos: Vector3 = view.pos
		var look: Vector3 = view.look
		if scene.world.has_method("terrain_height"):
			pos.y += scene.world.terrain_height(pos.x, pos.z)
			look.y += scene.world.terrain_height(look.x, look.z)
		camera.position = pos
		camera.look_at(look)
		scene.player.position = pos + Vector3(0, 0.3, 2.0)
		scene.player.velocity = Vector3.ZERO
		for i in range(12):
			await process_frame
		var image: Image = root.get_viewport().get_texture().get_image()
		var path := "res://designs/03-world/actual-3d-" + str(view.name) + ".png"
		image.save_png(path)
		print("CAPTURED ", path)
	quit(0)
