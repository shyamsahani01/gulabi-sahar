extends SceneTree
## Physical access, seating, streaming and atlas travel regression checks.
var failures:=0
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("run")
func expect(ok: bool,message: String) -> void:
	if not ok:
		failures+=1
		push_error(message)
func ticks(n: int) -> void:
	for i in n: await physics_frame
func ray(scene: Node3D,a: Vector3,b: Vector3) -> Dictionary:
	return scene.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(a,b,1))
func run() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	await ticks(20)
	var world: Node3D=scene.world
	world.player_ref=null
	var expected:=0
	for a in world.amenities:
		if a.kind=="restaurant" and a.get("tags",{}).get("amenity","")!="cafe": expected+=1
	expect(world.restaurant_entries.size()==expected,"Every non-cafe restaurant has a detailed interior")
	var styles: Dictionary={}
	for entry in world.restaurant_entries:
		styles[entry.style]=true
		var p: Vector3=entry.origin
		var b: Basis=entry.basis
		world.update_cells(p)
		await ticks(2)
		for x in [-.4,0.0,.4]:
			var hit:=ray(scene,p+b*Vector3(x,1.4,entry.d/2+1.3),p+b*Vector3(x,1.4,-entry.d/2+1.6))
			expect(hit.is_empty(),"Door/central aisle obstructed: "+entry.name)
		var ground:=ray(scene,p+b*Vector3(0,1.5,0),p+b*Vector3(0,-.2,0))
		expect(not ground.is_empty() and absf(ground.position.y-p.y-entry.floor)<.035,"Restaurant floor height: %s at %s hit=%s expected=%s"%[entry.name,p,ground.get("position",Vector3.ZERO),p.y+entry.floor])
		var seats:=0
		for seat in world.seats:
			var local: Vector3=b.inverse()*(seat.p-p)
			if absf(local.x)<entry.w/2 and absf(local.z)<entry.d/2 and absf(local.y-entry.floor)<.05: seats+=1
		expect(seats>=2,"Usable restaurant seats: "+entry.name)
	expect(styles.size()==3,"Three distinct restaurant families")
	var palace: Dictionary=world.palace_entry
	var p: Vector3=palace.origin
	var b: Basis=palace.basis
	world.update_cells(p)
	await ticks(3)
	for x in [-1.0,0.0,1.0]:
		expect(ray(scene,p+b*Vector3(x,1.5,28),p+b*Vector3(x,1.5,6)).is_empty(),"Palace gate opens into courtyard")
	for x in [-6.0,6.0]:
		var floor_hit:=ray(scene,p+b*Vector3(x,2,8),p+b*Vector3(x,-.2,8))
		expect(not floor_hit.is_empty() and absf(floor_hit.position.y-p.y-palace.floor)<.04,"Palace courtyard is grounded")
	expect(not ray(scene,p+b*Vector3(0,.3,4),p+b*Vector3(0,.3,0)).is_empty(),"Fountain has collision")
	expect(world.dining_destinations.size()==3,"Dining destinations registered")
	scene.hud.dining_tab=true
	expect(scene.hud.atlas_entries().size()==3,"DINING tab exposes the three reviewed places")
	expect(scene.hud.atlas_offset()==world.landmarks.size()+world.services.size(),"Dining selection uses correct travel index")
	world.player_ref=scene.player
	# Real character walks from the atlas arrival through each reviewed doorway.
	for i in world.dining_destinations.size():
		scene.travel_to(world.landmarks.size()+world.services.size()+i)
		await ticks(70)
		expect(scene.player.is_on_floor(),"Dining arrival lands on ground")
		scene.touch_move=Vector2(0,-1)
		await ticks(110)
		scene.touch_move=Vector2.ZERO
		await ticks(10)
		var entry: Dictionary={}
		for q in world.restaurant_entries:
			if q.name==world.dining_destinations[i].name: entry=q
		var local: Vector3=entry.basis.inverse()*(scene.player.position-entry.origin)
		print("WALK ",entry.name," local=",local," floor=",scene.player.is_on_floor())
		expect(local.z<entry.d/2-.4 and local.z>-entry.d/2 and scene.player.is_on_floor(),"Player walks into "+entry.name)
	# Exercise the touch route, including switching away from and back to DINING.
	scene.hud.map_open=true
	var tap:=InputEventScreenTouch.new()
	tap.pressed=true
	tap.index=9
	tap.position=Vector2(scene.hud.size.x-282+74+35,105)
	scene.hud._input(tap)
	expect(scene.hud.services_tab and not scene.hud.dining_tab,"Services tab clears dining selection")
	tap.position=Vector2(scene.hud.size.x-282+148+35,105)
	scene.hud._input(tap)
	expect(scene.hud.dining_tab and not scene.hud.services_tab,"Dining tab touch selects restaurants")
	tap.position=Vector2(scene.hud.size.x-220,160)
	scene.hud._input(tap)
	var destination: Dictionary=world.dining_destinations[0]
	expect(not scene.hud.map_open and Vector2(scene.player.position.x,scene.player.position.z).distance_to(Vector2(destination.p[0],destination.p[1]))<.1,"Dining row touch travels to the right entrance")
	# The palace ramp must also carry the player, not just a clear ray.
	scene.player.position=p+b*Vector3(0,.4,27)
	scene.player.velocity=Vector3.ZERO
	scene.yaw=-PI/2
	scene.smooth_yaw=scene.yaw
	world.update_cells(scene.player.position)
	await ticks(40)
	scene.touch_move=Vector2(0,-1)
	await ticks(120)
	scene.touch_move=Vector2.ZERO
	await ticks(10)
	var palace_local: Vector3=b.inverse()*(scene.player.position-p)
	expect(palace_local.z<23 and scene.player.is_on_floor(),"Player walks through palace gate into courtyard")
	print("ARCHITECTURE REVIEW: ",failures," failures; restaurants=",expected," styles=",styles.size())
	quit(1 if failures else 0)
