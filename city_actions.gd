extends "res://street_actions.gd"
var health := 100.0
var combo := 0
var combo_clock := 0.0
var hit_in := -1.0
var hit_damage := 0
var hit_range := 0.0
var toast_clock := 0.0
var mission_active := false
var mission_stage := 0
var cash := 250
var visited: Array = []
var mission_indices := [1,3,5]
var mission_names := ["Collect the parcel · Chandpole Bazaar","Deliver textiles · Central Spine, VDN","Meet the guide · Nahargarh Fort"]
var blood_button: CheckButton

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var theme_style := Theme.new()
	theme_style.default_font_size = 17
	var skin := StyleBoxFlat.new()
	skin.bg_color = Color("20363e")
	skin.border_color = Color("bda27a")
	skin.set_border_width_all(1)
	skin.set_corner_radius_all(10)
	skin.content_margin_left=18
	skin.content_margin_right=18
	theme_style.set_stylebox("normal","Button",skin)
	theme = theme_style
	message = Label.new()
	message.position = Vector2(320,112)
	message.add_theme_color_override("font_color",Color("f0dcb7"))
	message.add_theme_font_size_override("font_size",18)
	add_child(message)
	dialogue = PanelContainer.new()
	dialogue.position = Vector2(345,210)
	dialogue.custom_minimum_size = Vector2(520,320)
	dialogue.hide()
	add_child(dialogue)
	var choices := VBoxContainer.new()
	choices.add_theme_constant_override("separation",8)
	dialogue.add_child(choices)
	for entry in [["RAM RAM SA! · Leave",close_dialogue],["Tell me about this district",directions],["Start / track the city delivery job",work],["Chai + first aid · Rs 25",rest]]:
		var b := Button.new()
		b.text=entry[0]
		b.custom_minimum_size.y=52
		b.pressed.connect(entry[1])
		choices.add_child(b)
	blood_button = CheckButton.new()
	blood_button.text = "Blood effects"
	blood_button.button_pressed = true
	blood_button.toggled.connect(func(value: bool):blood_enabled=value)
	choices.add_child(blood_button)
	var audio_button:=CheckButton.new()
	audio_button.text="Sound effects"
	audio_button.button_pressed=true
	audio_button.toggled.connect(func(value: bool):game.sound.enabled=value)
	choices.add_child(audio_button)
	load_progress()
	game.hud.action_pressed.connect(handle_action)

func notify(text: String) -> void:
	message.text = text
	toast_clock = 5.0

func handle_action(value: String) -> void:
	match value:
		"attack":attack()
		"kick":kick()
		"dodge":dash()
		"talk":talk()
		"guard":
			if not blocked():
				game.avatar.guarding = not game.avatar.guarding
				game.avatar.crouching = false
		"crouch":
			if not blocked():
				game.avatar.crouching = not game.avatar.crouching
				game.avatar.guarding = false
		"ride":
			if not game.hud.map_open and not dialogue_open:
				game.vehicle.toggle_drive()

func blocked() -> bool:
	return game.portrait or game.hud.map_open or dialogue_open or game.vehicle.driving

func attack() -> void:
	begin_attack(false)
func kick() -> void:
	begin_attack(true)
func begin_attack(is_kick: bool) -> void:
	if blocked() or game.attack_cooldown>0 or game.dash_time>0 or game.stamina<(16 if is_kick else 8):
		return
	game.avatar.guarding=false
	game.avatar.crouching=false
	var selected := nearest(3.5)
	if not selected.is_empty():
		var offset: Vector3 = selected.body.position-game.player.position
		game.avatar.rotation.y=atan2(-offset.x,-offset.z)
	if combo_clock<=0:
		combo=0
	var clip := "Kick" if is_kick else ("Jab" if combo%2==0 else "Cross")
	game.avatar.play_action(clip)
	game.avatar.set_expression("Serious",1)
	game.stamina-=16 if is_kick else 8
	game.attack_cooldown=.8 if is_kick else .5
	hit_in=.34 if is_kick else .22
	hit_damage=40 if is_kick else 24
	hit_range=2.5 if is_kick else 2.0
	combo+=1
	combo_clock=1.3

func resolve_hit() -> void:
	var person := nearest(hit_range,true)
	if person.is_empty():
		return
	person.health=person.get("health",100)-hit_damage
	person.stun=.48
	person.human.play_action("Hit")
	person.aggressive=true
	person.counter=1.4
	game.camera_shake=.12
	game.sound.play_effect("impact")
	notify("%s · %d health"%["Kick connected" if hit_damage==40 else "Punch connected",maxi(0,person.health)])
	if blood_enabled:
		blood_mark(person.body.position)
	if person.health<=0:
		person.defeated=true
		person.respawn=30.0
		person.body.collision_layer=0
		person.aggressive=false
		person.human.animation_tree.active=false
		person.human.animator.pause()
		var tween:=create_tween()
		tween.tween_property(person.human,"rotation:z",PI*.48,.35)
		notify("Knockdown · area residents will recover")

func receive_hit(damage: float) -> void:
	if game.vehicle.driving or game.dash_time>0 or dialogue_open:
		return
	if game.avatar.guarding and game.stamina>6:
		damage*=.15
		game.stamina-=6
		notify("Blocked")
	else:
		game.avatar.play_action("Hit")
		game.camera_shake=.16
	health=maxf(0,health-damage)
	if health<=0:
		health=100
		cash=maxi(0,cash-50)
		game.travel_to(0)
		notify("Recovered at Chandpole · Rs 50 first aid")

