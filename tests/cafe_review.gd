extends SceneTree
var failures:=0
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("check")
func check() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	for i in 20:
		await physics_frame
	var world: Node3D=scene.world
	var vki: Vector3=Vector3(-2350,0,-4750)*world.CITY_COMPRESSION
	if world.route_between(Vector3.ZERO,vki).size()<2:
		push_error("VKI road network disconnected")
		failures+=1
	if world.district_at(vki).id != "vki":
		push_error("VKI district identification missing")
		failures+=1
	var cafe: Dictionary={}
	for a in world.amenities:
		if a.get("osm_id")==-91001:
			cafe=a
	if cafe.is_empty():
		push_error("Crazy Cafe missing")
		quit(1)
		return
	var p:=Vector3(cafe.p[0],world.terrain_height(cafe.p[0],cafe.p[1]),cafe.p[1])
	world.update_cells(p)
	for i in 5:
		await physics_frame
	for offset in [0.0,.35,-.35]:
		var x: float=-cafe.w*.25+offset
		var query:=PhysicsRayQueryParameters3D.create(p+Vector3(x,1.8,cafe.d/2+2.6),p+Vector3(x,1.8,cafe.d/2-1.3),1)
		if not scene.get_world_3d().direct_space_state.intersect_ray(query).is_empty():
			push_error("Cafe approach/doorway obstructed")
			failures+=1
	var floor_ray:=PhysicsRayQueryParameters3D.create(p+Vector3(-cafe.w*.25,2,0),p+Vector3(-cafe.w*.25,-1,0),1)
	var hit: Dictionary=scene.get_world_3d().direct_space_state.intersect_ray(floor_ray)
	if hit.is_empty() or absf(hit.position.y-p.y-.75)>.05:
		push_error("Cafe raised interior floor missing")
		failures+=1
	if DisplayServer.get_name()=="headless":
		# The ramp must actually carry the player through the left doorway.
		scene.player.position=p+Vector3(-cafe.w*.25,.15,cafe.d/2+2.9)
		scene.player.velocity=Vector3.ZERO
		scene.yaw=0
		scene.smooth_yaw=0
		scene.touch_move=Vector2(0,-1)
		for i in 140:
			await physics_frame
		scene.touch_move=Vector2.ZERO
		if scene.player.position.z>p.z+cafe.d/2-.5 or not scene.player.is_on_floor():
			push_error("Player cannot walk up cafe steps into interior")
			failures+=1
	var hospital: Dictionary={}
	for a in world.amenities:
		if a.name=="Shri Ram Hospital" and a.get("area","")=="VKI south":
			hospital=a
	var hp:=Vector3(hospital.p[0],world.terrain_height(hospital.p[0],hospital.p[1]),hospital.p[1])
	var hb:=Basis(Vector3.UP,hospital.a+(PI if hospital.get("front",1)<0 else 0))
	world.update_cells(hp)
	for i in 3:
		await physics_frame
	var entry:=PhysicsRayQueryParameters3D.create(hp+hb*Vector3(0,1.5,hospital.d*.28+2.6),hp+hb*Vector3(0,1.5,hospital.d*.28-2),1)
	if not scene.get_world_3d().direct_space_state.intersect_ray(entry).is_empty():
		push_error("Hospital reception entrance obstructed")
		failures+=1
	if not DisplayServer.get_name()=="headless":
		scene.hud.hide()
		var camera:=Camera3D.new()
		scene.add_child(camera)
		camera.make_current()
		world.player_ref=camera
		camera.fov=65
		DirAccess.make_dir_recursive_absolute("res://designs/08-cafe-hospital")
		for view in [["exterior",Vector3(4,3.2,16),Vector3(0,2.7,2)],["interior",Vector3(-cafe.w*.25,2.25,3.3),Vector3(-cafe.w*.25,2.0,-4)]]:
			camera.position=p+view[1]
			camera.look_at(p+view[2])
			world.update_cells(camera.position)
			for i in 8:
				await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://designs/08-cafe-hospital/"+view[0]+".png")
		camera.position=hp+hb*Vector3(hospital.w*.65,7,hospital.d*.28+25)
		camera.look_at(hp+Vector3(0,5,0))
		world.update_cells(hp)
		for i in 10:
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://designs/08-cafe-hospital/hospital.png")
	print("CAFE REVIEW RESULT: ",failures," failures")
	quit(1 if failures else 0)
