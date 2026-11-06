extends SceneTree
## Checks the body-motion update: jump phases, landing, seats, cafe patrons, conversation
## gestures and head tracking. Run: ./play.sh --headless --fixed-fps 60 --script res://tests/hero_motion.gd
var failures:=0
func expect(value: bool,label: String) -> void:
	if not value:
		failures+=1
		push_error("FAIL: "+label)
	else:
		print("ok   ",label)
func ticks(n: int) -> void:
	for i in n:
		await physics_frame
func _initialize() -> void:
	Engine.max_fps=0
	call_deferred("check")
func check() -> void:
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	await ticks(60)
	var world: Node3D=scene.world
	var hero: Node3D=scene.avatar
	for name in ["Jump","JumpAir","JumpLand","HardLand","Sit","SitHigh","Talk","Listen","LookAround","Wave"]:
		expect(hero.animator.has_animation("action/"+name),"Clip exists: "+name)
	expect(hero.look!=null,"Hero head look modifier installed")
	expect(world.seats.size()>20,"Seats registered: %d"%world.seats.size())
	expect(world.patron_spots.size()>=7,"Patron spots registered: %d"%world.patron_spots.size())
	var cafe_index:=-1
	for i in world.destinations().size():
		if world.destinations()[i].name.begins_with("Crazy Cafe"):
			cafe_index=i
	expect(cafe_index>=0,"Crazy Cafe is an atlas destination")
	# --- jump: anticipation, airborne loop, landing recovery.
	scene.jump_requested=true
	var saw_jump:=false
	var saw_air:=false
	var saw_land:=false
	var peak: float=scene.player.position.y
	for i in 110:
		await physics_frame
		peak=maxf(peak,scene.player.position.y)
		if hero.action=="Jump": saw_jump=true
		if hero.action=="JumpAir": saw_air=true
		if hero.action=="JumpLand": saw_land=true
	expect(saw_jump,"Jump launch clip played")
	expect(saw_air,"Airborne clip looped while off the ground")
	expect(saw_land,"Landing clip played on touchdown")
	expect(peak>scene.player.position.y+.8,"Jump height reached (%.2f m)"%(peak-scene.player.position.y))
	expect(scene.player.is_on_floor(),"Back on the ground after the jump")
	# --- idle lean/fidget state sanity.
	expect(absf(hero.rotation.z)<.2 and absf(hero.rotation.x)<.2,"Lean stays subtle at rest")
	# --- travel to the cafe, patrons appear, sit on a chair, stand up by moving.
	scene.travel_to(cafe_index)
	await ticks(90)
	var life: Node3D=scene.activity
	expect(life.patrons.size()>=3,"Cafe patrons spawned near the player: %d"%life.patrons.size())
	var seated_patron: Dictionary={}
	var barista: Dictionary={}
	for p in life.patrons:
		if p.seated and seated_patron.is_empty(): seated_patron=p
		if p.pose=="Stand": barista=p
	expect(not seated_patron.is_empty() and seated_patron.human.action in ["Sit","SitHigh"],"Seated patron holds a sitting pose")
	expect(not seated_patron.is_empty() and seated_patron.human.skeleton.find_bone("thigh_l")>=0,"Crowd rig has leg bones for the sitting pose")
	expect(not barista.is_empty(),"Barista stands behind the counter")
	var nearest_seat: Dictionary={}
	var best:=1e9
	for s in world.seats:
		var d: float=s.p.distance_to(scene.player.position)
		if d<best and s.pose=="Sit":
			best=d
			nearest_seat=s
	scene.player.position=nearest_seat.p+Vector3(0,.3,0)
	scene.player.velocity=Vector3.ZERO
	await ticks(20)
	var before: Vector3=scene.player.position
	scene.sit_toggle()
	await ticks(30)
	expect(not scene.seated.is_empty(),"Player sits on the nearest cafe seat")
	expect(hero.action in ["Sit","SitDown"],"Sit-down clip starts (%s)"%hero.action)
	await ticks(85)
	expect(hero.action=="Sit","Seated loop plays after the sit-down transition")
	expect(scene.player.position.distance_to(nearest_seat.p)<.05,"Player pinned to the seat position")
	expect(absf(angle_difference(hero.rotation.y,nearest_seat.yaw))<.05,"Player faces the seat direction")
	var pelvis: int=hero.skeleton.find_bone("pelvis")
	var pelvis_height: float=(hero.skeleton.global_transform*hero.skeleton.get_bone_global_pose(pelvis)).origin.y-scene.player.global_position.y
	expect(pelvis_height<.72,"Hips lowered to chair height (%.2f m)"%pelvis_height)
	scene.touch_move=Vector2(0,-1)
	await ticks(10)
	scene.touch_move=Vector2.ZERO
	expect(scene.seated.is_empty(),"Pushing the stick stands the player up")
	expect(hero.action in ["","StandUp"],"Stand-up clip plays (%s)"%hero.action)
	await ticks(70)
	expect(hero.action=="","Locomotion resumes after standing")
	await ticks(20)
	# --- conversation with the seated guest: gestures, facing and the speech panel.
	scene.player.position=seated_patron.body.position+Vector3(1.2,.3,0)
	scene.player.velocity=Vector3.ZERO
	await ticks(15)
	scene.actions.talk()
	await ticks(30)
	expect(scene.actions.dialogue_open,"Dialogue opens next to the guest")
	expect(hero.action=="Listen","Hero listens while the guest greets")
	expect(scene.actions.speech.text.length()>8,"Resident greeting line shown")
	expect(seated_patron.human.action in ["Sit","SitHigh"],"Seated guest keeps sitting during the talk")
	var partner: Dictionary=scene.actions.target
	expect(partner.get("seated",false),"Talk picked the seated guest")
	var to_npc: Vector3=partner.body.global_position-scene.player.global_position
	to_npc.y=0
	expect((-hero.global_basis.z).dot(to_npc.normalized())>.8,"Hero turned to face the guest")
	scene.actions.directions()
	await ticks(5)
	expect(hero.action=="Talk","Hero gestures while speaking")
	await ticks(150)
	expect(hero.action=="Listen","Hero returns to listening after the reply")
	expect(hero.look_target!=null and hero.look.influence>.5,"Head tracks the conversation partner")
	var head: int=hero.skeleton.find_bone("head")
	var head_forward: Vector3=hero.skeleton.global_transform.basis*hero.skeleton.get_bone_global_pose(head).basis.z
	var head_pos: Vector3=(hero.skeleton.global_transform*hero.skeleton.get_bone_global_pose(head)).origin
	var to_target: Vector3=(hero.look_target.global_position-head_pos).normalized()
	expect(head_forward.normalized().dot(to_target)>.85,"Head bone points at the look target (dot %.2f)"%head_forward.normalized().dot(to_target))
	scene.actions.close_dialogue()
	await ticks(5)
	expect(not scene.actions.dialogue_open and hero.action=="","Dialogue closes and the hero relaxes")
	# --- talk with a standing resident: they turn to face the player.
	scene.player.position=barista.body.position+Vector3(0,.3,1.5)
	await ticks(10)
	scene.actions.talk()
	await ticks(45)
	expect(scene.actions.target.get("pose","")=="Stand","Talk reaches the barista across the counter")
	var toward: Vector3=scene.player.global_position-barista.body.global_position
	toward.y=0
	expect((-barista.human.global_basis.z).dot(toward.normalized())>.7,"Standing resident turns toward the player")
	expect(barista.human.action in ["Talk","Wave","Listen"],"Standing resident gestures while talking")
	scene.actions.close_dialogue()
	await ticks(5)
	# --- hard landing from a height.
	var cafe: Dictionary=world.destinations()[cafe_index]
	scene.player.position=Vector3(cafe.p[0],world.terrain_height(cafe.p[0],cafe.p[1])+10,cafe.p[1])
	scene.player.velocity=Vector3.ZERO
	var saw_hard:=false
	for i in 140:
		await physics_frame
		if hero.action=="HardLand": saw_hard=true
	expect(saw_hard,"Hard landing clip after a 9 m drop")
	# --- physical layer: foot IK installed, ragdoll knockdown and recovery, dangling wardrobe.
	expect(hero.foot_ik.size()==2,"Foot IK installed on both legs")
	await ticks(30)
	hero.knock_down(Vector3(0,3,4))
	await ticks(45)
	expect(hero.ragdolling and hero.ragdoll!=null,"Knockdown switches the hero to the ragdoll")
	# Modifier results are not visible through get_bone_global_pose(); read the simulated body.
	var head_height: float=hero.ragdoll.get_node("PB_head").global_position.y-hero.global_position.y
	expect(head_height<1.0,"Ragdoll head drops under physics (%.2f m)"%head_height)
	hero.get_up()
	await ticks(5)
	expect(not hero.ragdolling and hero.animation_tree.active,"Get-up restores the animation")
	hero.apply_outfit(0)
	expect(hero.pendulums.size()>=1,"Street outfit hangs a swinging necklace")
	for name in ["Jab","Kick","Sit","Talk","Fall","Wave"]:
		expect(hero.animator.has_animation("Mocap"+name),"Motion-capture clip loaded: "+name)
	# --- face: structured head keys, brow-driven expressions and the FACE-view zoom.
	for shape in ["Smile","BrowRaise","BrowFurrow","BlinkLeft","Serious","Surprised"]:
		expect(hero.face.find_blend_shape_by_name(shape)>=0,"Face key present: "+shape)
	hero.set_expression("Neutral",30)
	for i in 60:hero.update_face(.025)
	hero.set_expression("Smile",30)
	expect(hero.brow_flash>.9,"Smile onset lifts the brows first")
	for i in 60:hero.update_face(.025)
	expect(hero.face.get_blend_shape_value(hero.face.find_blend_shape_by_name("Smile"))>.95,"Smile key blends in")
	var raise_index: int=hero.face.find_blend_shape_by_name("BrowRaise")
	expect(hero.face.get_blend_shape_value(raise_index)>.15,"Smile keeps a light brow lift (%.2f)"%hero.face.get_blend_shape_value(raise_index))
	hero.set_expression("Serious",30)
	for i in 60:hero.update_face(.025)
	expect(hero.face.get_blend_shape_value(hero.face.find_blend_shape_by_name("BrowFurrow"))>.7,"Serious furrows the brows")
	expect(hero.face.get_blend_shape_value(raise_index)<.05,"Brow lift released when serious")
	hero.set_expression("Neutral",30)
	scene.toggle_portrait()
	expect(scene.portrait and scene.portrait_camera.current,"FACE view uses the portrait camera")
	var far: float=scene.portrait_distance
	scene.zoom_portrait(2.0)
	var near: float=scene.portrait_distance
	var camera_offset: Vector3=scene.portrait_camera.position-Vector3(0,1.58,0)
	expect(near<far*.6 and absf(camera_offset.length()-near)<.1,"Zoom moves the portrait camera closer (%.2f -> %.2f m)"%[far,near])
	expect(is_equal_approx(scene.hud.face_zoom_level,.85/scene.portrait_distance),"HUD shows the zoom level")
	for i in 12:scene.zoom_portrait(2.0)
	expect(scene.portrait_distance>=scene.PORTRAIT_DISTANCE_MIN-.001,"Zoom stops at the minimum distance")
	scene.hud.face_zoom.emit(.5)
	expect(scene.portrait_distance>scene.PORTRAIT_DISTANCE_MIN+.01,"Pinch-out signal zooms back out")
	scene.orbit_portrait(Vector2(0,400))
	expect(scene.portrait_camera.position.y>1.6,"Dragging down pulls the view up toward the brows (content follows the finger)")
	scene.orbit_portrait(Vector2(0,-900))
	expect(scene.portrait_camera.position.y<1.56,"Dragging up pulls the view down toward the chin and neck")
	scene.toggle_portrait()
	expect(not scene.portrait,"BACK leaves the portrait view")
	print("HERO MOTION RESULT: ",failures," failures")
	quit(1 if failures else 0)
