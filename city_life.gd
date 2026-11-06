extends "res://market_life.gd"
var repopulate_clock := 0.0
var last_center := Vector3(99999,0,0)
# Seated cafe guests and counter staff, spawned only while the player is nearby.
var patrons: Array[Dictionary] = []
var patron_clock := 0.0

func _ready() -> void:
	name = "MarketLife"

func everyone() -> Array:
	var all: Array = []
	all.append_array(people)
	all.append_array(patrons)
	return all

func populate_near(at: Vector3) -> void:
	var candidates: Array = []
	for road in world.data.roads:
		if road.width < 5 or road.p.size()<2:
			continue
		for i in range(road.p.size()-1):
			var a := Vector3(road.p[i][0],0,road.p[i][1])
			var b := Vector3(road.p[i+1][0],0,road.p[i+1][1])
			if a.distance_to(b)<15 or Vector2(a.x-at.x,a.z-at.z).length()>110:
				continue
			var normal := Vector3(-(b-a).z,0,(b-a).x).normalized()
			var side := -1 if candidates.size()%2 else 1
			a += normal*(road.width*.5+.9)*side
			b += normal*(road.width*.5+.9)*side
			a.y = world.terrain_height(a.x,a.z)+.2
			b.y = world.terrain_height(b.x,b.z)+.2
			candidates.append([a,b])
			if candidates.size()>=18:
				break
		if candidates.size()>=18:
			break
	for i in candidates.size():
		var pair: Array = candidates[i]
		var start: Vector3 = pair[0].lerp(pair[1],float(i%5)/5)
		if i >= people.size():
			spawn(start,i+1,i%4!=0,1,"adult" if i%6 else "elder",pair)
			people[i].goal = 1
			people[i].health = 100
			people[i].home = start
		elif people[i].body.position.distance_to(at)>130:
			var p: Dictionary = people[i]
			p.body.position = start
			p.body.velocity = Vector3.ZERO
			p.route = pair
			p.goal = 1
			p.health = 100
			p.home = start
			p.defeated = false
			p.human.get_up()
			p.human.stop_action(.4)
			p.aggressive = false
			p.body.collision_layer = 2
			p.human.rotation.z = 0
	last_center = at
	update_patrons()

func update_patrons() -> void:
	for spot in world.patron_spots:
		var distance: float = spot.p.distance_to(player.position)
		if not spot.get("live",false) and distance < 120 and patrons.size() < 10:
			spawn_patron(spot)
		elif spot.get("live",false) and distance > 200:
			for p in patrons:
				if p.spot == spot:
					p.body.queue_free()
					patrons.erase(p)
					break
			spot.live = false

func spawn_patron(spot: Dictionary) -> void:
	spawn(spot.p,7+patrons.size()*3,false,1,"adult",[],spot.yaw)
	var p: Dictionary = people.pop_back()
	p.spot = spot
	p.pose = spot.pose
	p.seated = spot.pose != "Stand"
	p.health = 100
	p.home = spot.p
	p.body.position = spot.p
	p.greeting.text = "कॉफ़ी बढ़िया है!" if p.seated else "स्वागत है! क्या लेंगे?"
	if p.seated:
		p.human.play_action(spot.pose,3600.0,.01)
		p.human.animator.advance(randf_range(0,3))
	spot.live = true
	patrons.append(p)

func _physics_process(delta: float) -> void:
	if player == null:
		return
	repopulate_clock -= delta
	if repopulate_clock <= 0:
		repopulate_clock = 1.0
		if player.position.distance_to(last_center)>85:
			populate_near(player.position)
	patron_clock -= delta
	if patron_clock <= 0:
		patron_clock = 2.0
		update_patrons()
	for p in patrons:
		var nearby: bool = p.body.position.distance_to(player.position)<85
		p.human.set_process(nearby)
		p.human.animation_tree.active = nearby and not p.seated and p.human.action_left<=0
		p.greet_time = maxf(0,p.get("greet_time",0.0)-delta)
		p.cooldown = maxf(0,p.get("cooldown",0.0)-delta)
		if nearby and player.position.distance_to(p.body.position) < 2.6 and p.cooldown <= 0:
			p.greet_time = 2.5
			p.cooldown = 14.0
			p.human.set_expression("Smile",3)
		if not p.seated and p.get("stun",0.0) <= 0 and nearby and player.position.distance_to(p.body.position) < 4:
			var toward: Vector3 = player.position - p.body.position
			p.human.rotation.y = lerp_angle(p.human.rotation.y, atan2(-toward.x,-toward.z), delta*3)
		p.greeting.visible = p.greet_time > 0
		if p.get("stun",0.0) > 0:
			p.stun -= delta
	for p in people:
		var nearby: bool = p.body.position.distance_to(player.position)<85
		p.human.set_process(nearby)
		p.human.animation_tree.active = nearby and p.human.action_left<=0 and not p.get("defeated",false)
		if p.get("counter_hit_in",-1.0)>=0:
			p.counter_hit_in-=delta
			if p.counter_hit_in<0 and p.body.position.distance_to(player.position)<2.2 and not p.get("defeated",false):
				get_parent().actions.receive_hit(9)
		if p.get("aggressive",false) and not p.get("defeated",false) and nearby:
			p.counter = maxf(0,p.get("counter",1.0)-delta)
			var distance: float = p.body.position.distance_to(player.position)
			if distance < 2.1 and p.counter<=0:
				p.human.play_action("Cross")
				p.counter = 1.8
				p.counter_hit_in=.24
			elif distance > 18:
				p.aggressive = false
			elif distance > 2.0:
				p.route = [player.position]
				p.goal = 0
				p.walking = true
				p.speed = 2.1
	super._physics_process(delta)
