extends PanelContainer
## Location actions use real walk-up points; opening the atlas never completes a visit.
var game: Node3D
var active: Dictionary={}
var visited: Dictionary={}
var title: Label
var description: Label
var action: Button
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	offset_left=-255
	offset_top=-155
	offset_right=255
	offset_bottom=155
	custom_minimum_size=Vector2(510,290)
	var skin:=StyleBoxFlat.new()
	skin.bg_color=Color("1c3039")
	skin.set_corner_radius_all(14)
	skin.content_margin_left=24
	skin.content_margin_right=24
	skin.content_margin_top=24
	skin.content_margin_bottom=24
	add_theme_stylebox_override("panel",skin)
	var column:=VBoxContainer.new()
	column.add_theme_constant_override("separation",18)
	add_child(column)
	title=Label.new()
	title.add_theme_font_size_override("font_size",22)
	title.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	column.add_child(title)
	description=Label.new()
	description.custom_minimum_size=Vector2(460,80)
	description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	column.add_child(description)
	action=Button.new()
	action.custom_minimum_size.y=48
	action.pressed.connect(perform)
	column.add_child(action)
	var leave:=Button.new()
	leave.text="Continue exploring"
	leave.custom_minimum_size.y=44
	leave.pressed.connect(close)
	column.add_child(leave)
	hide()
func nearest() -> Dictionary:
	var best: Dictionary={}
	var distance:=2.5
	for entry in game.world.place_interactions:
		var d: float=entry.p.distance_to(game.player.position)
		if d<distance:best=entry;distance=d
	return best
func open() -> void:
	if game.actions.blocked():return
	active=nearest()
	if active.is_empty():return
	title.text=active.name
	description.text=active.description
	action.text="First aid · Rs 25" if active.kind=="hospital" else "Check in at reception"
	action.disabled=false
	game.actions.dialogue_open=true
	game.hud.modal=true
	game.hud.clear_input()
	game.player.velocity=Vector3.ZERO
	show()
func perform() -> void:
	if active.is_empty() or not visible:return
	if game.player.position.distance_to(active.p)>2.5:
		close()
		return
	if active.kind=="hospital":
		if game.actions.health>=100:
			description.text="You are already at full health. No charge."
			return
		if game.actions.cash<25:
			description.text="You need Rs 25 for first aid. Your wallet has Rs %d."%game.actions.cash
			return
		game.actions.cash-=25
		game.actions.health=100
		game.stamina=100
		game.actions.save_progress()
		description.text="First aid complete. Health and stamina restored."
	else:
		description.text="Visit recorded. Explore the courtyard and reception, or take a seat outside."
	visited[active.name]=true
	action.disabled=true
func close() -> void:
	hide()
	active={}
	game.actions.dialogue_open=false
	game.hud.modal=false
	game.hud.clear_input()
func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
