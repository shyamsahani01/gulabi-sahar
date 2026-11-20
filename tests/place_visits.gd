extends SceneTree
var failures:=0
var capture:=false
func _initialize() -> void:
	Engine.max_fps=0
	capture="--capture" in OS.get_cmdline_user_args()
	if capture:RenderingServer.render_loop_enabled=false
	call_deferred("run")
func expect(ok: bool,message: String) -> void:
	if not ok:failures+=1;push_error(message)
func ticks(n: int) -> void:
	for i in n:await physics_frame
func photo(scene: Node,at: Vector3,target: Vector3,name0: String) -> void:
	if not capture:return
	var camera:=Camera3D.new()
	scene.add_child(camera)
	camera.position=at
	camera.look_at(target)
	camera.fov=65
	camera.make_current()
	RenderingServer.render_loop_enabled=true
	for i in 3:await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://designs/22-startup-and-smaller-map/"+name0+".png")
	RenderingServer.render_loop_enabled=false
	camera.queue_free()
func run() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	await ticks(45)
	var w=scene.world
	var visits=scene.visits
	expect(w.place_interactions.filter(func(a):return a.kind=="school").size()==3,"Three distinct campuses; shared college records do not stack buildings")
	for a in w.amenities:
		if a.kind!="school" or a.has("shared_campus"):continue
		var origin:=Vector3(a.p[0],0,a.p[1])
		var basis:=Basis(Vector3.UP,a.a+(PI if a.get("front",1)<0 else 0))
		scene.player.position=origin+basis*Vector3(0,1,a.d*.48)
		w.update_cells(origin)
		await ticks(4)
		var ray:=PhysicsRayQueryParameters3D.create(origin+basis*Vector3(0,1.5,a.d*.5+1),origin+basis*Vector3(0,1.5,-a.d*.25),1)
		ray.exclude=[scene.player.get_rid()]
		expect(scene.get_world_3d().direct_space_state.intersect_ray(ray).is_empty(),"Open gate and reception path: "+a.name)
		var place: Dictionary=w.place_interactions.filter(func(p):return p.name==a.name)[0]
		scene.player.position=place.p+Vector3(0,.1,0)
		scene.player.velocity=Vector3.ZERO
		visits.open()
		expect(visits.visible and scene.hud.modal,"Campus visit opens nearby")
		visits.perform()
		expect(visits.visited.has(a.name),"Physical campus visit recorded")
		visits.close()
		if "college" in a.name:
			scene.hud.hide()
			scene.actions.hide()
			await photo(scene,origin+basis*Vector3(-a.w*.55,7,a.d*1.2),origin+Vector3(0,3,0),"college-courtyard")
			scene.hud.show()
			scene.actions.show()
	var hospital: Dictionary=w.place_interactions.filter(func(p):return p.name=="Sahar Hospital")[0]
	scene.player.position=hospital.p+Vector3(0,.2,0)
	scene.player.velocity=Vector3.ZERO
	w.update_cells(scene.player.position)
	await ticks(8)
	var wallet: int=scene.actions.cash
	scene.actions.health=40
	scene.stamina=30
	visits.open()
	expect(visits.visible and scene.actions.dialogue_open,"Walk-up hospital reception is interactive")
	visits.perform()
	expect(scene.actions.health==100 and scene.stamina==100 and scene.actions.cash==wallet-25,"Care restores health and charges exactly once")
	visits.perform()
	expect(scene.actions.cash==wallet-25,"Repeated input cannot charge for full health")
	visits.close()
	scene.actions.health=40
	scene.actions.cash=0
	visits.open()
	visits.perform()
	expect(scene.actions.health==40 and scene.actions.cash==0,"Insufficient funds cannot buy care")
	visits.close()
	scene.actions.cash=wallet
	scene.actions.health=100
	scene.actions.save_progress()
	scene.player.position=w.spawn_point
	visits.open()
	expect(not visits.visible,"Cannot interact remotely from spawn")
	var bench: Dictionary=w.seats.filter(func(s):return s.get("park",false))[0]
	scene.player.position=bench.p+Vector3(0,.5,-.7)
	w.update_cells(scene.player.position)
	await ticks(40)
	scene.sit_toggle()
	expect(not scene.seated.is_empty(),"Park bench supports sit action")
	scene.sit_toggle()
	expect(scene.seated.is_empty() and scene.player.collision_layer==1,"Standing restores player collision")
	print("PLACE VISITS RESULT: ",failures," failures")
	quit(1 if failures else 0)
