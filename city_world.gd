extends "res://world.gd"
# OSM source geometry is preserved on disk; the playable layout is 12% shorter.
const CITY_COMPRESSION := 0.88
var services: Array = []
var service_builder = preload("res://city_services.gd").new()
const CELL := 160.0
var data: Dictionary
var cells: Dictionary = {}
var road_meshes: Dictionary = {}
var player_ref: Node3D
var stream_clock := 0.0
var building_count := 0
var active_cells := 0
var draw_detail := false
var sphere_mesh := SphereMesh.new()
var map_bounds := Rect2(-2900, -4200, 5000, 4950)
var landmarks: Array = []
var routes: Array = []
var authored_roads: Array = []
var spawn_point := Vector3(25, 1, 0)

func _ready() -> void:
	add_child(collision_root)
	cube.size = Vector3.ONE
	sphere_mesh.radius=.5
	sphere_mesh.height=1
	sphere_mesh.radial_segments=12
	sphere_mesh.rings=6
	data = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/jaipur_city.json"))
	compact_layout()
	landmarks = data.pois
	service_builder.world = self
	service_builder.assign(data,CITY_COMPRESSION)
	make_materials()
	make_city_materials()
	# Less aggressive surface relief removes the sandpaper shimmer seen on the tablet.
	for key in mats:
		mats[key].normal_scale *= 0.32
		mats[key].texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	lighting()
	mats["sand"].albedo_color=Color("b8b4a2")
	mats["scrub"].albedo_color=Color("84947b")
	for key in ["hm_pink","rose","terracotta","fort"]:
		mats[key].normal_enabled=false
		mats[key].albedo_texture=load("res://assets/textures/paintedwall_Diffuse.jpg")
	mats["hm_pink"].albedo_color=Color("c98c76")
	mats["rose"].albedo_color=Color("cc9b87")
	mats["terracotta"].albedo_color=Color("b98069")
	mats["fort"].albedo_color=Color("aa9a7c")
	for child in get_children():
		if child is WorldEnvironment:
			child.environment.ambient_light_energy=.52
			child.environment.tonemap_exposure=.85
			child.environment.fog_density=.0013
			child.environment.adjustment_saturation=.94
	build_ground()
	build_roads()
	for b in data.buildings:
		if Vector2(b.x-495*CITY_COMPRESSION,b.z+760*CITY_COMPRESSION).length()<105*CITY_COMPRESSION:
			continue
		city_building(b)
		building_count += 1
	var order := ["showroom","hospital","police","theka","grocery","chai"]
	services.sort_custom(func(a,b): return order.find(a.kind)<order.find(b.kind))
	var details=preload("res://street_details.gd").new()
	details.world=self
	for i in services.size():
		details.build(services[i].building,services[i].rotation,i)
	build_parks()
	build_landmarks()
	flush_batches()
	flush_road_meshes()
	batches.clear()
	road_meshes.clear()
	update_cells(spawn_point)

func compact_layout() -> void:
	map_bounds = Rect2(map_bounds.position*CITY_COMPRESSION,map_bounds.size*CITY_COMPRESSION)
	spawn_point.x *= CITY_COMPRESSION
	spawn_point.z *= CITY_COMPRESSION
	for road in data.roads:
		road.width *= CITY_COMPRESSION
		for p in road.p:
			p[0] *= CITY_COMPRESSION
			p[1] *= CITY_COMPRESSION
	for b in data.buildings:
		for key in ["x","z","w","d"]:
			b[key] *= CITY_COMPRESSION
	for park in data.parks:
		for p in park.p:
			p[0] *= CITY_COMPRESSION
			p[1] *= CITY_COMPRESSION
	for poi in data.pois:
		poi.p[0] *= CITY_COMPRESSION
		poi.p[1] *= CITY_COMPRESSION
	for line in data.navigation:
		for p in line:
			p[0] *= CITY_COMPRESSION
			p[1] *= CITY_COMPRESSION

