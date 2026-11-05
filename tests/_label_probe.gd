extends SceneTree
# Throwaway probe: does a rotated, non-billboard Label3D with width/autowrap render?
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var rootn := Node3D.new()
	root.add_child(rootn)
	var cam := Camera3D.new()
	rootn.add_child(cam)
	cam.position = Vector3(0, 1.5, 8)
	cam.current = true
	var sun := DirectionalLight3D.new()
	rootn.add_child(sun)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("446")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color.WHITE
	rootn.add_child(env)
	var font = preload("res://assets/fonts/NotoSansDevanagari-Regular.ttf")
	var specs := [[false,false,-3.0],[true,false,0.0],[true,true,3.0]]
	for spec in specs:
		var label := Label3D.new()
		label.font = font
		label.text = "पुलिस थाना\nPOLICE STATION"
		label.font_size = 34
		label.pixel_size = .0045
		label.modulate = Color.WHITE
		label.outline_size = 4
		label.outline_modulate = Color(0,0,0,.55)
		if spec[0]:
			label.width = 5.0 / .0045
		if spec[1]:
			label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.position = Vector3(spec[2], 1.5, 0)
		rootn.add_child(label)
	for i in 20:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/previews/label_probe.png")
	print("PROBE DONE")
	quit()
