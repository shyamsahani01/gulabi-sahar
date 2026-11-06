extends Control
# Separate native controls keep action touches out of the camera gesture stream.
var game: Node3D
var dialogue_open := false
var target: Dictionary = {}
var message: Label
var status: Label
var dialogue: PanelContainer
var blood_enabled := true
var marks: Array[Node3D] = []
var hit_flash: ColorRect
var bar: HBoxContainer

func _ready() -> void:
	var skin := StyleBoxFlat.new()
	skin.bg_color = Color("202d32")
	skin.border_color = Color("d5a26d")
	skin.set_border_width_all(2)
	skin.set_corner_radius_all(12)
	var theme_style := Theme.new()
	theme_style.default_font_size = 17
	theme_style.set_stylebox("normal", "Button", skin)
	var pressed_style: StyleBoxFlat = skin.duplicate()
	pressed_style.bg_color = Color("875b47")
	theme_style.set_stylebox("pressed", "Button", pressed_style)
	theme_style.set_color("font_color", "Button", Color("f4e6d0"))
	theme = theme_style
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar = HBoxContainer.new()
	bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	bar.position = Vector2(size.x - 340, size.y * 0.5 - 40)
	bar.add_theme_constant_override("separation", 10)
	add_child(bar)
	for item in [["HIT · Q", attack], ["TALK · T", talk], ["DASH · X", dash]]:
		var b := Button.new()
		b.text = item[0]
		b.custom_minimum_size = Vector2(96, 58)
		b.pressed.connect(item[1])
		bar.add_child(b)
	status = Label.new()
	status.position = Vector2(30, 126)
	status.add_theme_color_override("font_color", Color("f2d2a4"))
	add_child(status)
	message = Label.new()
	message.position = Vector2(365, 32)
	message.add_theme_font_size_override("font_size", 19)
	add_child(message)
	dialogue = PanelContainer.new()
	dialogue.position = Vector2(365, 90)
	dialogue.custom_minimum_size = Vector2(475, 220)
	dialogue.visible = false
	add_child(dialogue)
	var choices := VBoxContainer.new()
	dialogue.add_child(choices)
	for entry in [["RAM RAM SA! · Close", close_dialogue], ["Ask about the city", directions], ["Any work nearby?", work], ["Chai break · recover stamina", rest]]:
		var b := Button.new()
		b.text = entry[0]
		b.custom_minimum_size.y = 48
		b.pressed.connect(entry[1])
		choices.add_child(b)
	var blood := CheckButton.new()
	blood.text = "Blood FX"
	blood.button_pressed = true
	blood.position = Vector2(30, 158)
	blood.toggled.connect(func(value: bool): blood_enabled = value)
	add_child(blood)
	hit_flash = ColorRect.new()
	hit_flash.color = Color(1, 0.3, 0.15, 0)
	hit_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hit_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(hit_flash)

func blocked() -> bool:
	return game.portrait or game.hud.map_open or dialogue_open

func nearest(radius: float, facing := false) -> Dictionary:
	var found: Dictionary = {}
	var best := radius
	for person in game.activity.everyone():
		if person.kind == "child" or person.get("defeated", false):
			continue
		var offset: Vector3 = person.body.global_position - game.player.global_position
		var distance := offset.length()
		if facing and distance > 0.1 and offset.normalized().dot(-game.avatar.global_basis.z) < 0.2:
			continue
		if distance < best:
			# Eye-level line of sight, so a counter or table between two people does not block talking.
			var query := PhysicsRayQueryParameters3D.create(game.player.global_position + Vector3(0, 1.45, 0), person.body.global_position + Vector3(0, 1.45, 0), 1)
			query.exclude = [game.player.get_rid()]
			if not game.get_world_3d().direct_space_state.intersect_ray(query).is_empty():
				continue
			best = distance
			found = person
	return found

func attack() -> void:
	if blocked() or game.attack_cooldown > 0:
		return
	game.attack_cooldown = 0.6
	game.avatar.set_expression("Serious", 1)
	var tween := create_tween()
	tween.tween_property(game.avatar, "rotation:x", -0.18, 0.1)
	tween.tween_property(game.avatar, "rotation:x", 0.0, 0.2)
	var person := nearest(2.3, true)
	if person.is_empty():
		message.text = "Move closer and face an adult NPC."
		return
	person.health = person.get("health", 100) - 34
	person.stun = 0.8
	person.greet_time = 0.0
	person.human.set_expression("Surprised", 2)
	person.human.movement_speed = 0
	message.text = "Hit · health %d" % maxi(0, person.health)
	if blood_enabled:
		blood_mark(person.body.global_position)
	if person.health <= 0:
		person.defeated = true
		person.respawn = 25.0
		person.body.collision_layer = 0
		person.human.rotation.z = PI / 2
		message.text = "NPC down · recovers in 25 seconds"

func blood_mark(at: Vector3) -> void:
	var mark := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.23
	mesh.bottom_radius = 0.26
	mesh.height = 0.009
	mesh.radial_segments = 12
	mark.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("852b32")
	mat.roughness = 0.7
	mark.material_override = mat
	game.add_child(mark)
	mark.global_position = at + Vector3(0, 0.02, 0)
	marks.append(mark)
	if marks.size() > 16:
		var oldest: Node3D = marks.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()
	get_tree().create_timer(20).timeout.connect(func():
		if is_instance_valid(mark):
			marks.erase(mark)
			mark.queue_free())

func talk() -> void:
	if blocked():
		return
	target = nearest(3.5)
	if target.is_empty():
		message.text = "Find an adult shopkeeper or resident to talk."
		return
	dialogue_open = true
	dialogue.show()
	game.hud.clear_input()
	target.stun = 60.0
	target.human.set_expression("Smile", 60)
	message.text = "Resident: Khamma ghani! How can I help?"

func close_dialogue() -> void:
	if not target.is_empty():
		target.stun = 0.0
		target.human.set_expression("Neutral", 1)
	target = {}
	dialogue_open = false
	dialogue.hide()

func directions() -> void:
	message.text = "North: Chandpole, Sikar Road, park, then the hills."
func work() -> void:
	message.text = "Explore the new artisan square east of Sikar Road."
func rest() -> void:
	game.stamina = 100
	message.text = "Chai is ready, sa. Stamina restored."
func dash() -> void:
	if blocked() or game.stamina < 35 or game.dash_time > 0:
		return
	game.stamina -= 35
	game.dash_time = 0.45
func _process(_delta: float) -> void:
	bar.position = Vector2(size.x - 340, size.y * 0.5 - 40)
	visible = not game.portrait and not game.hud.map_open
	status.text = "STAMINA  %03d  /  100     ·     STREET LIFE" % int(game.stamina)
	if dialogue_open and (game.hud.map_open or game.portrait):
		close_dialogue()