func make_city_materials() -> void:
	for pair in [["shop_glass","779b9e"],["warm_light","ffe6b3"],["chrome","bac5c8"],["tile","c7cec8"],["grout","89958e"]]:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(pair[1])
		mat.roughness = .28
		mats[pair[0]] = mat
	mats["shop_glass"].transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mats["shop_glass"].albedo_color.a = .20
	mats["shop_glass"].cull_mode = BaseMaterial3D.CULL_DISABLED
	mats["warm_light"].emission_enabled = true
	mats["warm_light"].emission = Color("ffe6b3")
	mats["chrome"].metallic = .7
	mats["glass"].albedo_color = Color("35535c")
	mats["glass"].metallic = .08
	mats["glass"].roughness = .45
	mats["stone"].albedo_texture = preload("res://assets/textures/pavement05_diff.jpg")
	mats["stone"].normal_texture = preload("res://assets/textures/pavement05_nor_gl.jpg")
	mats["stone"].roughness_texture = preload("res://assets/textures/pavement05_rough.jpg")
	mats["stone"].uv1_scale = Vector3.ONE/3.4
	mats["stone"].albedo_color = Color("b8b6a9")
	mats["stone"].normal_scale = .20
	mats["tile"].roughness = .55
	# Quieter road surfaces leave silhouette, signs and traffic readable at tablet scale.
	mats["tarmac"].albedo_color = Color("4d5255")
	mats["tarmac"].normal_enabled = false
	mats["tarmac"].uv1_scale = Vector3.ONE*.10

func destinations() -> Array:
	return landmarks + services

func cell_key(pos: Vector3) -> Vector2i:
	return Vector2i(floori(pos.x / CELL), floori(pos.z / CELL))

func cell(pos: Vector3) -> Node3D:
	var id := cell_key(pos)
	if not cells.has(id):
		var node := Node3D.new()
		node.name = "Cell_%d_%d" % [id.x, id.y]
		add_child(node)
		var body := StaticBody3D.new()
		body.name = "Collision"
		node.add_child(body)
		cells[id] = node
	return cells[id]

func box(pos: Vector3, dimensions: Vector3, key: String, solid := false, rot := Vector3.ZERO) -> void:
	var id := cell_key(pos)
	var bucket := "%d,%d|%s|%d" % [id.x, id.y, key, int(draw_detail)]
	if not batches.has(bucket):
		batches[bucket] = []
	batches[bucket].append(Transform3D(Basis.from_euler(rot) * Basis.from_scale(dimensions), pos))
	if solid:
		var shape := CollisionShape3D.new()
		var bounds := BoxShape3D.new()
		bounds.size = dimensions
		shape.shape = bounds
		shape.position = pos
		shape.rotation = rot
		cell(pos).get_node("Collision").add_child(shape)

func flush_batches() -> void:
	for bucket in batches:
		var parts: PackedStringArray = bucket.split("|")
		var transforms: Array = batches[bucket]
		var multi := MultiMesh.new()
		multi.transform_format = MultiMesh.TRANSFORM_3D
		multi.mesh = sphere_mesh if parts.size()>3 else cube
		multi.instance_count = transforms.size()
		for i in transforms.size():
			multi.set_instance_transform(i, transforms[i])
		var mesh := MultiMeshInstance3D.new()
		mesh.multimesh = multi
		mesh.material_override = mats[parts[1]]
		mesh.visibility_range_end = 240 if parts[2] == "1" else 620
		mesh.visibility_range_end_margin = 20
		cell(transforms[0].origin).add_child(mesh)

func terrain_height(x: float,z: float) -> float:
	# Sample the same triangles used by collision; roads and props cannot float.
	var step:=25.0
	var gx:=floorf(x/step)*step
	var gz:=floorf(z/step)*step
	var fx:=(x-gx)/step
	var fz:=(z-gz)/step
	var a:=terrain_raw(gx,gz)
	var b:=terrain_raw(gx+step,gz)
	var c:=terrain_raw(gx,gz+step)
	if fx+fz<=1:
		return a+(b-a)*fx+(c-a)*fz
	var d:=terrain_raw(gx+step,gz+step)
	return d+(c-d)*(1-fx)+(b-d)*(1-fz)

