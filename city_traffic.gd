extends Node3D
var game: Node3D
var cars: Array[Dictionary] = []
var check_clock := 0.0
var random := RandomNumberGenerator.new()

func _ready() -> void:
	random.seed=86
	var paints := [Color("e9e4d6"), Color("b9342c"), Color("3b5f9a"), Color("6c7378"), Color("d9d9d4"), Color("2f2f33")]
	for i in 8:
		var car=preload("res://city_vehicle.gd").new()
		car.game=game
		# Every third vehicle is an auto-rickshaw, the rest are hatchbacks in different paints.
		car.kind="auto" if i%3==2 else "car"
		car.paint=paints[i%paints.size()]
		add_child(car)
		car.set_physics_process(false)
		car.collision_layer=4
		car.hide()
		cars.append({"node":car,"route":PackedVector3Array(),"index":0,"speed":(4.0 if car.kind=="auto" else 5.5)+i*.4})

func pick_route(car: Dictionary) -> void:
	var candidates: Array=[]
	for r in game.world.routes:
		if r.p.size()<3:
			continue
		var p:=Vector3(r.p[0][0],0,r.p[0][1])
		if Vector2(p.x-game.player.position.x,p.z-game.player.position.z).length()<240:
			candidates.append(r)
	if candidates.is_empty():
		car.node.hide()
		return
	var route: Dictionary=candidates[random.randi_range(0,candidates.size()-1)]
	var path:=PackedVector3Array()
	for i in route.p.size():
		var p:=Vector3(route.p[i][0],0,route.p[i][1])
		var next: Array=route.p[mini(i+1,route.p.size()-1)] if i<route.p.size()-1 else route.p[i-1]
		var d:=(Vector3(next[0],0,next[1])-p).normalized()
		if i==route.p.size()-1:
			d=-d
		p+=Vector3(d.z,0,-d.x)*route.width*.25
		p.y=game.world.terrain_height(p.x,p.z)+.1
		path.append(p)
	car.route=path
	car.index=1
	car.node.position=path[0]
	car.node.show()

func _physics_process(delta: float) -> void:
	check_clock-=delta
	if check_clock<=0:
		check_clock=2.0
		for car in cars:
			if car.route.is_empty() or car.node.position.distance_to(game.player.position)>300:
				pick_route(car)
	for car in cars:
		if car.route.is_empty() or not car.node.visible:
			continue
		var node: CharacterBody3D=car.node
		var destination: Vector3=car.route[car.index]
		var offset:=destination-node.position
		offset.y=0
		if offset.length()<2:
			car.index+=1
			if car.index>=car.route.size():
				car.route.reverse()
				car.index=1
			continue
		var direction:=offset.normalized()
		var obstacle: Vector3=game.player.position-node.position
		var stop:=obstacle.length()<7 and obstacle.normalized().dot(direction)>.75
		var query:=PhysicsRayQueryParameters3D.create(node.position+Vector3.UP,node.position+Vector3.UP+direction*5,5)
		query.exclude=[node.get_rid()]
		stop=stop or not get_world_3d().direct_space_state.intersect_ray(query).is_empty()
		node.velocity=direction*(0 if stop else car.speed)
		node.velocity.y=-1 if node.is_on_floor() else -12
		node.rotation.y=lerp_angle(node.rotation.y,atan2(-direction.x,-direction.z),delta*4)
		node.move_and_slide()
