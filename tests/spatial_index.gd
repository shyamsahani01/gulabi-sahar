extends SceneTree
func _initialize() -> void:
	var rng:=RandomNumberGenerator.new()
	rng.seed=22
	var data: Dictionary={"buildings":[],"amenities":[],"roads":[]}
	for i in 180:
		data.buildings.append({"x":rng.randf_range(-320,320),"z":rng.randf_range(-320,320),"w":rng.randf_range(2,80),"d":rng.randf_range(2,35),"a":rng.randf_range(-PI,PI)})
	for i in 40:
		data.roads.append({"p":[[rng.randf_range(-400,400),rng.randf_range(-400,400)],[rng.randf_range(-400,400),rng.randf_range(-400,400)]],"width":rng.randf_range(4,30)})
	var index=load("res://city_spatial_index.gd").new()
	index.build(data)
	var failures:=0
	for i in 2000:
		var point:=Vector2(rng.randf_range(-450,450),rng.randf_range(-450,450))
		var margin:=rng.randf_range(0,12)
		var clear:=true
		for b in data.buildings:
			var local: Vector2=(point-Vector2(b.x,b.z)).rotated(b.a)
			if absf(local.x)<b.w*.5+margin and absf(local.y)<b.d*.5+margin:clear=false;break
		if index.obstacles_clear(point,margin)!=clear:failures+=1
		clear=true
		for r in data.roads:
			if Geometry2D.get_closest_point_to_segment(point,Vector2(r.p[0][0],r.p[0][1]),Vector2(r.p[1][0],r.p[1][1])).distance_to(point)<r.width*.5+margin:clear=false;break
		if index.roads_clear(point,margin)!=clear:failures+=1
	print("SPATIAL INDEX RESULT: ",failures," failures / 4000 brute-force comparisons")
	quit(1 if failures else 0)