func terrain_raw(x: float,z: float) -> float:
	# Artistic Aravalli ridge. Low gradient keeps every mapped hill road drivable.
	x /= CITY_COMPRESSION
	z /= CITY_COMPRESSION
	var rise := exp(-pow((x - 680.0) / 560.0, 2) - pow((z + 1060.0) / 900.0, 2))
	var shoulder := smoothstep(160.0, 510.0, x) * smoothstep(-250.0, -650.0, z)
	var hill:=rise*shoulder*95.0
	var plateau:=1-smoothstep(85.0,170.0,Vector2(x-495,z+760).length())
	return lerpf(hill,66.0,plateau)

func build_ground() -> void:
	var step := 25.0
	for cx in range(-3000, 2200, 400):
		for cz in range(-4300, 900, 400):
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			for ix in 16:
				for iz in 16:
					var x: float = cx + ix * step
					var z: float = cz + iz * step
					var a := Vector3(x, terrain_height(x,z), z)
					var b := Vector3(x + step, terrain_height(x+step,z), z)
					var c := Vector3(x, terrain_height(x,z+step), z+step)
					var d := Vector3(x+step, terrain_height(x+step,z+step), z+step)
					for v in [a,b,c,b,d,c]:
						st.set_uv(Vector2(v.x,v.z)*0.04)
						st.add_vertex(v)
			st.generate_normals()
			var mesh := MeshInstance3D.new()
			mesh.mesh = st.commit()
			mesh.material_override = mats["scrub"] if cx > 200 and cz < -300 else mats["sand"]
			add_child(mesh)
			mesh.create_trimesh_collision()
	# Boundaries stop traversal beyond the imported area.
	for spec in [[Vector3(-2900,80,-1725),Vector3(2,400,4950)],[Vector3(2100,80,-1725),Vector3(2,400,4950)],[Vector3(-400,80,-4200),Vector3(5000,400,2)],[Vector3(-400,80,750),Vector3(5000,400,2)]]:
		var p: Vector3 = spec[0]
		var dimensions: Vector3 = spec[1]
		p.x *= CITY_COMPRESSION
		p.z *= CITY_COMPRESSION
		dimensions.x *= CITY_COMPRESSION
		dimensions.z *= CITY_COMPRESSION
		box(p,dimensions,"sand",true)

func road_piece(a: Vector2, b: Vector2, width: float, key: String, lift: float) -> void:
	var direction := (b-a).normalized()
	var side := Vector2(-direction.y,direction.x)*width*0.5
	var mid := Vector3((a.x+b.x)*0.5,0,(a.y+b.y)*0.5)
	var id := cell_key(mid)
	var bucket := "%d,%d|%s" % [id.x,id.y,key]
	if not road_meshes.has(bucket):
		road_meshes[bucket] = {"v": PackedVector3Array(), "uv": PackedVector2Array(), "at":mid}
	var entry: Dictionary = road_meshes[bucket]
	for p in [a-side,b-side,a+side,b-side,b+side,a+side]:
		entry.v.append(Vector3(p.x,terrain_height(p.x,p.y)+lift,p.y))
		entry.uv.append(p*0.08)

