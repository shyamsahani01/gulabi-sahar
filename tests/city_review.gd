extends SceneTree
# Real engine renders of the OSM city for design review (nothing here is concept art).
# Run: xvfb-run -a -s "-screen 0 1280x800x24" ./play.sh --fixed-fps 60 --script res://tests/city_review.gd
const OUT := "res://designs/04-city/"
var scene: Node3D
func _initialize() -> void:
	call_deferred("capture")
func settle(frames: int) -> void:
	for i in range(frames):
		await process_frame
	await RenderingServer.frame_post_draw
func shot(name: String) -> void:
	await settle(6)
	root.get_texture().get_image().save_png(OUT+"actual-3d-"+name+".png")
	print("CAPTURED ",name)
func place(at: Vector3,yaw: float,pitch := -0.12) -> void:
	# Teleport the player and point the orbit camera; the world streams cells around it.
	var p := Vector3(at.x,scene.world.terrain_height(at.x,at.z)+1.0,at.z)
	scene.player.position = p
	scene.player.velocity = Vector3.ZERO
	scene.yaw = yaw
	scene.smooth_yaw = yaw
	scene.pitch = pitch
	scene.smooth_pitch = pitch
	scene.world.update_cells(p)
	scene.activity.populate_near(p)
	await settle(45)
func capture() -> void:
	scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	DirAccess.make_dir_recursive_absolute(OUT)
	await settle(100)
	await shot("01-chandpole-spawn")
	await place(Vector3(0,0,30),0.0)
	await shot("02-chandpole-gate")
	scene.hud.map_open = true
	await shot("03-city-atlas-map")
	scene.hud.map_open = false
	await place(Vector3(-120,0,-900),PI*0.5)
	await shot("04-shastri-nagar-street")
	await place(Vector3(scene.world.landmarks[2].p[0],0,scene.world.landmarks[2].p[1]),PI*0.25)
	await shot("05-vidhyadhar-nagar")
	await place(Vector3(scene.world.landmarks[4].p[0],0,scene.world.landmarks[4].p[1]),PI*1.5)
	await shot("06-sikar-road")
	# Camera forward is (-sin(yaw),0,-cos(yaw)); yaw 0.83 looks south-west down the connector.
	await place(Vector3(542,0,-858),0.83,-0.1)
	await shot("07-nahargarh-game-connector")
	await place(Vector3(scene.world.landmarks[5].p[0]-30,0,scene.world.landmarks[5].p[1]+40),-1.08,-0.05)
	await shot("08-nahargarh-fort")
	await place(Vector3(scene.world.landmarks[6].p[0],0,scene.world.landmarks[6].p[1]),PI*0.5,-0.05)
	await shot("09-brahmpuri-ridge-view")
	# Real OSM amenities: look at each from the road side.
	for spec in [["police","10-panipech-police-station"],["showroom","11-car-showroom"],["hospital","12-hospital"],["theka","13-wine-shop"],["fuel","14-petrol-pump"]]:
		var pick: Dictionary={}
		for a in scene.world.amenities:
			if a.kind==spec[0] and (pick.is_empty() or a.w>pick.w):
				pick=a
		if pick.is_empty():
			continue
		var basis := Basis(Vector3.UP,pick.a)
		var front: float = pick.get("front",1)
		var at: Vector3 = Vector3(pick.p[0],0,pick.p[1])+basis*Vector3(0,0,front*(pick.d/2+14))
		var look: Vector3 = basis*Vector3(0,0,-front)
		await place(at,atan2(-look.x,-look.z),-0.1)
		await shot(spec[1])
	# The player's car up close.
	await place(scene.vehicle.position+Vector3(-5,0,3),atan2(5,-3),-0.15)
	await shot("15-player-car")
	quit()
