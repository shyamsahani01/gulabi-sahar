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
var mission_indices := [1,2,0]
var mission_names := ["Collect the parcel · Central Spine","Deliver parts · VKI South","Return to Vidhyadhar Nagar"]
var blood_button: CheckButton
var speaker: Label
var speech: Label
var reply_clock := 0.0
const ROLES := {"adult":"Resident","elder":"Elder","child":"Child"}

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
	dialogue.position = Vector2(240,300)
	dialogue.custom_minimum_size = Vector2(470,330)
	dialogue.hide()
	add_child(dialogue)
	var choices := VBoxContainer.new()
	choices.add_theme_constant_override("separation",6)
	dialogue.add_child(choices)
	speaker = Label.new()
	speaker.add_theme_color_override("font_color",Color("d6bb7f"))
	speaker.add_theme_font_size_override("font_size",13)
	choices.add_child(speaker)
	speech = Label.new()
	speech.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	speech.custom_minimum_size = Vector2(440,0)
	speech.add_theme_color_override("font_color",Color("f4e6d0"))
	speech.add_theme_font_size_override("font_size",16)
	choices.add_child(speech)
	for entry in [["Tell me about this district",directions],["Start / track the city delivery job",work],["Chai + first aid · Rs 25",rest],["Ram Ram sa! · Leave",close_dialogue]]:
		var b := Button.new()
		b.text=entry[0]
		b.custom_minimum_size.y=44
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
		"sit":
			game.sit_toggle()
		"ride":
			if not game.hud.map_open and not dialogue_open:
				var was_driving: bool = game.vehicle.driving
				if not was_driving:
					game.vehicle = game.nearest_drivable()
					game.vehicle.set_physics_process(true)
				game.vehicle.toggle_drive()
				if was_driving:
					for car in game.traffic.cars:
						if car.node == game.vehicle:
							car.route = PackedVector3Array()
							car.node.set_physics_process(false)
							break

func blocked() -> bool:
	return game.portrait or game.hud.map_open or dialogue_open or game.vehicle.driving or not game.seated.is_empty()

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
		if hit_damage==40:
			# A kick knocks them off their feet: physics ragdoll in the direction of the blow.
			var push: Vector3=(person.body.position-game.player.position)
			push.y=0
			person.human.knock_down(push.normalized()*7.0+Vector3.UP*3.0)
		elif person.human.has_action("Fall"):
			# Punch knockdown: motion-captured fall; the clip ends lying down and holds there.
			person.human.play_action("Fall",3600.0,.12)
		else:
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
		var attacker := nearest(3.5,true)
		game.knockout(attacker.body.global_position if not attacker.is_empty() else game.player.global_position-game.avatar.global_basis.z)

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
	if game.portrait or game.hud.map_open or dialogue_open or game.vehicle.driving:
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
	target.face_player=true
	# Both people turn to each other; the resident greets, the hero answers with a gesture.
	var role: String=ROLES.get(target.kind,"Resident")
	if target.get("seated",false):
		role="Cafe guest"
	elif target.get("pose","")=="Stand":
		role="Barista"
	speaker.text="%s · %s"%[role.to_upper(),str(game.world.district_at(game.player.position).get("name","Jaipur")).to_upper()]
	var openers: Array=["Ram Ram sa! Kaise ho? Jaipur ghoomne aaye ho?","Khamma ghani! Kuch madad chahiye, bhai sa?","Aao, aao! Chai piyoge? Kya haal hai?","Namaste ji. Yahan naye lage ho, raasta bataun?"]
	if role=="Cafe guest":
		openers=["Yahan ka cappuccino try karo, kamaal ka hai!","Baitho na, WiFi bhi free hai yahan.","Espresso Yourself! Accha cafe hai, nahi?"]
	elif role=="Barista":
		openers=["Welcome to Crazy Cafe! Kya lenge aap?","Aaj special mocha hai, try karoge?","Order counter pe dein, table pe la denge."]
	speech.text=openers[randi()%openers.size()]
	target.human.set_expression("Smile",6)
	if target.get("seated",false):
		pass
	elif game.player.position.distance_to(target.body.position)>2.2:
		target.human.play_action("Wave",-1.0,.2)
		reply_clock=1.4
	else:
		target.human.play_action("Talk",3600.0,.25)
		reply_clock=2.4
	game.avatar.play_action("Listen",3600.0,.25)
	game.avatar.set_expression("Smile",4)
	notify("Talking · Wallet Rs %d"%cash)