func build_roads() -> void:
	for road in data.roads:
		var points: Array = road.p
		if points.size() < 2:
			continue
		if road.kind in ["primary","secondary","tertiary","trunk"]:
			routes.append(road)
		var authored: bool = road.get("source","osm") == "authored"
		if authored:
			authored_roads.append(road)
			mark_connector(road)
		for i in range(points.size()-1):
			var a := Vector2(points[i][0],points[i][1])
			var b := Vector2(points[i+1][0],points[i+1][1])
			if a.distance_to(b)>500 or not map_bounds.has_point(a):
				continue
			var count := maxi(1,ceili(a.distance_to(b)/12.0))
			for j in count:
				var p := a.lerp(b,float(j)/count)
				var q := a.lerp(b,float(j+1)/count)
				road_piece(p,q,road.width+3.0,"kerb_yellow" if authored else "stone",0.035)
				road_piece(p,q,road.width,"tarmac",0.06)
				if authored:
					road_piece(p.lerp(q,0.2),p.lerp(q,0.6),0.3,"kerb_black",0.075)
				if road.width >= 10*CITY_COMPRESSION and j%2 == 0:
					road_piece(p.lerp(q,0.1),p.lerp(q,0.65),0.16,"cream",0.075)
			if road.width >= 10*CITY_COMPRESSION and i % 4 == 0:
				var d := (b-a).normalized()
				var at: Vector2 = a + Vector2(-d.y,d.x)*(road.width*0.5+1)
				var y := terrain_height(at.x,at.y)
				draw_detail = true
				box(Vector3(at.x,y+3,at.y),Vector3(.12,6,.12),"metal")
				box(Vector3(at.x,y+6,at.y),Vector3(1,.1,.35),"cream")
				draw_detail = false
				if i%8==0:
					tree_at(Vector3(at.x,y,at.y))
				if i%12==0:
					market_cart(Vector3(at.x,y,at.y)+Vector3(2,0,0),int(road.id)%4)

func mark_connector(road: Dictionary) -> void:
	# Authored game-only link (not in OSM): yellow kerbs, striped bollards and a sign at
	# both ends so players and reviewers can tell it apart from the real street network.
	var points: Array = road.p
	var ends := [Vector2(points[0][0],points[0][1]),Vector2(points[-1][0],points[-1][1])]
	for k in 2:
		var at: Vector2 = ends[k]
		var toward: Vector2 = Vector2(points[1][0],points[1][1]) if k == 0 else Vector2(points[-2][0],points[-2][1])
		var d := (toward-at).normalized()
		var width: float = road.width
		var side: Vector2 = Vector2(-d.y,d.x)*(width*0.5+1.2)
		for s in [-1,1]:
			var foot: Vector2 = at+side*s
			var y := terrain_height(foot.x,foot.y)
			box(Vector3(foot.x,y+.45,foot.y),Vector3(.3,.9,.3),"kerb_yellow",true)
			box(Vector3(foot.x,y+.95,foot.y),Vector3(.32,.12,.32),"kerb_black")
			box(Vector3(foot.x,y+.3,foot.y),Vector3(.32,.12,.32),"kerb_black")
		var post: Vector2 = at-side+d*1.5
		var ground := terrain_height(post.x,post.y)
		box(Vector3(post.x,ground+1.5,post.y),Vector3(.1,3,.1),"metal",true)
		box(Vector3(post.x,ground+2.9,post.y),Vector3(2.4,.9,.08),"kerb_yellow",false,Vector3(0,atan2(-d.y,-d.x),0))
		var sign := Label3D.new()
		sign.font = hindi_font
		sign.text = "खेल मार्ग · GAME CONNECTOR\nNahargarh link · not a real road"
		sign.font_size = 30
		sign.pixel_size = .0045
		sign.modulate = Color("1d1d1d")
		sign.position = Vector3(post.x,ground+2.9,post.y)
		sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sign.no_depth_test = false
		sign.visibility_range_end = 120
		cell(sign.position).add_child(sign)

func flush_road_meshes() -> void:
	for bucket in road_meshes:
		var entry: Dictionary = road_meshes[bucket]
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = entry.v
		arrays[Mesh.ARRAY_TEX_UV] = entry.uv
		var normals := PackedVector3Array()
		normals.resize(entry.v.size())
		normals.fill(Vector3.UP)
		arrays[Mesh.ARRAY_NORMAL] = normals
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		var instance := MeshInstance3D.new()
		instance.mesh = mesh
		instance.material_override = mats[bucket.split("|")[1]]
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		cell(entry.at).add_child(instance)

