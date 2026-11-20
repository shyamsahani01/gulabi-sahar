extends CanvasLayer
## Keep this scene free of game preloads: it must paint before loading the city.
@export var game_scene_path := "res://main.tscn"
signal loading_changed(fraction: float, stage: String)
var fraction := 0.0
var stage := "Getting ready"
var started := 0
var loading := false
var finishing := false
var failed := false
var game: Node3D
var progress: ProgressBar
var status: Label
var elapsed: Label
var retry: Button
var spinner: Label
var frame_count := 0
var timing: Dictionary = {}
var previous_fps := 30

func _ready() -> void:
	previous_fps=Engine.max_fps
	Engine.max_fps=60
	started=Time.get_ticks_msec()
	var background := ColorRect.new()
	background.color=Color("171e25")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.add_child(centre)
	var column := VBoxContainer.new()
	column.custom_minimum_size=Vector2(560,0)
	column.add_theme_constant_override("separation",22)
	centre.add_child(column)
	for item in [["GULABI SAHAR",42,"f4d5ba"],["VIDHYADHAR NAGAR · JAIPUR",18,"cb998b"]]:
		var label := Label.new()
		label.text=item[0]
		label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size",item[1])
		label.add_theme_color_override("font_color",Color(item[2]))
		column.add_child(label)
	spinner=Label.new()
	spinner.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	spinner.add_theme_color_override("font_color",Color("d59987"))
	column.add_child(spinner)
	status=Label.new()
	status.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	column.add_child(status)
	progress=ProgressBar.new()
	progress.custom_minimum_size.y=10
	progress.show_percentage=false
	var track:=StyleBoxFlat.new()
	track.bg_color=Color("2c3942")
	track.set_corner_radius_all(5)
	progress.add_theme_stylebox_override("background",track)
	var fill:=track.duplicate()
	fill.bg_color=Color("d59987")
	progress.add_theme_stylebox_override("fill",fill)
	column.add_child(progress)
	elapsed=Label.new()
	elapsed.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	elapsed.add_theme_font_size_override("font_size",15)
	elapsed.add_theme_color_override("font_color",Color("a4b2bc"))
	column.add_child(elapsed)
	var hint:=Label.new()
	hint.text="Explore on foot or drive. Open the map to find places nearby."
	hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size",15)
	column.add_child(hint)
	retry=Button.new()
	retry.text="Try again"
	retry.custom_minimum_size.y=48
	retry.hide()
	retry.pressed.connect(begin_loading)
	column.add_child(retry)
	get_viewport().disable_3d=true
	# Give the lightweight overlay a full rendered frame before requesting resources.
	await get_tree().process_frame
	await get_tree().process_frame
	begin_loading()

func begin_loading() -> void:
	failed=false
	fraction=0.0
	retry.hide()
	set_progress(0,"Loading game resources")
	var error:=ResourceLoader.load_threaded_request(game_scene_path)
	if error!=OK:
		show_error("Game resources could not be opened.")
		return
	loading=true

func set_progress(value: float, label: String) -> void:
	# Work-stage weighting, not a download percentage or a countdown.
	fraction=maxf(fraction,clampf(value,0,1))
	stage=label
	progress.value=fraction*100
	status.text=stage
	loading_changed.emit(fraction,stage)

func show_error(message: String) -> void:
	loading=false
	failed=true
	status.text=message
	spinner.text="Could not start"
	retry.show()
	push_error(message)

func _process(_delta: float) -> void:
	frame_count+=1
	elapsed.text="%d%% · %d s elapsed" % [roundi(fraction*100),(Time.get_ticks_msec()-started)/1000]
	if not failed: spinner.text=["●  ·  ·","·  ●  ·","·  ·  ●","·  ●  ·"][(Time.get_ticks_msec()/250)%4]
	if not loading:return
	var resource_progress: Array=[]
	var state:=ResourceLoader.load_threaded_get_status(game_scene_path,resource_progress)
	if state==ResourceLoader.THREAD_LOAD_FAILED or state==ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		show_error("Game resources could not be loaded.")
	elif state==ResourceLoader.THREAD_LOAD_LOADED:
		loading=false
		timing.resource_ms=Time.get_ticks_msec()-started
		start_game(ResourceLoader.load_threaded_get(game_scene_path))
	elif not resource_progress.is_empty():
		set_progress(float(resource_progress[0])*.15,"Loading game resources")

func start_game(packed: PackedScene) -> void:
	if packed==null:
		show_error("The game scene is missing.")
		return
	set_progress(.15,"Preparing the city")
	await get_tree().process_frame
	game=packed.instantiate()
	game.incremental_startup=true
	game.process_mode=Node.PROCESS_MODE_DISABLED
	game.startup_progress.connect(set_progress)
	game.startup_complete.connect(finish_loading)
	get_tree().root.add_child(game)

func finish_loading() -> void:
	if finishing:return
	finishing=true
	set_progress(.99,"Preparing the first view")
	get_viewport().disable_3d=false
	# Submit the first world view while the overlay still covers it.
	await get_tree().process_frame
	await get_tree().process_frame
	set_progress(1.0,"Ready")
	timing.total_ms=Time.get_ticks_msec()-started
	timing.loader_frames=frame_count
	timing.world_stages=game.world.startup_timings
	game.set_meta("startup_timing",timing)
	print("STARTUP_LOADING ",JSON.stringify(timing))
	Engine.max_fps=previous_fps
	game.process_mode=Node.PROCESS_MODE_INHERIT
	get_tree().current_scene=game
	queue_free()

func _exit_tree() -> void:
	Engine.max_fps=previous_fps
