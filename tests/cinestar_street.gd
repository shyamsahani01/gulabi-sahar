extends SceneTree
var failures:=0
func _initialize() -> void:
	Engine.max_fps=0
	RenderingServer.render_loop_enabled=false
	call_deferred("run")
func check(ok: bool,message: String) -> void:
	if not ok:failures+=1;push_error(message)
func run() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	for i in 45:await physics_frame
	var world=scene.world
	world.set_process(false) # This probe explicitly selects the active collision cells.
	var kit=load("res://cinestar_street.gd")
	var start: Vector2=kit.START*world.CITY_COMPRESSION
	var end: Vector2=kit.END*world.CITY_COMPRESSION
	var direction:=start.direction_to(end)
	var lateral:=Vector2(-direction.y,direction.x)
	var count:=0
	for b in world.data.buildings:
		if not b.has("cinestar_street"):continue
		count+=1
		check(b.get("source","")=="infill" and not b.has("kind"),"Original named destinations remain intact")
	check(count>=3,"Visible frontage pass is present")
	check(world.get_meta("jaipur_pavement_sections",0)>0,"Walkable pavement was placed")
	check(world.get_meta("jaipur_vendor_pockets",0)>0,"Street vendors were placed")
	check(world.pedestrian_routes.size()>0,"Pavement routes were placed")
	for road in world.data.roads:
		if int(road.id)==kit.ROAD_ID:
			check(is_equal_approx(world.road_segment_width(road,0),9.0*world.CITY_COMPRESSION),"Surveyed road width applied")
			check(is_equal_approx(world.road_segment_width(road,2),road.width),"Unsurveyed road width retained")
	check(world.get_meta("jaipur_parked_scooters",0)>0,"Shoulder scooters present")
	var traffic=load("res://city_traffic.gd")
	var route={"p":[[0,0],[0,10],[0,20]],"width":8.0}
	var outward: PackedVector3Array=traffic.lane_path(route,false)
	var returning: PackedVector3Array=traffic.lane_path(route,true)
	check(outward[1].x>0 and returning[1].x<0,"Opposing traffic uses separate left-hand lanes")
	var space=scene.get_world_3d().direct_space_state
	# Sample the full block, including both junctions, at walking and vehicle body height.
	for step in range(21):
		var at:=start.lerp(end,step/20.0)
		world.update_cells(Vector3(at.x,0,at.y))
		for i in 3:await physics_frame
		for offset in [-1.5,0,1.5]:
			for height in [1.0,2.1]:
				var p0: Vector2=at-direction*2+lateral*offset
				var p1: Vector2=at+direction*2+lateral*offset
				var ray:=PhysicsRayQueryParameters3D.create(Vector3(p0.x,height,p0.y),Vector3(p1.x,height,p1.y),1)
				ray.exclude=[scene.player.get_rid()]
				check(space.intersect_ray(ray).is_empty(),"Block remains clear at sample %d, offset %.1f, height %.1f"%[step,offset,height])
	for pair in world.pedestrian_routes:
		world.update_cells(pair[0])
		for i in 3:await physics_frame
		var a: Vector3=pair[0]+Vector3.UP
		var b: Vector3=pair[1]+Vector3.UP
		var ray:=PhysicsRayQueryParameters3D.create(a,b,1)
		ray.exclude=[scene.player.get_rid()]
		check(space.intersect_ray(ray).is_empty(),"Pavement walking route clear at body height")
	var ramps: Array=world.get_meta("jaipur_driveway_ramps",[])
	check(not ramps.is_empty(),"Driveway ramps exist")
	for ramp in ramps.slice(0,3):
		var walker:=CharacterBody3D.new()
		walker.collision_layer=0;walker.collision_mask=1;walker.floor_snap_length=.4
		var capsule:=CapsuleShape3D.new();capsule.radius=.27;capsule.height=1.7
		var collision:=CollisionShape3D.new();collision.shape=capsule;collision.position.y=.85
		walker.add_child(collision);scene.add_child(walker);walker.position=ramp[0]
		world.update_cells(walker.position)
		for frame in 100:
			await physics_frame
			var toward: Vector3=ramp[1]-walker.position;toward.y=0
			walker.velocity=toward.normalized()*1.5 if toward.length()>.1 else Vector3.ZERO
			walker.velocity.y=-2
			walker.move_and_slide()
		check(Vector2(walker.position.x,walker.position.z).distance_to(Vector2(ramp[1].x,ramp[1].z))<.3,"Player-sized walker can climb driveway ramp: %s -> %s"%[walker.position,ramp[1]])
		walker.queue_free()
	check(not world.route_between(Vector3(start.x,1,start.y),Vector3(end.x,1,end.y)).is_empty(),"Both junctions remain connected")
	print("CINESTAR STREET RESULT: ",failures," failures; facades=",count," pockets=",world.get_meta("jaipur_vendor_pockets",0)," pavement=",world.get_meta("jaipur_pavement_sections",0)," routes=",world.pedestrian_routes.size())
	quit(1 if failures else 0)
