extends SceneTree
var failures:=0
var samples: Array=[]
var loader: CanvasLayer
var capture := false
var captured := {}
func _initialize() -> void:
	capture="--capture" in OS.get_cmdline_user_args()
	call_deferred("run")
func expect(ok: bool,message: String) -> void:
	if not ok:failures+=1;push_error(message)
func observe(value: float,label: String) -> void:
	if not samples.is_empty():expect(value>=samples[-1][0],"Progress never moves backwards")
	samples.append([value,label])
func snapshot(name0: String) -> void:
	if not capture or captured.has(name0):return
	captured[name0]=true
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://designs/22-startup-and-smaller-map/"+name0+".png")
func run() -> void:
	var old_fps:=Engine.max_fps
	expect(ProjectSettings.get_setting("application/run/main_scene")=="res://startup.tscn","Default entry shows loader")
	loader=load("res://startup.tscn").instantiate()
	loader.loading_changed.connect(observe)
	root.add_child(loader)
	var deadline:=Time.get_ticks_msec()+120000
	var frames:=0
	while is_instance_valid(loader) and Time.get_ticks_msec()<deadline:
		frames+=1
		if loader.fraction<.15:await snapshot("loading-resources")
		if loader.fraction>.38 and loader.fraction<.72:await snapshot("loading-city")
		if loader.game!=null and not loader.finishing:
			expect(loader.game.process_mode==Node.PROCESS_MODE_DISABLED,"Gameplay cannot run during construction")
		await process_frame
	expect(not is_instance_valid(loader),"Loader hands over without timeout")
	if is_instance_valid(loader):quit(1);return
	var game:=current_scene
	expect(game!=null and game.startup_finished and game.world.build_finished,"Complete world and player before handover")
	expect(frames>20 and samples.size()>15,"Overlay gets frames and real stage updates")
	expect(Engine.max_fps==old_fps,"Gameplay frame cap restored")
	expect(not root.disable_3d,"3D rendering resumes")
	expect(samples[-1][0]==1.0,"Finished progress reaches 100 percent")
	for i in 90:await physics_frame
	expect(game.player.is_on_floor(),"Player lands on optimized flat terrain")
	expect(game.activity.people.size()>6,"Residents are present at first playable frame")
	expect(game.world.map_bounds.get_area()<3000000,"Playable map below 3 square km")
	var atlas=game.hud.atlas
	for query in ["cinema","college","school","park"]:
		atlas.search.text=query
		atlas.refresh_results()
		expect(not atlas.filtered.is_empty(),"Searchable destination: "+query)
	expect(game.world.seats.any(func(s):return s.get("park",false)),"Park benches can be used")
	for key in ["stone","concrete","tarmac","grass"]:
		expect(game.world.mats[key].normal_enabled and game.world.mats[key].roughness_texture!=null,"PBR surface retained: "+key)
	await snapshot("first-playable-view")
	var file:=FileAccess.open("res://designs/22-startup-and-smaller-map/startup-profile.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(game.get_meta("startup_timing"),"  "))
	game.queue_free()
	await process_frame
	# Failure leaves a readable retry UI and never creates a partially live game.
	var bad=load("res://startup.tscn").instantiate()
	bad.game_scene_path="res://missing-startup-test.tscn"
	root.add_child(bad)
	for i in 8:await process_frame
	expect(bad.failed and bad.retry.visible and bad.game==null,"Missing resource shows retry, not a blank screen")
	bad.queue_free()
	await process_frame
	print("STARTUP TEST RESULT: ",failures," failures; ",samples.size()," progress events")
	quit(1 if failures else 0)
