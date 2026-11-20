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
	var world: Node3D=scene.world
	var original: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/vki_vdn_city_small.json"))
	var a: Dictionary={}
	for item in world.amenities:
		if item.get("sector2_design","")=="rose_tower":a=item
	check(not a.is_empty(),"Featured tower exists on the intended original clinic plot")
	for existing in original.amenities:
		check(world.amenities.any(func(item):return item.osm_id==existing.osm_id),"Original amenity retained")
	check(world.data.roads.size()==original.roads.size(),"Road segment count preserved")
	var atlas=scene.hud.atlas
	atlas.search.text="Sector 2"
	atlas.refresh_results()
	check(atlas.filtered.size()==1,"Sector 2 is searchable as its own road")
	if not atlas.filtered.is_empty():
		var entry: Dictionary=atlas.filtered[0]
		check(int(entry.id)==261520097,"Sector 2 selection retains correct OSM road ID")
		var arrival: Dictionary=scene.map_arrival(entry)
		check(world.clear_arrival(arrival.p,.6),"Street travel arrival is clear of buildings")
		scene.travel_to_map_entry(entry)
		for i in 60:await physics_frame
		check(scene.player.is_on_floor(),"Sector 2 street travel lands on solid ground")
		check(not world.route_between(world.spawn_point,scene.player.position).is_empty(),"Sector 2 remains connected to spawn")
	var facing:=Basis(Vector3.UP,a.a)
	var at:=Vector3(a.p[0],0,a.p[1])
	world.update_cells(at)
	for i in 4:await physics_frame
	var space=scene.get_world_3d().direct_space_state
	var ray:=PhysicsRayQueryParameters3D.create(at+facing*Vector3(0,1.4,a.d/2+3),at+facing*Vector3(0,1.4,-a.d/2+1),1)
	ray.exclude=[scene.player.get_rid()]
	check(space.intersect_ray(ray).is_empty(),"Tower ground-floor central entrance and passage remain open")
	for road in world.data.roads:
		if int(road.get("id",0)) not in [261520097,278200313]:continue
		for i in range(road.p.size()-1):
			var p0:=Vector3(road.p[i][0],1.0,road.p[i][1])
			var p1:=Vector3(road.p[i+1][0],1.0,road.p[i+1][1])
			if p0.distance_to(at)>90 or p1.distance_to(at)>140:continue
			ray=PhysicsRayQueryParameters3D.create(p0,p1,1)
			ray.exclude=[scene.player.get_rid()]
			check(space.intersect_ray(ray).is_empty(),"Carriageway remains free of new walls or street props")
	print("SECTOR 2 RESULT: ",failures," failures")
	quit(1 if failures else 0)
