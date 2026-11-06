extends SceneTree
var failures := 0
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("check")
func expect(ok: bool, message: String) -> void:
	if not ok:
		failures+=1
		push_error(message)
func ticks(n: int) -> void:
	for i in n:
		await physics_frame
func check() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	await ticks(50)
	var world: Node3D=scene.world
	expect(is_equal_approx(world.map_bounds.size.x,4400),"Playable map is 12% shorter")
	expect(world.services.size()==6,"Six authored city services exist")
	# Rotated rectangular batches must stay orthogonal, matching the box colliders.
	var checked := 0
	for c in world.cells.values():
		for child in c.get_children():
			if child is MultiMeshInstance3D and child.multimesh.instance_count>0:
				var basis: Basis=child.multimesh.get_instance_transform(0).basis
				expect(absf(basis.x.normalized().dot(basis.z.normalized()))<.001,"Rendered wall is not sheared relative to collision")
				checked+=1
	expect(checked>100,"Building batch geometry was inspected")
	var kinds: Array=[]
	for i in world.services.size():
		var service: Dictionary=world.services[i]
		kinds.append(service.kind)
		scene.travel_to(world.landmarks.size()+i)
		await ticks(45)
		expect(scene.player.is_on_floor(),service.kind+": travel lands on solid ground")
		expect(scene.vehicle.is_on_floor(),service.kind+": car lands on the mapped road")
		var basis:=Basis(Vector3.UP,service.rotation)
		var entrance:=Vector3(service.p[0],world.terrain_height(service.p[0],service.p[1]),service.p[1])
		var ray:=PhysicsRayQueryParameters3D.create(entrance+Vector3.UP,entrance-basis.z*2.8+Vector3.UP,1)
		ray.exclude=[scene.player.get_rid()]
		expect(scene.get_world_3d().direct_space_state.intersect_ray(ray).is_empty(),service.kind+": doorway is clear")
		scene.player.position=entrance+Vector3(0,.3,0)
		scene.touch_move=Vector2(0,-1)
		await ticks(75)
		scene.touch_move=Vector2.ZERO
		expect((scene.player.position-entrance).dot(-basis.z)>2.0,service.kind+": player can walk through entrance")
		expect(scene.player.is_on_floor(),service.kind+": interior supports player")
	for kind in ["showroom","hospital","police","theka","grocery","chai"]:
		expect(kinds.has(kind),"Required service: "+kind)
	var vehicle: Node3D=scene.vehicle
	expect(vehicle.design.wheels.size()==4,"Vehicle has four animated wheel assemblies")
	var before: float=vehicle.design.wheels[0].get_child(0).rotation.x
	vehicle.design.animate_wheels(1,.5)
	expect(absf(vehicle.design.wheels[0].get_child(0).rotation.x-before)>.1,"Wheel rolls with distance")
	expect(absf(vehicle.design.wheels[0].rotation.y)>.01,"Front wheels visibly steer")
	expect(is_zero_approx(vehicle.design.wheels[1].rotation.y),"Rear wheels do not steer")
	# Services-tab touch must use the service index, not the district underneath it.
	scene.hud.map_open=true
	scene.hud.services_tab=true
	var event:=InputEventScreenTouch.new()
	event.index=9
	event.pressed=true
	event.position=Vector2(scene.hud.size.x-220,160)
	scene.hud._input(event)
	expect(not scene.hud.map_open,"Service selection closes atlas")
	var target: Dictionary=world.services[0]
	expect(Vector2(scene.player.position.x,scene.player.position.z).distance_to(Vector2(target.p[0],target.p[1]))<1,"Service touch travels to showroom")
	print("CITY REFRESH RESULT: ",failures," failures")
	quit(1 if failures else 0)
