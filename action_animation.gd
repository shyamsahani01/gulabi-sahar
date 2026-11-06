extends RefCounted
# Authored full-rig action clips. Locomotion remains the user's existing mocap.
# Each clip is a list of keyframes [time, pose, pelvis_drop]; a pose maps bone names to
# degrees in skeleton/world axes, converted to each bone's parent frame. Missing bones
# return to the baseline (Idle) rotation, so clips also work on the simpler crowd rig.
const FIST_CLIPS := ["Jab","Cross","Kick","Guard"]

static func clips() -> Array:
	var guard := {"upperarm_l":Vector3(-35,0,-12),"lowerarm_l":Vector3(-65,0,0),"upperarm_r":Vector3(-35,0,12),"lowerarm_r":Vector3(-65,0,0),"spine_01":Vector3(5,0,0)}
	var jab := guard.duplicate()
	jab.merge({"upperarm_l":Vector3(-80,-12,0),"lowerarm_l":Vector3(-12,0,0),"spine_01":Vector3(6,-18,0)},true)
	var cross := guard.duplicate()
	cross.merge({"upperarm_r":Vector3(-85,15,0),"lowerarm_r":Vector3(-8,0,0),"spine_01":Vector3(8,25,0)},true)
	var kick := guard.duplicate()
	kick.merge({"thigh_r":Vector3(-82,0,0),"calf_r":Vector3(12,0,0),"spine_01":Vector3(-12,-10,0)},true)
	var crouch := {"thigh_l":Vector3(-48,0,0),"thigh_r":Vector3(-48,0,0),"calf_l":Vector3(85,0,0),"calf_r":Vector3(85,0,0),"spine_01":Vector3(24,0,0),"upperarm_l":Vector3(-30,0,0),"upperarm_r":Vector3(-30,0,0)}
	var hit := {"spine_01":Vector3(-18,12,0),"neck_01":Vector3(-15,0,0),"upperarm_l":Vector3(15,0,-20),"upperarm_r":Vector3(15,0,20)}
	var wave := {"upperarm_r":Vector3(0,0,100),"lowerarm_r":Vector3(-50,0,0),"hand_r":Vector3(0,0,20)}
	# Jump: a quick dip with the arms swung back, then a full extension as the feet leave.
	var jump_dip := {"thigh_l":Vector3(-32,0,0),"thigh_r":Vector3(-32,0,0),"calf_l":Vector3(55,0,0),"calf_r":Vector3(55,0,0),"spine_01":Vector3(16,0,0),"upperarm_l":Vector3(28,0,-8),"upperarm_r":Vector3(28,0,8),"neck_01":Vector3(-8,0,0)}
	var jump_launch := {"thigh_l":Vector3(-12,0,0),"thigh_r":Vector3(-30,0,0),"calf_l":Vector3(10,0,0),"calf_r":Vector3(40,0,0),"spine_01":Vector3(-6,0,0),"upperarm_l":Vector3(-62,0,-22),"upperarm_r":Vector3(-62,0,22),"lowerarm_l":Vector3(-30,0,0),"lowerarm_r":Vector3(-30,0,0)}
	# Airborne: knees tucked, trailing leg higher, arms out for balance, slight forward lean.
	var air_a := {"thigh_l":Vector3(-34,0,0),"thigh_r":Vector3(-58,0,0),"calf_l":Vector3(52,0,0),"calf_r":Vector3(84,0,0),"upperarm_l":Vector3(-48,0,-34),"upperarm_r":Vector3(-48,0,34),"lowerarm_l":Vector3(-42,0,0),"lowerarm_r":Vector3(-42,0,0),"spine_01":Vector3(8,0,0)}
	var air_b := {"thigh_l":Vector3(-50,0,0),"thigh_r":Vector3(-40,0,0),"calf_l":Vector3(70,0,0),"calf_r":Vector3(64,0,0),"upperarm_l":Vector3(-40,0,-40),"upperarm_r":Vector3(-40,0,40),"lowerarm_l":Vector3(-36,0,0),"lowerarm_r":Vector3(-36,0,0),"spine_01":Vector3(10,0,0)}
	# Landing: deep knee bend, torso folded forward, arms reaching, then rise.
	var land_deep := {"thigh_l":Vector3(-52,0,0),"thigh_r":Vector3(-52,0,0),"calf_l":Vector3(96,0,0),"calf_r":Vector3(96,0,0),"spine_01":Vector3(30,0,0),"neck_01":Vector3(-12,0,0),"upperarm_l":Vector3(-28,0,-28),"upperarm_r":Vector3(-28,0,28),"lowerarm_l":Vector3(-20,0,0),"lowerarm_r":Vector3(-20,0,0)}
	var land_rise := {"thigh_l":Vector3(-16,0,0),"thigh_r":Vector3(-16,0,0),"calf_l":Vector3(30,0,0),"calf_r":Vector3(30,0,0),"spine_01":Vector3(8,0,0),"upperarm_l":Vector3(-6,0,-8),"upperarm_r":Vector3(-6,0,8)}
	# Seated: thighs level, shins vertical, hands resting on the thighs; a gentle breath cycle.
	var sit := {"thigh_l":Vector3(-86,0,6),"thigh_r":Vector3(-86,0,-6),"calf_l":Vector3(88,0,0),"calf_r":Vector3(88,0,0),"spine_01":Vector3(-3,0,0),"spine_02":Vector3(4,0,0),"upperarm_l":Vector3(-20,0,-6),"upperarm_r":Vector3(-20,0,6),"lowerarm_l":Vector3(-66,0,10),"lowerarm_r":Vector3(-66,0,-10),"hand_l":Vector3(14,0,0),"hand_r":Vector3(14,0,0),"foot_l":Vector3(8,0,0),"foot_r":Vector3(8,0,0)}
	var sit_breath := sit.duplicate()
	sit_breath.merge({"spine_02":Vector3(6,0,0),"neck_01":Vector3(3,0,0),"head":Vector3(0,6,0)},true)
	var sit_high := sit.duplicate()
	sit_high.merge({"thigh_l":Vector3(-70,0,6),"thigh_r":Vector3(-70,0,-6),"calf_l":Vector3(72,0,0),"calf_r":Vector3(72,0,0)},true)
	var sit_high_breath := sit_high.duplicate()
	sit_high_breath.merge({"spine_02":Vector3(6,0,0),"head":Vector3(0,-5,0)},true)
	# Conversation: alternating open-hand gestures and small head nods.
	var talk_a := {"upperarm_r":Vector3(-22,0,18),"lowerarm_r":Vector3(-72,0,-10),"hand_r":Vector3(-10,0,-20),"upperarm_l":Vector3(-8,0,-6),"lowerarm_l":Vector3(-24,0,0),"head":Vector3(3,6,0)}
	var talk_b := {"upperarm_r":Vector3(-38,-12,24),"lowerarm_r":Vector3(-96,0,-14),"hand_r":Vector3(-20,0,-30),"upperarm_l":Vector3(-10,0,-8),"lowerarm_l":Vector3(-30,0,0),"spine_01":Vector3(2,6,0),"head":Vector3(-4,-4,0)}
	var talk_c := {"upperarm_l":Vector3(-30,0,-20),"lowerarm_l":Vector3(-84,0,12),"hand_l":Vector3(-12,0,22),"upperarm_r":Vector3(-12,0,10),"lowerarm_r":Vector3(-40,0,-6),"spine_01":Vector3(2,-5,0),"head":Vector3(5,3,0)}
	var talk_d := {"upperarm_l":Vector3(-34,0,-26),"lowerarm_l":Vector3(-70,0,10),"upperarm_r":Vector3(-34,0,26),"lowerarm_r":Vector3(-70,0,-10),"hand_l":Vector3(0,0,30),"hand_r":Vector3(0,0,-30),"spine_01":Vector3(4,0,0),"head":Vector3(-2,0,0)}
	var listen_a := {"upperarm_l":Vector3(-6,0,-4),"upperarm_r":Vector3(-6,0,4),"lowerarm_r":Vector3(-20,0,0),"head":Vector3(2,-5,0),"spine_01":Vector3(0,0,2)}
	var listen_b := {"upperarm_l":Vector3(-6,0,-4),"upperarm_r":Vector3(-6,0,4),"lowerarm_r":Vector3(-24,0,0),"head":Vector3(9,2,0),"neck_01":Vector3(4,0,0),"spine_01":Vector3(0,0,-2)}
	var listen_c := {"upperarm_l":Vector3(-6,0,-4),"upperarm_r":Vector3(-6,0,4),"lowerarm_r":Vector3(-22,0,0),"head":Vector3(-2,4,0)}
	# Idle variation: look left, then right, with a weight shift.
	var look_l := {"head":Vector3(0,38,0),"neck_01":Vector3(0,10,0),"spine_02":Vector3(0,8,2)}
	var look_r := {"head":Vector3(0,-34,0),"neck_01":Vector3(0,-8,0),"spine_02":Vector3(0,-8,-2)}
	return [
		["Jab",.48,false,[[0,{},0],[.09,guard,0],[.22,jab,0],[.30,jab,0],[.48,{},0]]],
		["Cross",.56,false,[[0,{},0],[.10,guard,0],[.26,cross,0],[.35,cross,0],[.56,{},0]]],
		["Kick",.78,false,[[0,{},0],[.14,guard,0],[.36,kick,0],[.48,kick,0],[.78,{},0]]],
		["Dodge",.65,false,[[0,{},0],[.16,crouch,-.35],[.45,crouch,-.35],[.65,{},0]]],
		["Hit",.45,false,[[0,{},0],[.12,hit,0],[.28,hit,0],[.45,{},0]]],
		["Wave",1.4,false,[[0,{},0],[.3,wave,0],[.55,{"upperarm_r":Vector3(0,0,100),"lowerarm_r":Vector3(-20,0,0),"hand_r":Vector3(0,0,-20)},0],[.8,wave,0],[1.05,{"upperarm_r":Vector3(0,0,100),"lowerarm_r":Vector3(-20,0,0)},0],[1.4,{},0]]],
		["Guard",.8,true,[[0,guard,0],[.4,guard,0],[.8,guard,0]]],
		["Crouch",.8,true,[[0,crouch,-.35],[.4,crouch,-.35],[.8,crouch,-.35]]],
		["Jump",.34,false,[[0,{},0],[.1,jump_dip,-.16],[.26,jump_launch,.04],[.34,air_a,0]]],
		["JumpAir",.7,true,[[0,air_a,0],[.35,air_b,0],[.7,air_a,0]]],
		["JumpLand",.5,false,[[0,air_a,0],[.1,land_deep,-.3],[.26,land_deep,-.26],[.5,land_rise,0]]],
		["HardLand",.9,false,[[0,air_a,0],[.1,land_deep,-.42],[.45,land_deep,-.4],[.9,land_rise,0]]],
		["Sit",4.0,true,[[0,sit,-.37],[2.0,sit_breath,-.37],[4.0,sit,-.37]]],
		["SitHigh",4.0,true,[[0,sit_high,-.14],[2.0,sit_high_breath,-.14],[4.0,sit_high,-.14]]],
		["Talk",2.8,true,[[0,talk_a,0],[.7,talk_b,0],[1.4,talk_c,0],[2.1,talk_d,0],[2.8,talk_a,0]]],
		["Listen",3.2,true,[[0,listen_a,0],[1.0,listen_b,0],[1.5,listen_a,0],[2.4,listen_c,0],[3.2,listen_a,0]]],
		["LookAround",3.4,false,[[0,{},0],[.7,look_l,0],[1.3,look_l,0],[2.1,look_r,0],[2.7,look_r,0],[3.4,{},0]]],
	]

