extends SceneTree
## Actual engine renders of the rebuilt Crazy Cafe and the hero's new body motion.
## Run: xvfb-run -a -s '-screen 0 1280x800x24' ./play.sh --fixed-fps 60 --script res://tests/cafe_capture.gd
const OUT := "res://designs/09-crazy-cafe/"
var scene
var camera: Camera3D
func ticks(n: int) -> void:
	for i in n:
		await physics_frame
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("run")
func shot(name: String) -> void:
	for i in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+name+".png")
	print("saved ",name)
func free_camera(from: Vector3,to: Vector3,fov := 62.0) -> void:
	camera.make_current()
	camera.fov=fov
	camera.position=from
	camera.look_at(to)
	scene.world.update_cells(from)
	scene.hud.hide()
	scene.actions.hide()
func game_camera() -> void:
	scene.pivot.get_child(0).get_child(0).make_current()
	scene.hud.show()
	scene.actions.show()
func run() -> void:
	scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	await ticks(40)
	var world: Node3D=scene.world
	var index:=-1
	for i in world.destinations().size():
		if world.destinations()[i].name.begins_with("Crazy Cafe"):
			index=i
	scene.travel_to(index)
	await ticks(60)
	var cafe: Dictionary={}
	for a in world.amenities:
		if a.get("osm_id")==-91001:
			cafe=a
	var p:=Vector3(cafe.p[0],world.terrain_height(cafe.p[0],cafe.p[1]),cafe.p[1])
	var b:=Basis(Vector3.UP,cafe.a)
	camera=Camera3D.new()
	camera.near=.1
	camera.far=720
	scene.add_child(camera)
	DirAccess.make_dir_recursive_absolute(OUT)
	# Street views of the facade and the terrace, then the interior from the doorway.
	scene.player.position=p+b*Vector3(cafe.w*.45,.2,cafe.d/2+9)
	free_camera(p+b*Vector3(-1.5,2.6,cafe.d/2+14.5),p+b*Vector3(0,3.0,cafe.d/2),58)
	await shot("01-exterior-street")
	free_camera(p+b*Vector3(cafe.w*.55,2.2,cafe.d/2+7),p+b*Vector3(cafe.w*.15,2.4,cafe.d/2),60)
	await shot("02-exterior-terrace")
	scene.player.position=p+b*Vector3(-cafe.w*.25,.95,cafe.d/2-.6)
	free_camera(p+b*Vector3(-cafe.w*.25,2.3,cafe.d/2+.3),p+b*Vector3(-cafe.w*.27,2.0,-cafe.d/2),66)
	await shot("03-interior-from-door")
	free_camera(p+b*Vector3(-cafe.w*.04-1.6,2.1,cafe.d/2-1.2),p+b*Vector3(-cafe.w*.42,1.9,-cafe.d*.1),64)
	await shot("04-interior-left-wall")
	free_camera(p+b*Vector3(-cafe.w*.42,2.0,cafe.d/2-1.5),p+b*Vector3(-cafe.w*.04,1.8,-cafe.d*.2),64)
	await shot("05-interior-booths")
	free_camera(p+b*Vector3(cafe.w*.3,2.2,cafe.d/2+2.2),p+b*Vector3(cafe.w*.23,1.9,-cafe.d*.3),60)
	await shot("06-counter-through-glass")
	# Hero sits at a booth chair; a guest sits opposite.
	var seat: Dictionary={}
	var best:=1e9
	for s in world.seats:
		if s.pose!="Sit":
			continue
		var d: float=s.p.distance_to(p+b*Vector3(-cafe.w*.12,.75,-cafe.d*.08))
		if d<best:
			best=d
			seat=s
	scene.player.position=seat.p+Vector3(0,.3,0)
	scene.player.velocity=Vector3.ZERO
	await ticks(15)
	scene.sit_toggle()
	await ticks(50)
	var forward:=Vector3(-sin(seat.yaw),0,-cos(seat.yaw))
	var side:=Vector3(forward.z,0,-forward.x)
	free_camera(seat.p+forward*2.6+side*1.6+Vector3(0,1.75,0),seat.p+Vector3(0,1.0,0)+forward*.3,50)
	await shot("07-hero-seated-booth")
	scene.touch_move=Vector2(0,-1)
	await ticks(8)
	scene.touch_move=Vector2.ZERO
	await ticks(30)
	# Conversation with the seated guest using the real game camera and HUD.
	var guest: Dictionary={}
	for q in scene.activity.patrons:
		if q.seated:
			guest=q
	scene.player.position=guest.body.position+Vector3(-sin(guest.human.rotation.y),.3,-cos(guest.human.rotation.y))*1.3
	scene.player.velocity=Vector3.ZERO
	await ticks(20)
	scene.actions.talk()
	await ticks(70)
	game_camera()
	await shot("08-talking-game-camera")
	scene.actions.directions()
	await ticks(40)
	await shot("09-hero-speaking")
	scene.actions.close_dialogue()
	await ticks(20)
	# Jump on the pavement: airborne pose and landing.
	scene.player.position=p+b*Vector3(cafe.w*.1,.2,cafe.d/2+6)
	scene.player.velocity=Vector3.ZERO
	scene.yaw=atan2(b.z.x,b.z.z)+PI
	scene.smooth_yaw=scene.yaw
	await ticks(30)
	scene.jump_requested=true
	await ticks(22)
	await shot("10-jump-airborne")
	await ticks(16)
	await shot("11-jump-landing")
	await ticks(60)
	await shot("12-cafe-street-hud")
	quit()
