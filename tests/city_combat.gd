extends SceneTree
var failures:=0
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("check")
func expect(value: bool,label: String) -> void:
	if not value:
		failures+=1
		push_error(label)
func ticks(n: int) -> void:
	for i in n:await physics_frame
func finger(hud: Control,id: int,at: Vector2,pressed: bool) -> void:
	var e:=InputEventScreenTouch.new()
	e.index=id
	e.position=at
	e.pressed=pressed
	hud._input(e)
func check() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	await ticks(90)
	# Freeze crowd routing while testing exact attack-contact distances.
	scene.activity.set_physics_process(false)
	scene.traffic.set_physics_process(false)
	for car in scene.traffic.cars: car.node.collision_layer=0
	var target: Dictionary=scene.activity.people[0]
	target.body.velocity=Vector3.ZERO
	scene.vehicle.position+=Vector3(0,0,30) # Clear the road for deterministic contact checks.
	target.body.position=scene.player.position+Vector3(1.5,0,0)
	target.walking=false
	target.stun=0
	target.health=100
	scene.avatar.rotation.y=-PI/2
	await ticks(3)
	scene.actions.attack()
	expect(target.health==100,"Damage waits for the contact frame")
	await ticks(18)
	expect(target.health==76,"Jab contact damages once")
	await ticks(20)
	expect(target.health==76,"Attack does not damage repeatedly")
	# Target outside reach when the contact happens must evade the hit.
	scene.attack_cooldown=0
	scene.actions.attack()
	target.body.position+=Vector3(6,0,0)
	await ticks(20)
	expect(target.health==76,"Moving out of reach avoids damage")
	# Wall blocks line of sight even within reach.
	target.body.position=scene.player.position+Vector3(1.5,0,0)
	var wall:=StaticBody3D.new()
	var collision:=CollisionShape3D.new()
	var box:=BoxShape3D.new()
	box.size=Vector3(.2,3,3)
	collision.shape=box
	wall.add_child(collision)
	scene.add_child(wall)
	wall.position=scene.player.position+Vector3(.7,1,0)
	await ticks(2)
	expect(scene.actions.nearest(2.0,true).is_empty(),"Cannot strike through a wall")
	wall.queue_free()
	await ticks(3)
	scene.avatar.guarding=true
	scene.stamina=100
	var health: float=scene.actions.health
	scene.actions.receive_hit(10)
	expect(scene.actions.health>health-2,"Guard reduces damage")
	scene.avatar.guarding=false
	scene.dash_time=.3
	health=scene.actions.health
	scene.actions.receive_hit(10)
	expect(scene.actions.health==health,"Dodge evades counterattack")
	scene.dash_time=0
	scene.attack_cooldown=0
	scene.actions.talk()
	expect(scene.actions.dialogue_open,"Conversation opens")
	scene.actions.close_dialogue()
	expect(not scene.hud.modal,"Conversation releases input")
	scene.hud.combat_controls=true
	scene.hud.context_clock=0
	scene.hud._process(.3)
	# Independent fingers: attack must not acquire the camera drag finger.
	finger(scene.hud,1,scene.hud.center()+Vector2(0,-60),true)
	finger(scene.hud,2,scene.hud.action_centers().attack,true)
	expect(scene.hud.move_id==1 and scene.hud.look_id==-1,"Action touch preserves movement and camera ownership")
	finger(scene.hud,2,scene.hud.action_centers().attack,false)
	finger(scene.hud,1,scene.hud.center(),false)
	expect(scene.hud.movement==Vector2.ZERO,"Joystick release clears movement")
	scene.actions.visited=[0,1,2]
	scene.actions.save_progress()
	scene.actions.load_progress()
	expect(scene.actions.visited.size()==3 and scene.actions.visited.has(0),"Save converts numeric landmark IDs without duplicates")
	print("CITY COMBAT RESULT: ",failures," failures")
	quit(1 if failures else 0)