static func build(human: Node3D) -> AnimationLibrary:
	var lib := AnimationLibrary.new()
	var skeleton: Skeleton3D = human.skeleton
	human.animator.play("Idle")
	human.animator.advance(0.1)
	var baseline: Dictionary = {}
	for i in skeleton.get_bone_count():
		baseline[skeleton.get_bone_name(i)] = skeleton.get_bone_pose_rotation(i)
	var skeleton_path := str(human.animator.get_node(human.animator.root_node).get_path_to(skeleton))
	var pelvis := skeleton.find_bone("pelvis")
	for spec in clips():
		var clip := Animation.new()
		clip.length = spec[1]
		if spec[2]:
			clip.loop_mode = Animation.LOOP_LINEAR
		var keys: Array = spec[3]
		for i in skeleton.get_bone_count():
			var name: String = skeleton.get_bone_name(i)
			var q0: Quaternion = baseline[name]
			if spec[0] in FIST_CLIPS and (name.begins_with("index_") or name.begins_with("middle_") or name.begins_with("ring_") or name.begins_with("pinky_")):
				q0=(q0*Quaternion(Vector3.RIGHT,.65)).normalized()
			var track := clip.add_track(Animation.TYPE_ROTATION_3D)
			clip.track_set_path(track,NodePath(skeleton_path+":"+name))
			for key in keys:
				clip.rotation_track_insert_key(track,minf(key[0],clip.length),offset(skeleton,i,q0,key[1].get(name,Vector3.ZERO)))
		var drops := false
		for key in keys:
			if key[2] != 0:
				drops = true
		if drops and pelvis >= 0:
			# The pelvis pose lives in its parent's frame, whose local Y is not world up:
			# express the vertical drop along the parent's rest-space up axis.
			var parent := skeleton.get_bone_parent(pelvis)
			var up_local := Vector3.UP if parent < 0 else skeleton.get_bone_global_rest(parent).basis.orthonormalized().inverse()*Vector3.UP
			var track := clip.add_track(Animation.TYPE_POSITION_3D)
			clip.track_set_path(track,NodePath(skeleton_path+":pelvis"))
			var base := skeleton.get_bone_pose_position(pelvis)
			for key in keys:
				clip.position_track_insert_key(track,minf(key[0],clip.length),base+up_local*key[2])
		lib.add_animation(spec[0],clip)
	return lib

static func offset(sk: Skeleton3D,id: int,base: Quaternion,degrees: Vector3) -> Quaternion:
	var parent := sk.get_bone_parent(id)
	var frame := Basis.IDENTITY if parent < 0 else sk.get_bone_global_rest(parent).basis.orthonormalized()
	var rotation := Basis.from_euler(degrees * PI / 180.0)
	return (frame.inverse()*rotation*frame*Basis(base)).get_rotation_quaternion().normalized()