func dash() -> void:
	if blocked() or game.stamina<25 or game.dash_time>0 or game.attack_cooldown>0:
		return
	game.stamina-=25
	game.dash_time=.38
	game.dodge_direction=Basis(Vector3.UP,game.yaw)*Vector3(game.move_input.x,0,game.move_input.y)
	if game.dodge_direction.length()<.1:
		game.dodge_direction=game.avatar.global_basis.z
	game.dodge_direction=game.dodge_direction.normalized()
	game.avatar.play_action("Dodge")
	game.sound.play_effect("dodge")

func talk() -> void:
	if blocked():
		return
	target=nearest(3.8)
	if target.is_empty():
		notify("Walk up to a resident, then TALK")
		return
	dialogue_open=true
	dialogue.show()
	game.hud.modal=true
	game.hud.clear_input()
	target.stun=3600.0
	target.human.play_action("Wave")
	notify("Khamma ghani! · Wallet Rs %d"%cash)
func close_dialogue() -> void:
	super.close_dialogue()
	game.hud.modal=false
func directions() -> void:
	var district: String=game.world.district_at(game.player.position).id
	var hints: Dictionary={"chandpole":"Bazaar lanes, Chandpole Gate and the road toward Shastri Nagar.","vdn":"Residential sectors, parks and the Central Spine shopping streets.","hills":"Brahmpuri below; Nahargarh fort and the Aravalli ridge above.","sikar":"Sikar Road links the northern colonies and bus depots.","shastri":"Shastri Nagar connects the old city and Vidhyadhar Nagar."}
	var nearest_text := ""
	for kind in ["police","hospital","theka","showroom","fuel"]:
		var best := 1e9
		var best_name := ""
		for a in game.world.amenities:
			if a.kind != kind:
				continue
			var dist: float = Vector2(a.p[0]-game.player.position.x,a.p[1]-game.player.position.z).length()
			if dist < best:
				best = dist
				best_name = a.name if a.name != "" else {"police":"police station","hospital":"clinic","theka":"wine shop","showroom":"car showroom","fuel":"petrol pump"}[kind]
		if best < 1e8:
			nearest_text += "\n%s %d m" % [best_name, int(best)]
	notify(hints[district] + nearest_text)
func work() -> void:
	if not mission_active:
		mission_active=true
		mission_stage=0
	set_destination(mission_indices[mission_stage])
	close_dialogue()
	notify(mission_names[mission_stage]+" · car available at start")
	save_progress()
func rest() -> void:
	if cash<25:
		notify("You need Rs 25 for chai and first aid")
		return
	cash-=25
	health=100
	game.stamina=100
	notify("Rested · health and stamina restored")
	save_progress()
func set_destination(index: int) -> void:
	var poi: Dictionary=game.world.landmarks[index]
	game.hud.waypoint=Vector3(poi.p[0],0,poi.p[1])
	game.hud.has_waypoint=true
	game.hud.navigation=game.world.route_between(game.player.position,game.hud.waypoint)
func save_progress() -> void:
	var f:=FileAccess.open("user://city_progress.json",FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"cash":cash,"visited":visited,"mission_active":mission_active,"mission_stage":mission_stage}))
func load_progress() -> void:
	if not FileAccess.file_exists("user://city_progress.json"):
		return
	var saved=JSON.parse_string(FileAccess.get_file_as_string("user://city_progress.json"))
	if saved is Dictionary:
		cash=int(saved.get("cash",250))
		visited=[]
		for value in saved.get("visited",[]):
			var index:=int(value)
			if index>=0 and index<8 and not visited.has(index):
				visited.append(index)
		mission_active=saved.get("mission_active",false)
		mission_stage=clampi(int(saved.get("mission_stage",0)),0,2)

func _physics_process(delta: float) -> void:
	combo_clock=maxf(0,combo_clock-delta)
	if hit_in>=0:
		hit_in-=delta
		if hit_in<0 and not blocked():
			resolve_hit()
	if mission_active:
		var poi: Dictionary=game.world.landmarks[mission_indices[mission_stage]]
		if Vector2(game.player.position.x-poi.p[0],game.player.position.z-poi.p[1]).length()<12:
			mission_stage+=1
			if mission_stage>=mission_indices.size():
				mission_active=false
				mission_stage=0
				cash+=500
				game.hud.has_waypoint=false
				notify("CITY DELIVERY COMPLETE · +Rs 500")
			else:
				set_destination(mission_indices[mission_stage])
				notify(mission_names[mission_stage])
			save_progress()
	for i in game.world.landmarks.size():
		var p: Array=game.world.landmarks[i].p
		if not visited.has(i) and Vector2(game.player.position.x-p[0],game.player.position.z-p[1]).length()<30:
			visited.append(i)
			cash+=20
			notify("Discovered "+game.world.landmarks[i].name+" · +Rs 20")
			save_progress()

func _process(delta: float) -> void:
	visible=not game.portrait and not game.hud.map_open
	toast_clock=maxf(0,toast_clock-delta)
	message.visible=toast_clock>0
	game.hud.health=health
	game.hud.stamina=game.stamina
	game.hud.quest=mission_names[mission_stage] if mission_active else "EXPLORE %d/8 · Rs %d · talk for delivery work"%[visited.size(),cash]
	if dialogue_open and (game.hud.map_open or game.portrait):
		close_dialogue()
