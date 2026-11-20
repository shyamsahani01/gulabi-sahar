extends RefCounted
## Broad-phase grid; exact rotated-footprint/segment checks still decide clearance.
const CELL := 64.0
var obstacles: Dictionary = {}
var roads: Dictionary = {}

func keys(lo: Vector2, hi: Vector2) -> Array[Vector2i]:
	var result: Array[Vector2i]=[]
	for x in range(floori(lo.x/CELL),floori(hi.x/CELL)+1):
		for y in range(floori(lo.y/CELL),floori(hi.y/CELL)+1):result.append(Vector2i(x,y))
	return result

func insert(grid: Dictionary, record: Dictionary, lo: Vector2, hi: Vector2) -> void:
	for key in keys(lo,hi):
		if not grid.has(key):grid[key]=[]
		grid[key].append(record)

func build(data: Dictionary) -> void:
	obstacles.clear()
	roads.clear()
	var id := 0
	for group in [data.buildings,data.get("amenities",[])]:
		for b in group:
			if b.has("shared_campus"):continue
			var point := Vector2(b.x,b.z) if b.has("x") else Vector2(b.p[0],b.p[1])
			var half := Vector2(b.w,b.d)*.5
			var c := absf(cos(b.a))
			var s := absf(sin(b.a))
			var extent := Vector2(c*half.x+s*half.y,s*half.x+c*half.y)
			insert(obstacles,{"id":id,"p":point,"half":half,"a":b.a},point-extent,point+extent)
			id+=1
	id=0
	for road in data.roads:
		for i in range(road.p.size()-1):
			var a:=Vector2(road.p[i][0],road.p[i][1])
			var b:=Vector2(road.p[i+1][0],road.p[i+1][1])
			var width: float=road.segment_widths[i] if road.has("segment_widths") else road.width
			var pad:=Vector2.ONE*width*.5
			insert(roads,{"id":id,"a":a,"b":b,"half":width*.5},a.min(b)-pad,a.max(b)+pad)
			id+=1

func nearby(grid: Dictionary, point: Vector2, margin: float) -> Array:
	var found := {}
	for key in keys(point-Vector2.ONE*margin,point+Vector2.ONE*margin):
		for record in grid.get(key,[]):found[record.id]=record
	return found.values()

func obstacles_clear(point: Vector2, margin: float) -> bool:
	# Rotated padding can extend sqrt(2)*margin in world axes.
	for b in nearby(obstacles,point,margin*1.415):
		var local: Vector2=(point-b.p).rotated(b.a)
		if absf(local.x)<b.half.x+margin and absf(local.y)<b.half.y+margin:return false
	return true

func roads_clear(point: Vector2, margin: float) -> bool:
	for r in nearby(roads,point,margin):
		if Geometry2D.get_closest_point_to_segment(point,r.a,r.b).distance_to(point)<r.half+margin:return false
	return true
