extends SceneTree
var failures:=0
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("run")
func expect(ok: bool, message: String) -> void:
	if not ok: failures+=1; push_error(message)
func ticks(count: int) -> void:
	for i in count: await physics_frame
func run() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	await ticks(65)
	var atlas=scene.hud.atlas
	scene.hud.map_open=true
	await process_frame
	for i in 5: await process_frame
	expect(atlas.go.global_position.y+atlas.go.size.y<=scene.hud.size.y,"Travel buttons stay within visible viewport")
	atlas.search.text="theka"
	atlas.refresh_results()
	var wines: int=scene.world.amenities.filter(func(a):return a.kind=="theka").size()+scene.world.services.filter(func(a):return a.kind=="theka").size()
	expect(atlas.filtered.size()==wines and wines>1,"Every available wine shop appears, not a category singleton")
	var before: Vector3=scene.player.position
	atlas.select_entry(atlas.filtered[0])
	expect(scene.player.position==before and scene.hud.map_open,"Selecting previews without teleporting")
	atlas.show_route()
	expect(scene.hud.has_waypoint,"Route selection creates waypoint")
	# Exercise the native GUI click path; Android OS touch emulation is enabled.
	expect(Input.emulate_mouse_from_touch,"Native widgets enable platform touch-to-mouse input")
	var tap:=InputEventMouseButton.new()
	tap.button_index=MOUSE_BUTTON_LEFT
	tap.position=atlas.go.global_position+atlas.go.size/2
	tap.pressed=true
	root.push_input(tap,true)
	await process_frame
	tap=tap.duplicate()
	tap.pressed=false
	root.push_input(tap,true)
	await ticks(60)
	expect(scene.player.is_on_floor(),"Place travel lands on solid ground")
	expect(not scene.hud.map_open,"GO closes atlas")
	scene.hud.map_open=true
	await process_frame
	atlas.search.text=""
	atlas.category.selected=1
	atlas.refresh_results()
	expect(atlas.filtered.size()==scene.world.data.roads.size(),"All road segments including unnamed gali are searchable")
	atlas.select_entry(atlas.filtered[0])
	var anchor: Vector2=atlas.canvas.size/2
	var world_before: Vector2=atlas.unpoint(anchor)
	atlas.zoom_at(32,anchor)
	expect(is_equal_approx(atlas.zoom,32),"Street-level 32x zoom available")
	expect(atlas.unpoint(anchor).distance_to(world_before)<.01,"Zoom preserves its anchor")
	atlas.travel()
	await ticks(60)
	expect(scene.player.is_on_floor(),"Street travel lands on ground")
	atlas.search.text="no-such-place-zzzz"
	atlas.refresh_results()
	expect(atlas.filtered.is_empty() and atlas.go.disabled,"Empty search disables travel")
	scene.player.position=scene.vehicle.position+Vector3(2.2,0,0)
	scene.vehicle.toggle_drive()
	await ticks(35)
	expect(scene.vehicle.driving and scene.avatar.visible,"Hero stays visible after entering car")
	expect(scene.avatar.action=="Drive","Dedicated seated driving pose")
	var local: Vector3=scene.vehicle.to_local(scene.avatar.global_position)
	expect(local.distance_to(Vector3(.39,.08,.02))<.03,"Driver follows right-hand seat")
	scene.vehicle.heading+=1.2
	await ticks(5)
	expect(scene.vehicle.to_local(scene.avatar.global_position).distance_to(local)<.03,"Driver rotates with vehicle")
	scene.hud.context_clock=0
	scene.hud._process(.3)
	expect(scene.hud.context_actions==["ride"],"Driving hides walking/combat interactions")
	scene.travel_to(0)
	await ticks(60)
	expect(not scene.vehicle.driving and scene.avatar.position==Vector3.ZERO,"Travel while driving restores standing transform")
	expect(scene.player.collision_layer==1 and scene.avatar.action!="Drive","Player collisions and animation restored")
	var pilot:=0
	for b in scene.world.data.buildings:
		if b.has("street_pilot"): pilot+=1
	expect(pilot>0 and pilot<40,"First street pilot stays geographically scoped")
	print("MAP / DRIVER RESULT: ",failures," failures; ",wines," wine shops; ",pilot," pilot footprints")
	quit(1 if failures else 0)
