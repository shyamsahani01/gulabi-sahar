extends SceneTree
## Scope, navigation, vehicle families and legacy-save migration regressions.
var failures:=0
var checks:=0
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("run")
func expect(ok: bool,message: String) -> void:
	checks+=1
	if not ok:
		failures+=1
		push_error(message)
func ticks(n: int) -> void:
	for i in n: await physics_frame
func run() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	await ticks(45)
	var w: Node3D=scene.world
	var bounds: Rect2=w.map_bounds.grow(.01)
	expect(w.map_bounds.get_area()<4200000,"Playable area is under 4.2 square km")
	expect(not bounds.has_point(Vector2.ZERO),"Chandpole is outside the playable crop")
	expect(w.landmarks.size()==5,"Only compact district destinations are present")
	for r in w.data.roads:
		for p in r.p:
			expect(bounds.has_point(Vector2(p[0],p[1])),"Road vertex stays inside crop")
	for line in w.data.navigation:
		for p in line:
			expect(bounds.has_point(Vector2(p[0],p[1])),"Navigation vertex stays inside crop")
	for poi in w.destinations():
		var p:=Vector3(poi.p[0],0,poi.p[1])
		expect(bounds.has_point(Vector2(p.x,p.z)),"Destination inside crop: "+poi.name)
		var route: PackedVector3Array=w.route_between(w.spawn_point,p)
		expect(not route.is_empty(),"Reachable from VDN spawn: "+poi.name)
	for i in w.landmarks.size():
		scene.travel_to(i)
		await ticks(55)
		expect(scene.player.is_on_floor(),"Arrival grounded: "+w.landmarks[i].name)
		var district: Dictionary=w.district_at(scene.player.position)
		expect(district.id in ["vdn","vki"],"District labels only VKI or VDN")
	# Legacy map indices must not claim new locations or resume an old fort job.
	var path:="user://city_progress.json"
	var original:=FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else ""
	var file:=FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify({"cash":735,"visited":[0,5,8],"mission_active":true,"mission_stage":2,"outfit":0}))
	file.close()
	scene.actions.load_progress()
	expect(scene.actions.cash==735,"Legacy cash retained")
	expect(scene.actions.visited.is_empty() and not scene.actions.mission_active,"Legacy map progress reset safely")
	file=FileAccess.open(path,FileAccess.WRITE)
	file.store_string(original)
	file.close()
	var heights: Dictionary={}
	for kind in ["sedan","taxi","police","suv"]:
		var car=load("res://vehicle_design.gd").new()
		car.style=kind
		root.add_child(car)
		expect(car.wheels.size()==4,kind+": four wheels")
		var mesh: ArrayMesh=car.get_child(0).mesh
		heights[kind]=mesh.get_aabb().size.y
		expect(mesh.get_surface_count()>=7,kind+": distinct glass / trim / paint / lamps")
		for i in mesh.get_surface_count():
			var arrays:=mesh.surface_get_arrays(i)
			for p in arrays[Mesh.ARRAY_VERTEX]: expect(p.is_finite(),kind+": finite mesh geometry")
		car.animate_wheels(1,.7)
		expect(absf(car.wheels[0].rotation.y)>.01 and is_zero_approx(car.wheels[1].rotation.y),kind+": only front axle steers")
		car.queue_free()
	expect(heights.suv>heights.sedan+.2,"SUV has its own taller silhouette")
	expect(heights.taxi>heights.sedan+.2,"Taxi has rounded tall cabin and roof sign")
	expect(w.palace_entry.is_empty(),"Out-of-area fort is not instantiated")
	expect(w.dining_destinations.size()==3,"Three local fictional dining interiors retained")
	print("COMPACT WORLD RESULT: ",failures," failures / ",checks," checks")
	quit(1 if failures else 0)