func city_building(b: Dictionary) -> void:
	if b.has("service"):
		service_builder.build(b)
		return
	var base := Vector3(b.x,terrain_height(b.x,b.z),b.z)
	var basis := Basis(Vector3.UP,b.a)
	var old: bool = b.z > -1000 and b.x > -850
	var color: String = ["rose","hm_pink","terracotta","ochre"][int(abs(b.x+b.z))%4] if old else ["cream","white","concrete","ivory"][int(abs(b.x+b.z))%4]
	var height: float = b.h
	box(base+Vector3(0,.025,0),Vector3(b.w+1.5,.05,b.d+1.5),"stone",false,Vector3(0,b.a,0))
	box(base+Vector3(0,height/2,0),Vector3(b.w,height,b.d),color,true,Vector3(0,b.a,0))
	box(base+Vector3(0,height+.12,0),Vector3(b.w+.5,.24,b.d+.5),"cream",false,Vector3(0,b.a,0))
	draw_detail = true
	for side in [-1,1]:
		var front: float = side*(b.d/2+.06)
		for floor_index in range(mini(4,int(height/3))):
			for bay in range(maxi(1,mini(4,int(b.w/3)))):
				var x: float = -b.w/2+1.7+bay*2.8
				var y := 1.5+floor_index*3
				box(base+basis*Vector3(x,y,front),Vector3(1.2,1.65,.09),"dark" if old else "glass",false,Vector3(0,b.a,0))
				box(base+basis*Vector3(x,y+1.0,front+side*.18),Vector3(1.65,.13,.6),"trim",false,Vector3(0,b.a,0))
		if old:
			box(base+basis*Vector3(0,2.7,front+side*.8),Vector3(b.w*.9,.13,1.7),"teal" if int(b.x)%2 else "maroon",false,Vector3(0,b.a,0))
			box(base+basis*Vector3(0,3.1,front),Vector3(b.w*.8,.45,.15),"dark",false,Vector3(0,b.a,0))
		else:
			box(base+basis*Vector3(0,3.2,front+side*.4),Vector3(b.w*.8,.2,1.0),"white",false,Vector3(0,b.a,0))
	if b.source == "infill":
		var bays := maxi(1,mini(3,int(b.w/3.0)))
		var bw: float = (b.w-.6)/bays
		for side in [-1,1]:
			var front: float = side*(b.d/2+.13)
			for bay in bays:
				var x: float = -b.w/2+.3+bw*(bay+.5)
				box(base+basis*Vector3(x,1.25,front),Vector3(bw-.18,2.4,.12),"glass",false,Vector3(0,b.a,0))
				box(base+basis*Vector3(x,1.2,front+side*.08),Vector3(.055,2.4,.08),"trim",false,Vector3(0,b.a,0))
				box(base+basis*Vector3(x,.22,front+side*.12),Vector3(bw-.1,.2,.3),"trim",false,Vector3(0,b.a,0))
			if Vector2(b.x,b.z).length()<160:
				var label := Label3D.new()
				label.text = ["PINK CITY TEXTILES","JAIPUR CRAFTS","MOHAN SWEETS","SAHAR PHARMACY","ROYAL FOOTWEAR","DAILY NEEDS"][int(abs(b.x+b.z))%6]
				label.font_size=26
				label.pixel_size=.005
				label.position=base+basis*Vector3(0,3.08,front+side*.12)
				label.rotation.y=b.a+(PI if side<0 else 0.0)
				label.visibility_range_end=75
				cell(base).add_child(label)
	# Rooftop water tank, parapet and solar panel silhouettes.
	box(base+basis*Vector3(b.w*.25,height+.55,b.d*.2),Vector3(1.1,1.1,1.1),"dark")
	box(base+basis*Vector3(-b.w*.2,height+.3,0),Vector3(2,.12,1.3),"blue",false,Vector3(.18,b.a,0))
	draw_detail = false

