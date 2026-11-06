extends Node
var game: Node3D
var effects: AudioStreamPlayer
var footsteps: AudioStreamPlayer
var engine: AudioStreamPlayer
var step_clock:=0.0
var enabled:=true
var clips: Dictionary={}
func _ready() -> void:
	for key in ["step","impact","dodge","engine","land","sit"]:
		clips[key]=load("res://assets/audio/"+key+".wav")
	effects=AudioStreamPlayer.new()
	add_child(effects)
	footsteps=AudioStreamPlayer.new()
	footsteps.volume_db=-14
	add_child(footsteps)
	engine=AudioStreamPlayer.new()
	engine.stream=clips.engine
	engine.volume_db=-24
	add_child(engine)
func play_effect(key: String) -> void:
	if enabled:
		effects.stream=clips[key]
		effects.volume_db=-9
		effects.play()
func _process(delta: float) -> void:
	if not enabled:
		engine.stop()
		return
	step_clock-=delta
	if game.vehicle.driving:
		if not engine.playing:
			engine.play()
		engine.pitch_scale=.8+absf(game.vehicle.speed)/24
	else:
		engine.stop()
		if game.avatar.movement_speed>.4 and game.player.is_on_floor() and step_clock<=0:
			step_clock=clampf(.8/game.avatar.movement_speed,.22,.48)
			footsteps.stream=clips.step
			footsteps.pitch_scale=randf_range(.85,1.1)
			footsteps.play()
