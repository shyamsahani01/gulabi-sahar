extends SceneTree
var failures:=0
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("check")
func expect(value: bool,label: String) -> void:
	if not value:
		failures+=1
		push_error(label)
func ticks(n: int) -> void:
	for i in n:
		await physics_frame
func check() -> void:
	var began:=Time.get_ticks_msec()
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	print("WORLD READY ",Time.get_ticks_msec()-began," ms; cells ",scene.world.cells.size()," buildings ",scene.world.building_count)
	await ticks(90)
	expect(scene.player.is_on_floor(),"Player lands at Chandpole")
	expect(scene.world.building_count>5000,"Substantial city population of buildings")
	expect(scene.world.data.roads.size()>4000,"OSM road network loaded")
	expect(scene.world.active_cells<scene.world.cells.size()/2,"Distance culling limits active city")
	expect(scene.activity.people.size()>6,"Pedestrians spawn near player")
	var origin: Vector3=scene.player.position
	scene.touch_move=Vector2(1,0)
	await ticks(45)
	scene.touch_move=Vector2.ZERO
	expect(scene.player.position.distance_to(origin)>1,"Analog movement works")
	await ticks(20)
	expect(Vector2(scene.player.velocity.x,scene.player.velocity.z).length()<.05,"Movement brakes to a stop")
	scene.jump_requested=true
	await ticks(8)
	expect(scene.player.position.y>origin.y+.3,"Buffered jump lifts player")
	await ticks(70)
	expect(scene.player.is_on_floor(),"Jump returns to ground")
	var hero: Node3D=scene.avatar
	for name in ["Jab","Cross","Kick","Dodge","Jump","Hit","Guard"]:
		expect(hero.animator.has_animation("action/"+name),"Skeletal action exists: "+name)
	var bone: int=hero.bones["upperarm_l"]
	hero.play_action("Jab")
	hero.animator.advance(0.22)
	var pose: Quaternion=hero.skeleton.get_bone_pose_rotation(bone)
	hero.animator.advance(.24)
	expect(pose.angle_to(hero.skeleton.get_bone_pose_rotation(bone))>.05,"Punch actually animates the arm")
	await ticks(40)
	expect(hero.animation_tree.active,"Locomotion blending resumes after action")
	for index in [2,5,0]:
		scene.travel_to(index)
		await ticks(90)
		expect(scene.player.is_on_floor(),"Destination %d has solid ground"%index)
		expect(scene.player.position.y>-1,"Destination does not fall through terrain")
	var route: PackedVector3Array=scene.world.route_between(Vector3.ZERO,Vector3(scene.world.landmarks[2].p[0],0,scene.world.landmarks[2].p[1]))
	print("ROUTE points ",route.size())
	expect(route.size()>2,"Chandpole to VDN has connected road navigation")
	expect(scene.world.authored_roads.size()==1 and scene.world.authored_roads[0].source=="authored","Exactly one authored game connector is tagged in the data")
	var fort: PackedVector3Array=scene.world.route_between(Vector3.ZERO,Vector3(scene.world.landmarks[5].p[0],0,scene.world.landmarks[5].p[1]))
	var uses_connector:=false
	for p in fort:
		if Vector2(p.x,p.z).distance_to(Vector2(500,-896)*scene.world.CITY_COMPRESSION)<40:
			uses_connector=true
	expect(fort.size()>2 and uses_connector,"Nahargarh route reaches the fort through the marked game connector")
	expect(scene.world.data.roads.filter(func(r):return r.get("source","osm")=="osm" or not r.has("source")).size()>4000,"Everything else in the road network comes from OSM")
	var kinds: Dictionary={}
	for a in scene.world.amenities:
		kinds[a.kind]=kinds.get(a.kind,0)+1
	print("AMENITIES ",kinds)
	expect(scene.world.amenities.size()>200 and scene.world.amenity_count>200,"Real OSM amenities are loaded and built")
	expect(kinds.get("police",0)>=2 and kinds.get("showroom",0)>=3 and kinds.get("theka",0)>=5 and kinds.get("hospital",0)>=20 and kinds.get("fuel",0)>=5,"Police stations, car showrooms, wine shops, hospitals and petrol pumps exist")
	expect(scene.world.map_bounds.has_point(Vector2(-2350,-4750)*scene.world.CITY_COMPRESSION),"Expanded playable bounds include VKI south")
	expect(scene.vehicle.wheels.size()==4 and scene.vehicle.body_mesh.get_child(0).mesh.get_surface_count()>=5,"Player car has a detailed body")
	scene.vehicle.position=scene.player.position+Vector3(3,0,0)
	scene.vehicle.toggle_drive()
	expect(scene.vehicle.driving,"Player can enter car")
	scene.touch_move=Vector2(0,-1)
	await ticks(60)
	scene.touch_move=Vector2.ZERO
	expect(scene.vehicle.speed>1,"Vehicle accelerates")
	scene.vehicle.toggle_drive()
	expect(not scene.vehicle.driving and scene.avatar.visible,"Player can leave car")
	print("CITY SMOKE RESULT: ",failures," failures; elapsed ",Time.get_ticks_msec()-began," ms")
	quit(1 if failures else 0)