func build_parks() -> void:
	for park_data in data.parks:
		var points := PackedVector2Array()
		for p in park_data.p:
			points.append(Vector2(p[0],p[1]))
		if points.size()<3:
			continue
		var center := Vector2.ZERO
		for p in points:
			center += p
		center /= points.size()
		if not map_bounds.has_point(center):
			continue
		var indices := Geometry2D.triangulate_polygon(points)
		if indices.is_empty():
			continue
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for index in indices:
			var p := points[index]
			st.set_normal(Vector3.UP)
			st.add_vertex(Vector3(p.x,terrain_height(p.x,p.y)+.08,p.y))
		var m := MeshInstance3D.new()
		m.mesh = st.commit()
		m.material_override = mats["grass"]
		cell(Vector3(center.x,0,center.y)).add_child(m)
		for i in range(0,points.size(),maxi(1,points.size()/8)):
			var p := points[i].lerp(center,.15)
			var at:=Vector3(p.x,terrain_height(p.x,p.y),p.y)
			tree_at(at)
			box(at+Vector3(2,.55,0),Vector3(1.8,.16,.6),"wood")
			box(at+Vector3(2,.95,.3),Vector3(1.8,.65,.12),"wood")
			for side in [-1,1]:
				box(at+Vector3(2+side*.65,.25,0),Vector3(.1,.5,.45),"metal")
		var ground:=terrain_height(center.x,center.y)
		box(Vector3(center.x,ground+.06,center.y),Vector3(12,.1,8),"sand")
		for side in [-1,1]:
			box(Vector3(center.x+side*4,ground+1.5,center.y),Vector3(.12,3,.12),"blue")
		box(Vector3(center.x,ground+3,center.y),Vector3(8,.12,.12),"blue")
		for side in [-1,1]:
			box(Vector3(center.x+side*1.7,ground+1.8,center.y),Vector3(.04,2.4,.04),"metal")
		box(Vector3(center.x,ground+.6,center.y),Vector3(3.5,.12,.6),"terracotta")

func tree_at(at: Vector3) -> void:
	box(at+Vector3(0,1.6,0),Vector3(.35,3.2,.35),"wood")
	for i in 3:
		round_prop(at+Vector3(sin(i*2)*.8,3.4+i*.7,cos(i*2)*.8),Vector3(3.3-i*.45,2.6,3.3-i*.45),"leaves" if i%2 else "leaves_light")

func build_landmarks() -> void:
	for poi in landmarks:
		var p := Vector3(poi.p[0],terrain_height(poi.p[0],poi.p[1]),poi.p[1])
		var sign := Label3D.new()
		sign.font = hindi_font
		sign.text = poi.hindi+"\n"+poi.name
		sign.font_size = 32
		sign.pixel_size = .006
		sign.position = p+Vector3(-8,2.5,-6)
		sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sign.visibility_range_end = 100
		cell(p).add_child(sign)
		# Transit marker at every destination, also used for mission/checkpoint routes.
		box(p+Vector3(0,.08,0),Vector3(3,.1,3),"kerb_yellow")
		if poi.kind == "gate":
			for side in [-1,1]:
				box(p+Vector3(0,5,side*12),Vector3(7,10,7),"hm_pink",true)
				box(p+Vector3(0,10.4,side*12),Vector3(8,.6,8),"cream")
			for side in [-1,1]:
				for level in [3.0,6.0,8.5]:
					box(p+Vector3(3.54,level,side*12),Vector3(.12,1.8,1.3),"dark")
					box(p+Vector3(3.7,level+1,side*12),Vector3(.6,.15,2),"trim")
				round_prop(p+Vector3(0,11.5,side*12),Vector3(4.5,2.2,4.5),"cream")
			box(p+Vector3(0,9.8,0),Vector3(5,2.2,24),"hm_pink")
			for i in range(-12,13,2):
				box(p+Vector3(0,11.5,i),Vector3(5,.7,.65),"cream")
		elif poi.kind == "fort":
			# Courtyard set to the east of the road, with ramparts and bastions.
			p += Vector3(45,0,0)
			for side in [-1,1]:
				box(p+Vector3(side*30,4,0),Vector3(2,8,65),"fort",true)
				for edge in [-1,1]:
					box(p+Vector3(edge*18,4,side*32),Vector3(24,8,2),"fort",true)
				for k in range(-30,31,3):
					box(p+Vector3(side*30,8.6,k),Vector3(2.5,1.2,1.5),"fort")
			box(p+Vector3(0,3,-20),Vector3(38,6,12),"cream",true)
			for i in range(-3,4):
				box(p+Vector3(i*5,3,-13.8),Vector3(2.6,4,.2),"dark")
				box(p+Vector3(i*5,6.6,-20),Vector3(3,1,7),"fort")

