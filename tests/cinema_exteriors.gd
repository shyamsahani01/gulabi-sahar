extends SceneTree
var failures:=0
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("run")
func check(ok: bool,message: String) -> void:
	if not ok:failures+=1;push_error(message)
func run() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	for i in 45:await physics_frame
	var world=scene.world
	var original: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/vki_vdn_city.json"))
	for b in original.buildings:
		if b.get("source","")=="infill":continue
		check(world.data.buildings.any(func(item):return item.get("osm_id",0)==b.get("osm_id",0)),"Imported building retained")
	check(world.data.roads.size()==original.roads.size(),"Original streets retained")
	await check_place(scene,"Cinestar",[374923169,1210939418,261520115])
	await check_place(scene,"Funstar",[1210908405,931378210,931378209,261520097,463584272])
	print("CINEMA EXTERIORS RESULT: ",failures," failures")
	quit(1 if failures else 0)

func check_place(scene: Node,name: String,road_ids: Array) -> void:
	var world=scene.world
	var atlas=scene.hud.atlas
	atlas.search.text=name
	atlas.refresh_results()
	check(atlas.filtered.size()==1,name+" has one searchable destination")
	if atlas.filtered.size()!=1:return
	var a: Dictionary=atlas.filtered[0]
	scene.travel_to_map_entry(a)
	for i in 60:await physics_frame
	check(scene.player.is_on_floor(),"Cinema travel lands on ground")
	check(world.clear_arrival(Vector2(scene.player.position.x,scene.player.position.z),.4),"Cinema travel is clear of buildings")
	check(not world.route_between(world.spawn_point,scene.player.position).is_empty(),"Cinema has a connected route")
	var at:=Vector3(a.p[0],0,a.p[1])
	var facing:=Basis(Vector3.UP,a.a+(PI if a.get("front",1)<0 else 0))
	world.update_cells(at)
	for i in 4:await physics_frame
	var space=scene.get_world_3d().direct_space_state
	var ray:=PhysicsRayQueryParameters3D.create(at+facing*Vector3(0,1.7,a.d/2+2),at+facing*Vector3(0,1.7,a.d/2-2),1)
	ray.exclude=[scene.player.get_rid()]
	check(space.intersect_ray(ray).is_empty(),"Central cinema doorway is open")
	for road in world.data.roads:
		if int(road.get("id",0)) not in road_ids:continue
		for i in range(road.p.size()-1):
			var start:=Vector2(road.p[i][0],road.p[i][1])
			var end:=Vector2(road.p[i+1][0],road.p[i+1][1])
			var near:=Geometry2D.get_closest_point_to_segment(Vector2(at.x,at.z),start,end)
			if near.distance_to(Vector2(at.x,at.z))>25:continue
			var direction:=start.direction_to(end)
			for offset in [-.7,0,.7]:
				var lateral: Vector2=Vector2(-direction.y,direction.x)*offset
				var p0: Vector2=Geometry2D.get_closest_point_to_segment(near-direction*4,start,end)+lateral
				var p1: Vector2=Geometry2D.get_closest_point_to_segment(near+direction*4,start,end)+lateral
				ray=PhysicsRayQueryParameters3D.create(Vector3(p0.x,1,p0.y),Vector3(p1.x,1,p1.y),1)
				ray.exclude=[scene.player.get_rid()]
				check(space.intersect_ray(ray).is_empty(),"Cinema frontage leaves nearby street/footway clear: "+str(road.id))
