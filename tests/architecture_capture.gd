extends SceneTree
## Render the actual streamed city, with repeatable before/after camera positions.
const OUT := "res://designs/13-architecture/"
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("run")
func run() -> void:
	var world=load("res://city_world.gd").new()
	root.add_child(world)
	var camera:=Camera3D.new()
	root.add_child(camera)
	camera.make_current()
	camera.far=750
	world.player_ref=camera
	var prefix:="before" if "--before" in OS.get_cmdline_user_args() else "after"
	if prefix=="after" and (world.get("palace_entry")==null or world.palace_entry.is_empty()):
		push_error("World construction failed; refusing to overwrite review images")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(OUT)
	for name in ["Rajasthani Thali","Kalidoscope","Spicy King","Nahargarh Fort"]:
		if "--palace-only" in OS.get_cmdline_user_args() and name!="Nahargarh Fort": continue
		var p:=Vector3.ZERO
		var b:=Basis.IDENTITY
		var depth:=0.0
		var width:=0.0
		if name=="Nahargarh Fort":
			var poi: Dictionary=world.landmarks[5]
			p=Vector3(poi.p[0]+45,0,poi.p[1])
			p.y=world.terrain_height(p.x,p.z)
			b=Basis(Vector3.UP,-PI/2)
			depth=48
			width=48
		else:
			for a in world.amenities:
				if a.name==name:
					p=Vector3(a.p[0],world.terrain_height(a.p[0],a.p[1]),a.p[1])
					b=Basis(Vector3.UP,a.a+(PI if a.get("front",1)<0 else 0))
					depth=a.d
					width=a.w
		var palace: bool=name=="Nahargarh Fort"
		for interior in [false,true]:
			if prefix=="before" and interior: continue
			camera.fov=60 if not interior else 75
			var from:=Vector3(width*.65,9 if palace else 4,depth/2+(48 if palace else 12))
			var target:=Vector3(0,6 if palace else 2.7,0)
			if interior:
				from=Vector3(5 if palace else .3,3 if palace else 1.85,12 if palace else depth/2-.6)
				target=Vector3(0,5 if palace else 1.8,-depth*.3)
			camera.position=p+b*from
			camera.look_at(p+b*target)
			world.update_cells(camera.position)
			for i in 8:
				await process_frame
			await RenderingServer.frame_post_draw
			var path: String=OUT+prefix+"-"+name.to_lower().replace(" ","-")+("-interior" if interior else "-exterior")+".png"
			root.get_texture().get_image().save_png(path)
			print("CAPTURE ",path," objects=",Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)," draws=",Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	quit()