func say(reply: String) -> void:
	# The hero speaks with a gesture loop while the resident listens, then replies.
	speech.text=reply
	game.avatar.play_action("Talk",3600.0,.25)
	if not target.is_empty() and not target.get("seated",false):
		target.human.play_action("Listen",3600.0,.25)
	reply_clock=2.2
func close_dialogue() -> void:
	if not target.is_empty():
		target.face_player=false
		if target.get("seated",false):
			target.human.play_action(target.pose,3600.0,.3)
		else:
			target.human.stop_action(.3)
	super.close_dialogue()
	game.avatar.stop_action(.3)
	game.hud.modal=false
func directions() -> void:
	var district: String=game.world.district_at(game.player.position).id
	var hints: Dictionary={"vki":"VKI workshops, auto works and industrial streets. Head south to VDN Central Spine.","chandpole":"Bazaar lanes, Chandpole Gate and the road toward Shastri Nagar.","vdn":"Residential sectors, parks and the Central Spine shopping streets.","hills":"Brahmpuri below; Nahargarh fort and the Aravalli ridge above.","sikar":"Sikar Road links the northern colonies and bus depots.","shastri":"Shastri Nagar connects the old city and Vidhyadhar Nagar."}
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
	say(hints[district] + nearest_text)
func work() -> void:
	if not mission_active:
		mission_active=true
		mission_stage=0
	set_destination(mission_indices[mission_stage])
	say("Theek hai bhai sa, "+mission_names[mission_stage]+". Gaadi start pe milegi.")
	notify(mission_names[mission_stage]+" · car available at start")
	save_progress()
func rest() -> void:
	if cash<25:
		say("Arre, Rs 25 to lagenge chai aur patti ke liye!")
		return
	cash-=25
	health=100
	game.stamina=100
	say("Lo, garam chai. Aaram se piyo, thakan utar jayegi.")
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
		f.store_string(JSON.stringify({"map_edition":game.world.MAP_EDITION,"cash":cash,"visited":visited,"mission_active":mission_active,"mission_stage":mission_stage,"outfit":game.avatar.outfit}))
func load_progress() -> void:
	if not FileAccess.file_exists("user://city_progress.json"):
		return
	var saved=JSON.parse_string(FileAccess.get_file_as_string("user://city_progress.json"))
	if saved is Dictionary:
		cash=int(saved.get("cash",250))
		visited=[]
		for value in (saved.get("visited",[]) if saved.get("map_edition","")==game.world.MAP_EDITION else []):
			var index:=int(value)
			if index>=0 and index<game.world.landmarks.size() and not visited.has(index):
				visited.append(index)
		mission_active=saved.get("mission_active",false) and saved.get("map_edition","")==game.world.MAP_EDITION
		mission_stage=clampi(int(saved.get("mission_stage",0)),0,2)
		var outfit:=int(saved.get("outfit",0))
		if outfit!=game.avatar.outfit:
			game.avatar.apply_outfit(outfit)
			game.hud.outfit_label=game.avatar.outfit_name()

func _physics_process(delta: float) -> void:
	combo_clock=maxf(0,combo_clock-delta)
	if dialogue_open and reply_clock>0:
		reply_clock-=delta
		if reply_clock<=0 and not target.is_empty():
			# After a line, the resident answers with gestures and the hero listens.
			if not target.get("seated",false):
				target.human.play_action("Talk" if game.avatar.action!="Talk" else "Listen",3600.0,.3)
			if game.avatar.action=="Talk":
				game.avatar.play_action("Listen",3600.0,.3)
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
	game.hud.quest=mission_names[mission_stage] if mission_active else "EXPLORE %d/%d · Rs %d · talk for delivery work"%[visited.size(),game.world.landmarks.size(),cash]
	if dialogue_open and (game.hud.map_open or game.portrait):
		close_dialogue()