func district_at(at: Vector3) -> Dictionary:
	at /= CITY_COMPRESSION
	if at.x > 180 and at.z < -450:
		return {"id":"hills","name":"Nahargarh / Brahmpuri","hindi":"नाहरगढ़ की पहाड़ियाँ"}
	if at.z < -2050:
		return {"id":"vdn","name":"Vidhyadhar Nagar","hindi":"विद्याधर नगर"}
	if at.x < -1700:
		return {"id":"sikar","name":"Sikar Road","hindi":"सीकर रोड"}
	if at.z < -650:
		return {"id":"shastri","name":"Shastri Nagar","hindi":"शास्त्री नगर"}
	return {"id":"chandpole","name":"Chandpole Bazaar","hindi":"चाँदपोल बाज़ार"}

func update_cells(at: Vector3) -> void:
	active_cells = 0
	for id in cells:
		var c: Node3D = cells[id]
		var center := Vector3((id.x+.5)*CELL,at.y,(id.y+.5)*CELL)
		var distance := center.distance_to(at)
		c.visible = distance < 700
		var body: StaticBody3D = c.get_node("Collision")
		body.collision_layer = 1 if distance < 340 else 0
		if c.visible:
			active_cells += 1

func _process(delta: float) -> void:
	stream_clock -= delta
	if stream_clock <= 0 and player_ref != null:
		stream_clock = .3
		update_cells(player_ref.global_position)

var road_graph: AStar3D
func route_between(start: Vector3,finish: Vector3) -> PackedVector3Array:
	if road_graph==null:
		road_graph=AStar3D.new()
		var ids: Dictionary={}
		for line in data.navigation:
			var previous := -1
			for p in line:
				var key := Vector2i(roundi(p[0]),roundi(p[1]))
				if not ids.has(key):
					ids[key]=ids.size()
					road_graph.add_point(ids[key],Vector3(p[0],0,p[1]))
				var id: int=ids[key]
				if previous>=0 and previous!=id:
					road_graph.connect_points(previous,id)
				previous=id
	var a:=road_graph.get_closest_point(Vector3(start.x,0,start.z))
	var b:=road_graph.get_closest_point(Vector3(finish.x,0,finish.z))
	return road_graph.get_point_path(a,b)

func round_prop(pos: Vector3,dimensions: Vector3,key: String) -> void:
	var id:=cell_key(pos)
	var bucket:="%d,%d|%s|0|sphere"%[id.x,id.y,key]
	if not batches.has(bucket):
		batches[bucket]=[]
	batches[bucket].append(Transform3D(Basis.IDENTITY.scaled(dimensions),pos))

func market_cart(at: Vector3,index: int) -> void:
	draw_detail=true
	box(at+Vector3(0,.75,0),Vector3(1.6,.2,1),"wood")
	for side in [-1,1]:
		box(at+Vector3(side*.7,1.4,0),Vector3(.06,1.6,.06),"metal")
		for z in [-.35,.35]:
			round_prop(at+Vector3(side*.65,.35,z),Vector3(.14,.5,.5),"dark")
	box(at+Vector3(0,2.2,0),Vector3(2.1,.1,1.6),"maroon" if index%2 else "teal")
	for i in 6:
		round_prop(at+Vector3(-.6+i*.23,.95,0),Vector3(.22,.25,.3),"orange" if index%2 else "green")
	var sign:=Label3D.new()
	sign.text=["GULABI CHAI","FRESH FRUIT","JAIPUR CRAFTS","KACHORI HOUSE"][index]
	sign.font_size=32
	sign.pixel_size=.004
	sign.position=at+Vector3(0,2.5,0)
	sign.billboard=BaseMaterial3D.BILLBOARD_ENABLED
	sign.visibility_range_end=65
	cell(at).add_child(sign)
	draw_detail=false
