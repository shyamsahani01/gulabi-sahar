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
	check(world.get_meta("cinestar_street_pockets",0)>0,"Street pockets were placed")
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
	check(not world.route_between(Vector3(start.x,1,start.y),Vector3(end.x,1,end.y)).is_empty(),"Both junctions remain connected")
	print("CINESTAR STREET RESULT: ",failures," failures; facades=",count," pockets=",world.get_meta("cinestar_street_pockets",0))
	quit(1 if failures else 0)
