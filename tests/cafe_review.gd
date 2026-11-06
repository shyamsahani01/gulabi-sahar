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
		push_error("Crazy Coffee missing")
		quit(1)
		return
	var p:=Vector3(cafe.p[0],world.terrain_height(cafe.p[0],cafe.p[1]),cafe.p[1])
	world.update_cells(p)
	for i in 5:
		await physics_frame
	for x in [0.0,.6,-.6]:
		var query:=PhysicsRayQueryParameters3D.create(p+Vector3(x,1.4,cafe.d/2+1.9),p+Vector3(x,1.4,cafe.d/2-1.3),1)
		if not scene.get_world_3d().direct_space_state.intersect_ray(query).is_empty():
			push_error("Cafe approach/doorway obstructed")
			failures+=1
	var floor_ray:=PhysicsRayQueryParameters3D.create(p+Vector3(0,2,0),p+Vector3(0,-1,0),1)
	var hit: Dictionary=scene.get_world_3d().direct_space_state.intersect_ray(floor_ray)
	if hit.is_empty() or absf(hit.position.y-p.y-.45)>.05:
		push_error("Cafe raised interior floor missing")
		failures+=1
	if not DisplayServer.get_name()=="headless":
		scene.hud.hide()
		var camera:=Camera3D.new()
		scene.add_child(camera)
		camera.make_current()
		world.player_ref=camera
		camera.fov=65
		DirAccess.make_dir_recursive_absolute("res://designs/07-vki-vdn")
		for view in [["exterior",Vector3(11,6,18),Vector3(0,2.1,2)],["interior",Vector3(0,2.1,3.7),Vector3(.4,1.8,-4)]]:
			camera.position=p+view[1]
			camera.look_at(p+view[2])
			for i in 8:
				await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://designs/07-vki-vdn/"+view[0]+".png")
	print("CAFE REVIEW RESULT: ",failures," failures")
	quit(1 if failures else 0)
