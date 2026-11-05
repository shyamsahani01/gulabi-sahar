extends RefCounted
# Authored full-rig action clips. Locomotion remains the user's existing mocap.
# Rotations are expressed in skeleton/world axes, then converted to the bone parent frame.
static func build(human: Node3D) -> AnimationLibrary:
	var lib := AnimationLibrary.new()
	var skeleton: Skeleton3D = human.skeleton
	human.animator.play("Idle")
	human.animator.advance(0.1)
	var baseline: Dictionary = {}
	for i in skeleton.get_bone_count():
		baseline[skeleton.get_bone_name(i)] = skeleton.get_bone_pose_rotation(i)
	var guard := {"upperarm_l":Vector3(-35,0,-12),"lowerarm_l":Vector3(-65,0,0),"upperarm_r":Vector3(-35,0,12),"lowerarm_r":Vector3(-65,0,0),"spine_01":Vector3(5,0,0)}
	var jab := guard.duplicate()
	jab.merge({"upperarm_l":Vector3(-80,-12,0),"lowerarm_l":Vector3(-12,0,0),"spine_01":Vector3(6,-18,0)},true)
	var cross := guard.duplicate()
	cross.merge({"upperarm_r":Vector3(-85,15,0),"lowerarm_r":Vector3(-8,0,0),"spine_01":Vector3(8,25,0)},true)
	var kick := guard.duplicate()
	kick.merge({"thigh_r":Vector3(-82,0,0),"calf_r":Vector3(12,0,0),"spine_01":Vector3(-12,-10,0)},true)
	var crouch := {"thigh_l":Vector3(-48,0,0),"thigh_r":Vector3(-48,0,0),"calf_l":Vector3(85,0,0),"calf_r":Vector3(85,0,0),"spine_01":Vector3(24,0,0),"upperarm_l":Vector3(-30,0,0),"upperarm_r":Vector3(-30,0,0)}
	var jump := {"thigh_l":Vector3(-28,0,0),"thigh_r":Vector3(-45,0,0),"calf_l":Vector3(48,0,0),"calf_r":Vector3(65,0,0),"upperarm_l":Vector3(-42,0,-15),"upperarm_r":Vector3(-42,0,15)}
	var hit := {"spine_01":Vector3(-18,12,0),"neck_01":Vector3(-15,0,0),"upperarm_l":Vector3(15,0,-20),"upperarm_r":Vector3(15,0,20)}
	var wave := {"upperarm_r":Vector3(0,0,100),"lowerarm_r":Vector3(-50,0,0),"hand_r":Vector3(0,0,20)}
	for spec in [["Jab",.48,guard,jab],["Cross",.56,guard,cross],["Kick",.78,guard,kick],["Dodge",.65,{},crouch],["Jump",.7,{},jump],["Hit",.45,{},hit],["Wave",1.4,{},wave],["Guard",.8,guard,guard],["Crouch",.8,crouch,crouch]]:
		var clip := Animation.new()
		clip.length = spec[1]
		if spec[0] in ["Guard","Crouch"]:
			clip.loop_mode = Animation.LOOP_LINEAR
		for i in skeleton.get_bone_count():
			var name: String = skeleton.get_bone_name(i)
			var track := clip.add_track(Animation.TYPE_ROTATION_3D)
			clip.track_set_path(track,NodePath(str(human.animator.get_node(human.animator.root_node).get_path_to(skeleton))+":"+name))
			var q0: Quaternion = baseline[name]
			if spec[0] in ["Jab","Cross","Kick","Guard"] and (name.begins_with("index_") or name.begins_with("middle_") or name.begins_with("ring_") or name.begins_with("pinky_")):
				q0=(q0*Quaternion(Vector3.RIGHT,.65)).normalized()
			var start := offset(skeleton,i,q0,spec[2].get(name,Vector3.ZERO))
			var peak := offset(skeleton,i,q0,spec[3].get(name,Vector3.ZERO))
			clip.rotation_track_insert_key(track,0,q0 if spec[0] not in ["Guard","Crouch"] else start)
			clip.rotation_track_insert_key(track,clip.length*.18,start)
			clip.rotation_track_insert_key(track,clip.length*.46,peak)
			clip.rotation_track_insert_key(track,clip.length*.62,peak)
			clip.rotation_track_insert_key(track,clip.length,start if spec[0] in ["Guard","Crouch"] else q0)
		if spec[0] in ["Crouch","Dodge"]:
			var id:=skeleton.find_bone("pelvis")
			var track:=clip.add_track(Animation.TYPE_POSITION_3D)
			clip.track_set_path(track,NodePath(str(human.animator.get_node(human.animator.root_node).get_path_to(skeleton))+":pelvis"))
			var base:=skeleton.get_bone_pose_position(id)
			var lowered:=base+Vector3(0,-.35,0)
			clip.position_track_insert_key(track,0,lowered if spec[0]=="Crouch" else base)
			clip.position_track_insert_key(track,clip.length*.25,lowered)
			clip.position_track_insert_key(track,clip.length*.7,lowered)
			clip.position_track_insert_key(track,clip.length,lowered if spec[0]=="Crouch" else base)
		lib.add_animation(spec[0],clip)
	return lib

static func offset(sk: Skeleton3D,id: int,base: Quaternion,degrees: Vector3) -> Quaternion:
	var parent := sk.get_bone_parent(id)
	var frame := Basis.IDENTITY if parent < 0 else sk.get_bone_global_rest(parent).basis.orthonormalized()
	var rotation := Basis.from_euler(degrees * PI / 180.0)
	return (frame.inverse()*rotation*frame*Basis(base)).get_rotation_quaternion().normalized()
