extends "res://world.gd"
# VKI–VDN only. Archived Jaipur data remains available to the import tools.
const CITY_COMPRESSION := 0.88
const CITY_DATA_PATH := "res://assets/data/vki_vdn_city_small.json"
signal build_progress(fraction: float, stage: String)
signal world_built
var incremental_startup := false
var build_finished := false
var startup_timings: Array = []
var checkpoint_time := 0
var stage_started := 0
var stage_name := ""
var spatial = preload("res://city_spatial_index.gd").new()
var services: Array = []
var seats: Array = []
var patron_spots: Array = []
var pedestrian_routes: Array = []
var architecture_meshes: Dictionary = {}
var restaurant_entries: Array = []
var palace_entry: Dictionary = {}
var dining_destinations: Array = []
var park_destinations: Array = []
var place_interactions: Array = []
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
var map_bounds := Rect2(-2850, -5100, 1950, 2750)
var landmarks: Array = []
var routes: Array = []
var authored_roads: Array = []
var amenities: Array = []
var amenity_count := 0
var spawn_point := Vector3(-1591.05, 1, -2843.67)
var spawn_heading := 0.0
const MAP_EDITION := "vki-vdn-focused-v2"

func _ready() -> void:
	checkpoint_time=Time.get_ticks_msec()
	stage_started=checkpoint_time
	await loading_checkpoint(.0,"Reading city map",true)
	add_child(collision_root)
	cube.size = Vector3.ONE
	sphere_mesh.radius=.5
	sphere_mesh.height=1
	sphere_mesh.radial_segments=12
	sphere_mesh.rings=6
	data = JSON.parse_string(FileAccess.get_file_as_string(CITY_DATA_PATH))
	preload("res://sector2_street.gd").prepare(data)
	preload("res://cinema_frontages.gd").prepare(data)
	preload("res://cinestar_street.gd").prepare(data)
	preload("res://jaipur_streetscape.gd").prepare(data)
	var bounds: Array=data.meta.playable_bounds
	map_bounds=Rect2(bounds[0],bounds[1],bounds[2]-bounds[0],bounds[3]-bounds[1])
	compact_layout()
	spatial.build(data)
	await loading_checkpoint(.06,"Finding safe arrival",true)
	var arrival := safe_road_arrival(Vector2(spawn_point.x,spawn_point.z))
	spawn_point = Vector3(arrival.p.x,1,arrival.p.y)
	spawn_heading = arrival.heading
	landmarks = data.pois
	amenities = data.get("amenities", [])
	service_builder.world = self
	service_builder.assign(data,CITY_COMPRESSION,Vector2(-1591.05,-2843.67))
	await loading_checkpoint(.10,"Preparing surface materials",true)
	make_materials()
	make_city_materials()
	# Less aggressive surface relief removes the sandpaper shimmer seen on the tablet.
	for key in mats:
		mats[key].normal_scale *= 0.32
		mats[key].texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	lighting()
	style_pass()
	preload("res://architecture_materials.gd").install(self)
	preload("res://heritage_kit.gd").install(self)
	finish_materials()
	var jaipur_street=preload("res://jaipur_streetscape.gd").new()
	jaipur_street.world=self
	jaipur_street.install_materials()
	mark_street_pilot()
	for key in ["hm_pink","rose","terracotta","fort"]:
		pbr(key,"paintedwall",mats[key].albedo_color,.32,.07)
	mats["hm_pink"].albedo_color=Color("c98c76")
	mats["rose"].albedo_color=Color("cc9b87")
	mats["terracotta"].albedo_color=Color("b98069")
	mats["fort"].albedo_color=Color("aa9a7c")
	await loading_checkpoint(.18,"Building ground",true)
	await build_ground()
	await loading_checkpoint(.23,"Building roads",true)
	await build_roads()
	await loading_checkpoint(.35,"Building neighbourhoods",true)
	var built_count := 0
	for b in data.buildings:
		built_count+=1
		await loading_checkpoint(.35+.22*float(built_count)/data.buildings.size(),"Building neighbourhoods")
		if b.has("kind"):
			continue
		city_building(b)
		building_count += 1
	await loading_checkpoint(.57,"Preparing places to visit",true)
	await build_amenities()
	register_dining_destinations()
	var order := ["showroom","hospital","police","theka","grocery","chai"]
	services.sort_custom(func(a,b): return order.find(a.kind)<order.find(b.kind))
	var details=preload("res://street_details.gd").new()
	details.world=self
	for i in services.size():
		details.build(services[i].building,services[i].rotation,i)
	await loading_checkpoint(.70,"Building parks and landmarks",true)
	build_parks()
	build_landmarks()
	await loading_checkpoint(.75,"Adding street details",true)
	await preload("res://district_details.gd").new().decorate(self)
	preload("res://sector2_street.gd").new().streetscape(self)
	preload("res://jaipur_streetscape.gd").new().streetscape(self)
	await loading_checkpoint(.84,"Preparing visible city",true)
	await flush_batches()
	await flush_road_meshes()
	batches.clear()
	road_meshes.clear()
	update_cells(spawn_point)
	await loading_checkpoint(1.0,"City ready",true)
	build_finished=true
	world_built.emit()

func compact_layout() -> void:
	map_bounds = Rect2(map_bounds.position*CITY_COMPRESSION,map_bounds.size*CITY_COMPRESSION)
	spawn_point.x *= CITY_COMPRESSION
	spawn_point.z *= CITY_COMPRESSION
	for road in data.roads:
		road.width *= CITY_COMPRESSION
		if road.has("segment_widths"):
			for i in road.segment_widths.size():road.segment_widths[i]*=CITY_COMPRESSION
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
	for a in data.get("amenities", []):
		a.p[0] *= CITY_COMPRESSION
		a.p[1] *= CITY_COMPRESSION
		a.w *= CITY_COMPRESSION
		a.d *= CITY_COMPRESSION
	for line in data.navigation:
		for p in line:
			p[0] *= CITY_COMPRESSION
			p[1] *= CITY_COMPRESSION

func make_city_materials() -> void:
	for pair in [["cafe_charcoal","181b1d"],["cafe_wood","795139"],["cafe_turf","426447"],["cafe_plaster","b9b6ad"],["cafe_frame","67716a"],["cafe_cane","ba9763"],["shop_glass","779b9e"],["warm_light","ffe6b3"],["chrome","bac5c8"],["tile","c7cec8"],["grout","89958e"]]:
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

func finish_materials() -> void:
	# Metre-scaled CC0 surfaces with restrained relief and mipmaps. Keep the
	# normal/roughness maps: the former blanket override flattened every material.
	for item in [["arch_cream","paintedwall","e2d3b8",.35,.07],["cream","paintedwall","e6d5b8",.35,.07],["white","paintedwall","e9e1d1",.35,.06],["concrete","concrete","c5bca9",.25,.10],["stone","cobble","c5bca9",.25,.10],["tarmac","asphalt2","7b8288",.18,.08],["sand","scrubland","c1b697",.18,.08],["grass","scrubland","83a77d",.20,.08]]:
		pbr(item[0],item[1],Color(item[2]),item[3],item[4])
		mats[item[0]].texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	for key in ["leaves","leaves_light"]:
		mats[key].albedo_texture=null
		mats[key].albedo_color=Color("31583a") if key=="leaves" else Color("527849")
		mats[key].roughness=.9
	# First Android visual-quality pass: restore subtle real-world surface detail
	# on roads/stone/concrete. These textures are already bundled, so this
	# does not introduce new downloads or change world geometry/collisions.
	# Keep normal strength conservative to avoid shimmer on mobile screens.
	for spec in [["tarmac", "asphalt2", 0.12, 0.90], ["stone", "pavement05", 0.10, 0.82], ["concrete", "concrete", 0.10, 0.90]]:
		var material: StandardMaterial3D = mats[spec[0]]
		var texture_name: String = spec[1]
		var diffuse_name := "res://assets/textures/" + texture_name + ("_diff.jpg" if texture_name == "pavement05" else "_Diffuse.jpg")
		var normal_name := "res://assets/textures/" + texture_name + "_nor_gl.jpg"
		var rough_name := "res://assets/textures/" + texture_name + ("_rough.jpg" if texture_name == "pavement05" else "_Rough.jpg")
		material.albedo_texture = load(diffuse_name)
		material.normal_texture = load(normal_name)
		material.normal_enabled = true
		material.normal_scale = spec[2]
		material.roughness_texture = load(rough_name)
		material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
		material.roughness = spec[3]
		material.uv1_scale = Vector3.ONE * (0.22 if texture_name == "asphalt2" else 0.28)

func destinations() -> Array:
	return landmarks + services + dining_destinations

func register_dining_destinations() -> void:
	for entry in restaurant_entries:
		var at: Vector3=entry.origin+entry.basis*Vector3(0,0,entry.d/2+2.2)
		var road:=nearest_road_point(at.x,at.z)
		dining_destinations.append({"name":entry.name,"hindi":"","kind":"restaurant","p":[at.x,at.z],"rotation":atan2(entry.basis.z.x,entry.basis.z.z),"car_p":[road.p.x,road.p.y],"car_heading":road.heading})

func nearest_road_point(x: float,z: float) -> Dictionary:
	# Closest mapped road segment: used to park the player's car beside a destination.
	var closest := Vector2(x,z)
	var distance := INF
	var heading := 0.0
	for road in data.roads:
		for i in range(road.p.size()-1):
			var a := Vector2(road.p[i][0],road.p[i][1])
			var b := Vector2(road.p[i+1][0],road.p[i+1][1])
			if a.distance_squared_to(Vector2(x,z))>40000:
				continue
			var point := Geometry2D.get_closest_point_to_segment(Vector2(x,z),a,b)
			var d := point.distance_squared_to(Vector2(x,z))
			if d < distance:
				distance = d
				closest = point
				heading = atan2(-(b.x-a.x),-(b.y-a.y))
	return {"p":closest,"heading":heading}

func clear_arrival(at: Vector2, margin: float) -> bool:
	return map_bounds.grow(-8).has_point(at) and spatial.obstacles_clear(at,margin)

func clear_verge(at: Vector2) -> bool:
	return map_bounds.grow(-5).has_point(at) and spatial.obstacles_clear(at,2.0) and spatial.roads_clear(at,1.0)

func loading_checkpoint(fraction: float, label: String, force := false) -> void:
	var now := Time.get_ticks_msec()
	if label!=stage_name:
		if not stage_name.is_empty():startup_timings.append({"stage":stage_name,"ms":now-stage_started})
		stage_name=label
		stage_started=now
	if force or now-checkpoint_time>=20:
		build_progress.emit(fraction,label)
		if incremental_startup:await get_tree().process_frame
		checkpoint_time=Time.get_ticks_msec()

func safe_road_arrival(hint: Vector2) -> Dictionary:
	var closest:=Vector2.ZERO
	var distance:=INF
	var heading:=0.0
	for road in data.roads:
		if road.width<6: continue
		for i in range(road.p.size()-1):
			var a:=Vector2(road.p[i][0],road.p[i][1])
			var b:=Vector2(road.p[i+1][0],road.p[i+1][1])
			if a.distance_to(hint)>220: continue
			var direction: Vector2=(b-a).normalized()
			var side:=Vector2(-direction.y,direction.x)
			for fraction in [.2,.5,.8]:
				var point:=a.lerp(b,fraction)
				var score:=point.distance_squared_to(hint)
				if score>=distance or not clear_arrival(point,3.0) or not clear_arrival(point+side*2.6,1.0): continue
				distance=score
				closest=point
				heading=atan2(-direction.x,-direction.y)
	if is_inf(distance): return nearest_road_point(hint.x,hint.y)
	return {"p":closest,"heading":heading}

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
	var completed := 0
	for bucket in batches:
		completed+=1
		await loading_checkpoint(.84+.12*float(completed)/maxi(1,batches.size()),"Preparing visible city")
		var parts: PackedStringArray = bucket.split("|")
		var transforms: Array = batches[bucket]
		var multi := MultiMesh.new()
		multi.transform_format = MultiMesh.TRANSFORM_3D
		multi.mesh = architecture_meshes.get(parts[3],sphere_mesh) if parts.size()>3 else cube
		multi.instance_count = transforms.size()
		for i in transforms.size():
			multi.set_instance_transform(i, transforms[i])
		var mesh := MultiMeshInstance3D.new()
		mesh.multimesh = multi
		mesh.material_override = mats[parts[1]]
		if parts[1] in ["stone","sand","grass","tarmac","grout"]:
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh.visibility_range_end = 170 if parts[2] == "1" else 600
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
	# The entire retained VKI/VDN crop lies on the exactly-flat branch.
	if x<0:return 0.0
	var rise := exp(-pow((x - 680.0) / 560.0, 2) - pow((z + 1060.0) / 900.0, 2))
	var shoulder := smoothstep(160.0, 510.0, x) * smoothstep(-250.0, -650.0, z)
	var hill:=rise*shoulder*95.0
	var plateau:=1-smoothstep(85.0,170.0,Vector2(x-495,z+760).length())
	return lerpf(hill,66.0,plateau)

func build_ground() -> void:
	var step := 25.0
	var x0 := int(floor(map_bounds.position.x / 400.0) * 400) - 400
	var z0 := int(floor(map_bounds.position.y / 400.0) * 400) - 400
	for cx in range(x0, int(map_bounds.end.x) + 400, 400):
		for cz in range(z0, int(map_bounds.end.y) + 400, 400):
			await loading_checkpoint(.20,"Building ground")
			if cx+400<0:
				var flat := MeshInstance3D.new()
				var plane := PlaneMesh.new()
				plane.size=Vector2(400,400)
				flat.mesh=plane
				flat.position=Vector3(cx+200,0,cz+200)
				flat.material_override=mats["sand"]
				flat.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				add_child(flat)
				flat.create_trimesh_collision()
				continue
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
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mesh.create_trimesh_collision()
	# Boundaries stop traversal beyond the imported area.
	var c := map_bounds.get_center()
	var sz := map_bounds.size
	for spec in [[Vector3(map_bounds.position.x,80,c.y),Vector3(2,400,sz.y)],[Vector3(map_bounds.end.x,80,c.y),Vector3(2,400,sz.y)],[Vector3(c.x,80,map_bounds.position.y),Vector3(sz.x,400,2)],[Vector3(c.x,80,map_bounds.end.y),Vector3(sz.x,400,2)]]:
		var boundary := CollisionShape3D.new()
		var bounds := BoxShape3D.new()
		bounds.size = spec[1]
		boundary.shape = bounds
		boundary.position = spec[0]
		collision_root.add_child(boundary)

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

func road_segment_width(road: Dictionary,index: int) -> float:
	return road.segment_widths[index] if road.has("segment_widths") else road.width

func build_roads() -> void:
	var completed := 0
	for road in data.roads:
		completed+=1
		await loading_checkpoint(.23+.12*float(completed)/data.roads.size(),"Building roads")
		var points: Array = road.p
		if points.size() < 2:
			continue
		if road.kind in ["primary","secondary","tertiary","trunk"]:
			routes.append(road)
		if road.get("jaipur_block",false):
			var local_route: Dictionary=road.duplicate(true)
			local_route.p=road.p.slice(0,3)
			local_route.width=road_segment_width(road,0)
			routes.append(local_route)
		var authored: bool = road.get("source","osm") == "authored"
		if authored:
			authored_roads.append(road)
			mark_connector(road)
		for i in range(points.size()-1):
			var a := Vector2(points[i][0],points[i][1])
			var b := Vector2(points[i+1][0],points[i+1][1])
			if a.distance_to(b)>500 or not map_bounds.has_point(a):
				continue
			var width:=road_segment_width(road,i)
			var studied: bool=road.get("jaipur_block",false) and i<2
			var count := maxi(1,ceili(a.distance_to(b)/12.0))
			for j in count:
				var p := a.lerp(b,float(j)/count)
				var q := a.lerp(b,float(j+1)/count)
				road_piece(p,q,width+3.0,"jaipur_dust" if studied else ("kerb_yellow" if authored else "stone"),0.035)
				road_piece(p,q,width,"jaipur_asphalt" if studied else ("stone" if road.kind in ["footway","path","pedestrian","track"] else "tarmac"),0.14)
				if authored:
					road_piece(p.lerp(q,0.2),p.lerp(q,0.6),0.3,"kerb_black",0.075)
				if road.width >= 10*CITY_COMPRESSION and j%2 == 0:
					road_piece(p.lerp(q,0.1),p.lerp(q,0.65),0.16,"cream",0.16)
			if road.width >= 10*CITY_COMPRESSION and i % 4 == 0:
				var d := (b-a).normalized()
				var at: Vector2 = a + Vector2(-d.y,d.x)*(road.width*0.5+1)
				var y := terrain_height(at.x,at.y)
				draw_detail = true
				box(Vector3(at.x,y+3,at.y),Vector3(.12,6,.12),"metal")
				box(Vector3(at.x,y+6,at.y),Vector3(1,.1,.35),"lamp")
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
		await loading_checkpoint(.97,"Preparing road surfaces")
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

# ------------------------------------------------------------ style pass ----
func style_pass() -> void:
	# Clean, warm, readable look: one warm key light, cool sky fill, crisp
	# shadows near the player, light haze far away, harmonious palette.
	for child in get_children():
		if child is DirectionalLight3D:
			child.light_color = Color("ffe6c7")
			child.light_energy = 0.85
			child.rotation_degrees = Vector3(-31, -34, 0)
			child.directional_shadow_max_distance = 90
			child.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
			child.shadow_bias = 0.08
			child.shadow_normal_bias = 1.2
		elif child is WorldEnvironment:
			var env: Environment = child.environment
			var sky_mat: ProceduralSkyMaterial = env.sky.sky_material
			sky_mat.sky_top_color = Color("699bb8")
			sky_mat.sky_horizon_color = Color("efc6ab")
			sky_mat.ground_horizon_color = Color("efc6ab")
			sky_mat.ground_bottom_color = Color("8d7f68")
			sky_mat.sun_angle_max = 20
			sky_mat.sun_curve = 0.12
			env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
			env.ambient_light_sky_contribution = 1.0
			env.ambient_light_energy = 0.38
			env.tonemap_mode = Environment.TONE_MAPPER_ACES
			env.tonemap_exposure = 0.9
			env.tonemap_white = 5.0
			env.fog_enabled = true
			env.fog_light_color = Color("e5d8c3")
			env.fog_density = 0.00065
			env.fog_sky_affect = 0.18
			env.glow_enabled = true
			env.glow_intensity = 0.22
			env.glow_hdr_threshold = 1.15
			env.adjustment_enabled = true
			env.adjustment_contrast = 1.08
			env.adjustment_saturation = 1.07
	var palette := {"rose": "d9a08b", "hm_pink": "cf8f79", "terracotta": "c58a71", "ochre": "dcc08f", "cream": "ece0c4", "white": "f1ece0", "ivory": "e3d6b8", "concrete": "c9c3b7", "glass": "587f94", "dark": "2d3638", "trim": "f4ebda", "kerb_yellow": "e4bd3f", "teal": "3f8d85", "maroon": "95433f", "saffron": "e08a3c", "blue": "3f6aa6", "sky_blue": "6fb2d6", "green": "4e8f55", "wood": "9a7452", "tarmac": "585a5c", "stone": "cdc3b1", "sand": "c9bea3", "scrub": "8a9a6c", "grass": "8fb56f", "leaves": "4f7f45", "leaves_light": "7da35a", "red": "c8463a", "orange": "e58a2c", "yellow": "e9c54c", "metal": "6b7275"}
	for key in palette:
		if mats.has(key):
			mats[key].albedo_color = Color(palette[key])
	for key in ["white", "cream", "ivory", "trim", "concrete"]:
		mats[key].roughness = 0.85
	mats["glass"].roughness = 0.18
	mats["glass"].metallic = 0.55
	mats["glass"].metallic_specular = 0.8
	var lamp := StandardMaterial3D.new()
	lamp.albedo_color = Color("fff3d0")
	lamp.emission_enabled = true
	lamp.emission = Color("ffe9b0")
	lamp.emission_energy_multiplier = 1.6
	mats["lamp"] = lamp
	var cross := StandardMaterial3D.new()
	cross.albedo_color = Color("d83a2e")
	cross.emission_enabled = true
	cross.emission = Color("ff5a4a")
	cross.emission_energy_multiplier = 0.9
	mats["cross_red"] = cross
	var cross_green := StandardMaterial3D.new()
	cross_green.albedo_color = Color("2e9a4c")
	cross_green.emission_enabled = true
	cross_green.emission = Color("4fdc73")
	cross_green.emission_energy_multiplier = 0.8
	mats["cross_green"] = cross_green
	var showroom_glass := StandardMaterial3D.new()
	showroom_glass.albedo_color = Color(.55, .72, .8, .42)
	showroom_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	showroom_glass.roughness = .12
	showroom_glass.metallic = .4
	showroom_glass.metallic_specular = .9
	showroom_glass.cull_mode = BaseMaterial3D.CULL_DISABLED
	mats["showroom_glass"] = showroom_glass
	var police_blue := StandardMaterial3D.new()
	police_blue.albedo_color = Color("2d4f9a")
	police_blue.roughness = 0.7
	mats["police_blue"] = police_blue

# ------------------------------------------------------------ buildings ----
const SHOP_COLORS := ["teal", "maroon", "saffron", "blue", "green", "red"]

func mark_street_pilot() -> void:
	# Pass 01: Road Number 5, OSM way 374927752. Reference-inspired, not a survey.
	for road in data.roads:
		if int(road.get("id",0))!=374927752: continue
		var middle: Array=road.p[road.p.size()/2]
		for b in data.buildings:
			if Vector2(b.x-middle[0],b.z-middle[1]).length()>100: continue
			for i in range(road.p.size()-1):
				var a:=Vector2(road.p[i][0],road.p[i][1])
				var z:=Vector2(road.p[i+1][0],road.p[i+1][1])
				if Geometry2D.get_closest_point_to_segment(Vector2(b.x,b.z),a,z).distance_to(Vector2(b.x,b.z))<32:
					b.street_pilot="01-vki-road-5"
		return

func city_building(b: Dictionary) -> void:
	if b.has("service"):
		service_builder.build(b)
		return
	if b.has("cinestar_street"):
		var street=preload("res://cinestar_street.gd").new()
		street.world=self
		street.frontage(b)
		return
	if b.get("sector2_design", "")=="shop_row":
		var street=preload("res://sector2_street.gd").new()
		street.world=self
		street.shop_row(b)
		return
	# Richer street shells around the VDN arrival and dining locations.
	if b.z < -3650*CITY_COMPRESSION and b.w>=7 and b.d>=7:
		var industrial=preload("res://district_details.gd").new()
		industrial.factory(self,b)
		return
	var featured: bool=Vector2(b.x-spawn_point.x,b.z-spawn_point.z).length_squared()<62500
	if not featured:
		for a in amenities:
			if a.kind=="restaurant" and Vector2(b.x-a.p[0],b.z-a.p[1]).length_squared()<900:
				featured=true
				break
	if featured and b.w>=3.5 and b.d>=3.0:
		var neighbourhood=preload("res://neighborhood_architecture.gd").new()
		neighbourhood.world=self
		neighbourhood.build({"p":[b.x,b.z],"a":b.a,"w":b.w,"d":b.d,"h":b.h,"old":int(abs(b.x+b.z))%3==0})
		return
	var base := Vector3(b.x,terrain_height(b.x,b.z),b.z)
	var basis := Basis(Vector3.UP,b.a)
	var old: bool = int(abs(b.x+b.z))%4==0
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



func sign_board(at: Vector3, ang: float, front: float, text: String, board_key: String, size: Vector3, text_color := Color("fff6e6"), font_size := 36) -> void:
	# Painted board with readable text, facing the road.
	box(at, size, board_key, false, Vector3(0, ang, 0))
	var label := Label3D.new()
	label.font = hindi_font
	label.text = text
	label.font_size = font_size
	label.pixel_size = .0045
	label.modulate = text_color
	label.outline_size = 4
	label.outline_modulate = Color(0, 0, 0, .55)
	label.width = size.x / .0045
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = at + Basis(Vector3.UP, ang) * Vector3(0, 0, front * (size.z / 2 + .02))
	label.rotation.y = ang + (0.0 if front > 0 else PI)
	label.visibility_range_end = 110
	cell(at).add_child(label)

func parked_vehicle(at: Vector3, ang: float, kind: String, color: String) -> void:
	var model:=preload("res://vehicle_design.gd").new()
	model.style="police" if kind=="jeep" else ("ambulance" if kind=="ambulance" else ("suv" if color=="teal" else "sedan"))
	model.paint=mats[color].albedo_color if mats.has(color) else Color("d9d5ca")
	model.position=at
	model.rotation.y=ang
	cell(at).add_child(model)

func build_amenities() -> void:
	var completed := 0
	for a in amenities:
		completed+=1
		await loading_checkpoint(.57+.13*float(completed)/amenities.size(),"Preparing places to visit")
		if not map_bounds.has_point(Vector2(a.p[0], a.p[1])):
			continue
		amenity_count += 1
		if a.has("shared_campus"):continue
		var p := Vector3(a.p[0], terrain_height(a.p[0], a.p[1]), a.p[1])
		var ang: float = a.a
		var front: float = a.get("front", 1)
		var w: float = a.w
		var d: float = a.d
		var display_name: String = a.name if a.name != "" else ""
		if a.kind == "cafe" or a.get("tags", {}).get("amenity", "") == "cafe" or a.get("design", "") == "reference_cafe":
			var cafe = preload("res://cafe_reference.gd").new()
			cafe.world = self
			cafe.build(a)
			continue
		if a.kind == "restaurant":
			var restaurant=preload("res://restaurant_architecture.gd").new()
			restaurant.world=self
			restaurant.build(a)
			continue
		if a.get("sector2_design", "")=="rose_tower":
			var street=preload("res://sector2_street.gd").new()
			street.world=self
			street.tower(a)
			continue
		if a.get("design", "")=="cinestar_exterior":
			var cinema=preload("res://cinema_frontages.gd").new()
			cinema.world=self
			cinema.cinestar(a)
			continue
		if a.get("design", "")=="times_square_exterior":
			var cinema=preload("res://cinema_frontages.gd").new()
			cinema.world=self
			cinema.times_square(a)
			continue
		match a.kind:
			"police": amenity_police(p, ang, front, w, d, display_name)
			"hospital": amenity_hospital(p, ang, front, w, d, display_name)
			"showroom": amenity_showroom(p, ang, front, w, d, display_name)
			"theka": amenity_theka(p, ang, front, w, d)
			"fuel": amenity_fuel(p, ang, front, w, d, display_name)
			"bank": amenity_bank(p, ang, front, w, d, display_name)
			"school": amenity_school(p, ang, front, w, d, display_name)
			"temple": amenity_temple(p, ang, front, w, d, display_name)
			"pharmacy": amenity_shop(p, ang, front, w, d, 6.0, "white", "cross_green", "मेडिकल स्टोर · " + (display_name if display_name != "" else "PHARMACY"))
			"pub", "club": amenity_shop(p, ang, front, w, d, 7.0, "dark", "maroon", display_name if display_name != "" else "PUB / CLUB")
			_: amenity_shop(p, ang, front, w, d, 6.0, "cream", SHOP_COLORS[int(abs(p.x)) % SHOP_COLORS.size()], display_name if display_name != "" else "GENERAL STORE")

func lb(p: Vector3, ang: float, local: Vector3, size: Vector3, key: String, solid := false, tilt := 0.0) -> void:
	box(p + Basis(Vector3.UP, ang) * local, size, key, solid, Vector3(tilt, ang, 0))

func amenity_police(p: Vector3, ang: float, front: float, w: float, d: float, display_name: String) -> void:
	# Rajasthan thana: cream two-storey block with a blue band, portico, compound wall,
	# gate pillars, striped barrier, flag mast, a parked jeep.
	var bw: float = w * .78
	var bd: float = d * .5
	var back: float = -front * d * .22
	lb(p, ang, Vector3(0, 3.5, back), Vector3(bw, 7, bd), "cream", true)
	lb(p, ang, Vector3(0, 7.15, back), Vector3(bw + .5, .3, bd + .5), "trim")
	lb(p, ang, Vector3(0, 3.3, back), Vector3(bw + .06, .5, bd + .06), "police_blue")
	draw_detail = true
	for side in [-1, 1]:
		for floor_index in 2:
			lb(p, ang, Vector3(0, 1.6 + floor_index * 3.0, back + side * (bd / 2 + .05)), Vector3(bw * .8, 1.4, .1), "dark")
	# Portico.
	lb(p, ang, Vector3(0, 3.6, back + front * (bd / 2 + 1.6)), Vector3(bw * .45, .25, 3.2), "cream")
	for side in [-1, 1]:
		lb(p, ang, Vector3(side * bw * .2, 1.75, back + front * (bd / 2 + 2.9)), Vector3(.35, 3.5, .35), "cream")
	sign_board(p + Basis(Vector3.UP, ang) * Vector3(0, 4.6, back + front * (bd / 2 + .12)), ang, front, "पुलिस थाना\nPOLICE STATION\n" + display_name, "police_blue", Vector3(bw * .7, 1.6, .2), Color("ffffff"), 34)
	# Compound wall with gate.
	var fz: float = front * (d / 2 - .3)
	for side in [-1, 1]:
		lb(p, ang, Vector3(side * (w * .5 - w * .17), .7, fz), Vector3(w * .34, 1.4, .3), "cream")
		lb(p, ang, Vector3(side * w * .17, 1.1, fz), Vector3(.5, 2.2, .5), "ochre")
		lb(p, ang, Vector3(side * (w / 2 - .15), .7, 0), Vector3(.3, 1.4, d), "cream")
	lb(p, ang, Vector3(0, 1.0, fz + front * 1.2), Vector3(w * .3, .12, .12), "red")
	lb(p, ang, Vector3(w * .13, .5, fz + front * 1.2), Vector3(.3, 1.0, .3), "white")
	lb(p, ang, Vector3(-w * .15, 4.0, back + front * (bd / 2 + 3.5)), Vector3(.1, 8, .1), "metal")
	for i in 3:
		lb(p, ang, Vector3(-w * .15 + .55, 7.75 - i * .3, back + front * (bd / 2 + 3.5)), Vector3(1.0, .3, .04), ["saffron", "white", "green"][i])
	draw_detail = false
	parked_vehicle(p + Basis(Vector3.UP, ang) * Vector3(w * .3, 0, back + front * (bd / 2 + 3.2)), ang, "jeep", "white")

func amenity_hospital(p: Vector3, ang: float, front: float, w: float, d: float, display_name: String) -> void:
	var hospital = preload("res://hospital_reference.gd").new()
	hospital.world = self
	hospital.build({"p":[p.x,p.z],"a":ang,"front":front,"w":w,"d":d,"name":display_name})

func amenity_showroom(p: Vector3, ang: float, front: float, w: float, d: float, display_name: String) -> void:
	# Glass box with a white fascia band, brand name and cars on a lit plinth.
	var bw: float = w * .86
	var bd: float = d * .6
	var back: float = -front * d * .15
	lb(p, ang, Vector3(0, .25, back), Vector3(bw + 1, .5, bd + 1), "concrete", true)
	lb(p, ang, Vector3(0, 4.5, back), Vector3(bw, 8.0, bd), "showroom_glass", true)
	lb(p, ang, Vector3(0, .6, back), Vector3(bw * .9, .5, bd * .8), "white")
	for side in [-1, 1]:
		lb(p, ang, Vector3(side * (bw / 2), 4.5, back), Vector3(.5, 8.2, bd + .1), "white")
	lb(p, ang, Vector3(0, 8.9, back), Vector3(bw + .9, 1.4, bd + .9), "white")
	lb(p, ang, Vector3(0, 9.75, back), Vector3(bw + 1.1, .3, bd + 1.1), "trim")
	draw_detail = true
	for i in range(1, 4):
		lb(p, ang, Vector3(-bw / 2 + i * bw / 4, 4.5, back + front * (bd / 2)), Vector3(.14, 8, .2), "metal")
	for i in 6:
		lb(p, ang, Vector3(-bw / 2 + 1.5 + i * (bw - 3) / 5, 7.8, back), Vector3(.3, .08, .3), "lamp")
	draw_detail = false
	sign_board(p + Basis(Vector3.UP, ang) * Vector3(0, 8.9, back + front * (bd / 2 + .6)), ang, front, (display_name if display_name != "" else "CAR SHOWROOM").to_upper() + "  ·  कार शोरूम", "white", Vector3(bw * .8, 1.3, .1), Color("1d2a3a"), 44)
	var colors := ["red", "white", "sky_blue", "dark"]
	for i in 3:
		parked_vehicle(p + Basis(Vector3.UP, ang) * Vector3(-bw * .3 + i * bw * .3, .5, back), ang + PI / 2, "car", colors[i])
	parked_vehicle(p + Basis(Vector3.UP, ang) * Vector3(bw * .25, 0, back + front * (bd / 2 + 4.5)), ang, "car", colors[3])
	for side in [-1, 1]:
		lb(p, ang, Vector3(side * bw * .42, 3.5, back + front * (bd / 2 + 4.5)), Vector3(.08, 7, .08), "metal")
		lb(p, ang, Vector3(side * bw * .42 + .5, 6.5, back + front * (bd / 2 + 4.5)), Vector3(1.0, .6, .04), "blue")

func amenity_theka(p: Vector3, ang: float, front: float, w: float, d: float) -> void:
	# Rajasthan excise retail: small cream kiosk, iron grille counter, green-white board.
	lb(p, ang, Vector3(0, 1.8, 0), Vector3(w, 3.6, d), "cream", true)
	lb(p, ang, Vector3(0, 3.7, 0), Vector3(w + .3, .2, d + .3), "concrete")
	draw_detail = true
	var fz: float = front * (d / 2 + .05)
	lb(p, ang, Vector3(0, 1.5, fz), Vector3(w * .7, 1.6, .1), "dark")
	for i in 6:
		lb(p, ang, Vector3(-w * .3 + i * w * .12, 1.5, fz + front * .05), Vector3(.04, 1.6, .04), "metal")
	lb(p, ang, Vector3(0, .95, fz + front * .35), Vector3(w * .75, .12, .7), "concrete")
	for i in 5:
		round_prop(p + Basis(Vector3.UP, ang) * Vector3(-w * .25 + i * w * .12, 1.3, fz - front * .4), Vector3(.14, .4, .14), ["green", "dark", "yellow", "green", "maroon"][i])
	lb(p, ang, Vector3(w * .55, .6, fz + front * 1.4), Vector3(.06, 1.2, .06), "metal")
	lb(p, ang, Vector3(w * .2, 1.1, fz + front * 1.4), Vector3(w * .7, .05, .05), "metal")
	draw_detail = false
	sign_board(p + Basis(Vector3.UP, ang) * Vector3(0, 3.1, fz + front * .12), ang, front, "देसी · अंग्रेज़ी शराब की दुकान\nWINE & BEER SHOP", "green", Vector3(w * .95, .9, .16), Color("ffffff"), 26)

func amenity_fuel(p: Vector3, ang: float, front: float, w: float, d: float, display_name: String) -> void:
	var brand: String = display_name.to_upper()
	var key: String = "orange" if "INDIAN" in brand else ("blue" if "HP" in brand or "HINDUSTAN" in brand else "yellow")
	lb(p, ang, Vector3(0, .08, 0), Vector3(w, .16, d), "tarmac")
	lb(p, ang, Vector3(0, 5.6, 0), Vector3(w * .9, .45, d * .7), "white")
	lb(p, ang, Vector3(0, 5.35, 0), Vector3(w * .92, .12, d * .72), key)
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			lb(p, ang, Vector3(sx * w * .32, 2.7, sz * d * .22), Vector3(.45, 5.4, .45), "white", true)
	draw_detail = true
	for sx in [-1, 1]:
		lb(p, ang, Vector3(sx * w * .18, .2, 0), Vector3(2.0, .4, d * .45), "concrete", true)
		for sz in [-1, 1]:
			lb(p, ang, Vector3(sx * w * .18, 1.0, sz * d * .13), Vector3(.9, 1.6, .5), "white")
			lb(p, ang, Vector3(sx * w * .18, 1.4, sz * d * .13), Vector3(.92, .35, .52), key)
	for i in 4:
		lb(p, ang, Vector3(-w * .3 + i * w * .2, 5.3, 0), Vector3(.3, .08, .3), "lamp")
	draw_detail = false
	lb(p, ang, Vector3(0, 1.5, -front * (d / 2 - 2.0)), Vector3(w * .35, 3.0, 3.5), "white", true)
	lb(p, ang, Vector3(w * .42, 3.8, front * (d / 2 - .8)), Vector3(.25, 7.6, .25), "metal")
	sign_board(p + Basis(Vector3.UP, ang) * Vector3(w * .42, 7.0, front * (d / 2 - .8)), ang, front, display_name if display_name != "" else "PETROL PUMP", key, Vector3(3.6, 1.6, .3), Color("ffffff"), 30)

func amenity_bank(p: Vector3, ang: float, front: float, w: float, d: float, display_name: String) -> void:
	lb(p, ang, Vector3(0, 4.0, 0), Vector3(w, 8, d), "concrete", true)
	lb(p, ang, Vector3(0, 8.15, 0), Vector3(w + .3, .3, d + .3), "trim")
	draw_detail = true
	var fz: float = front * (d / 2 + .05)
	lb(p, ang, Vector3(0, 1.6, fz), Vector3(w * .7, 2.6, .1), "glass")
	lb(p, ang, Vector3(0, 5.6, fz), Vector3(w * .8, 1.5, .1), "glass")
	lb(p, ang, Vector3(w * .32, 1.3, fz + front * .9), Vector3(1.6, 2.5, 1.6), "white", true)
	lb(p, ang, Vector3(w * .32, 1.5, fz + front * 1.72), Vector3(.9, .9, .05), "dark")
	draw_detail = false
	sign_board(p + Basis(Vector3.UP, ang) * Vector3(0, 3.6, fz + front * .1), ang, front, (display_name if display_name != "" else "BANK") + " · बैंक", "blue", Vector3(w * .85, 1.0, .16), Color("ffffff"), 30)

func amenity_school(p: Vector3, ang: float, front: float, w: float, d: float, display_name: String) -> void:
	var campus=preload("res://education_reference.gd").new()
	campus.world=self
	campus.build({"p":[p.x,p.z],"a":ang,"front":front,"w":w,"d":d,"name":display_name})

func amenity_temple(p: Vector3, ang: float, front: float, w: float, d: float, display_name: String) -> void:
	var s: float = minf(w, d)
	lb(p, ang, Vector3(0, .5, 0), Vector3(s, 1.0, s), "cream", true)
	lb(p, ang, Vector3(0, 3.0, 0), Vector3(s * .6, 4.0, s * .6), "ivory", true)
	draw_detail = true
	for i in 5:
		lb(p, ang, Vector3(0, 5.4 + i * 1.0, 0), Vector3(s * (.5 - i * .08), 1.0, s * (.5 - i * .08)), "saffron" if i % 2 else "ochre")
	round_prop(p + Vector3(0, 10.8, 0), Vector3(1.4, 1.4, 1.4), "yellow")
	lb(p, ang, Vector3(0, 12.0, 0), Vector3(.06, 2.2, .06), "metal")
	lb(p, ang, Vector3(.4, 12.7, 0), Vector3(.8, .5, .03), "saffron")
	for side in [-1, 1]:
		lb(p, ang, Vector3(side * s * .35, 2.2, front * s * .3), Vector3(.4, 3.4, .4), "cream")
	lb(p, ang, Vector3(0, 2.0, front * s * .3), Vector3(s * .8, .3, .5), "cream")
	lb(p, ang, Vector3(0, 1.6, front * (s * .3 + .1)), Vector3(1.6, 2.4, .1), "dark")
	draw_detail = false
	sign_board(p + Basis(Vector3.UP, ang) * Vector3(0, 4.3, front * (s * .3 + .15)), ang, front, display_name if display_name != "" else "मंदिर · TEMPLE", "saffron", Vector3(s * .6, .8, .14), Color("fff6e0"), 26)

func amenity_shop(p: Vector3, ang: float, front: float, w: float, d: float, height: float, wall: String, accent: String, text: String) -> void:
	lb(p, ang, Vector3(0, height / 2, 0), Vector3(w, height, d), wall, true)
	lb(p, ang, Vector3(0, height + .12, 0), Vector3(w + .3, .24, d + .3), "trim")
	draw_detail = true
	var fz: float = front * (d / 2 + .05)
	lb(p, ang, Vector3(0, 1.4, fz), Vector3(w * .8, 2.6, .1), "glass" if accent == "cross_green" else "dark")
	lb(p, ang, Vector3(0, 2.85, fz + front * .55), Vector3(w * .9, .12, 1.2), accent if accent != "cross_green" else "green", false, front * .22)
	if accent == "cross_green":
		lb(p, ang, Vector3(w * .4, 4.3, fz), Vector3(1.2, .4, .14), "cross_green")
		lb(p, ang, Vector3(w * .4, 4.3, fz), Vector3(.4, 1.2, .14), "cross_green")
	draw_detail = false
	sign_board(p + Basis(Vector3.UP, ang) * Vector3(0, 3.6, fz + front * .1), ang, front, text, accent if accent != "cross_green" else "white", Vector3(w * .85, .8, .14), Color("fff6e6") if accent != "cross_green" else Color("1f7a3a"), 24)

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
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		cell(Vector3(center.x,0,center.y)).add_child(m)
		for i in range(0,points.size(),maxi(1,points.size()/8)):
			var p := points[i].lerp(center,.15)
			var at:=Vector3(p.x,terrain_height(p.x,p.y),p.y)
			tree_at(at)
			seats.append({"p":at+Vector3(2,0,-.1),"yaw":0.0,"h":.63,"pose":"Sit","park":true})
			box(at+Vector3(2,.55,0),Vector3(1.8,.16,.6),"wood")
			box(at+Vector3(2,.95,.3),Vector3(1.8,.65,.12),"wood")
			for side in [-1,1]:
				box(at+Vector3(2+side*.65,.25,0),Vector3(.1,.5,.45),"metal")
		park_destinations.append({"name":park_data.get("name","") if not str(park_data.get("name","")).is_empty() else "Neighbourhood Park %d" % (park_destinations.size()+1),"kind":"park","p":[center.x,center.y],"source":"Archived OpenStreetMap park footprint"})
		var ground:=terrain_height(center.x,center.y)
		box(Vector3(center.x,ground+.06,center.y),Vector3(12,.1,8),"sand")
		for side in [-1,1]:
			box(Vector3(center.x+side*4,ground+1.5,center.y),Vector3(.12,3,.12),"blue")
		box(Vector3(center.x,ground+3,center.y),Vector3(8,.12,.12),"blue")
		for side in [-1,1]:
			box(Vector3(center.x+side*1.7,ground+1.8,center.y),Vector3(.04,2.4,.04),"metal")
		box(Vector3(center.x,ground+.6,center.y),Vector3(3.5,.12,.6),"terracotta")

func tree_at(at: Vector3) -> void:
	box(at+Vector3(0,1.9,0),Vector3(.26,3.8,.26),"wood")
	for side in [-1,1]:
		box(at+Vector3(side*.42,2.9,0),Vector3(.15,1.6,.15),"wood",false,Vector3(0,0,side*-.5))
	for i in 7:
		var angle:=i*2.399
		var radius:=1.25 if i<5 else .5
		var center:=at+Vector3(sin(angle)*radius,3.7+(i%3)*.62,cos(angle)*radius)
		round_prop(center,Vector3(2.7,2.6,2.8),"leaves" if i%3 else "leaves_light")

func build_landmarks() -> void:
	for poi in landmarks:
		var arrival:=safe_road_arrival(Vector2(poi.p[0],poi.p[1]))
		poi.car_p=[arrival.p.x,arrival.p.y]
		poi.car_heading=arrival.heading
		poi.rotation=arrival.heading
		if poi.kind not in ["park"] and poi.name!="Crazy Cafe · VDN":
			var sidewalk: Vector3=Basis(Vector3.UP,arrival.heading)*Vector3(2.6,0,0)
			poi.p=[arrival.p.x+sidewalk.x,arrival.p.y+sidewalk.z]
		elif poi.name=="Crazy Cafe · VDN":
			for a in amenities:
				if a.get("osm_id",0)==-91001:
					poi.p=[a.p[0]-a.w*.25,a.p[1]+a.d/2+2.9]
					poi.rotation=0.0
		var p := Vector3(poi.p[0],terrain_height(poi.p[0],poi.p[1]),poi.p[1])
		var sign := Label3D.new()
		sign.font = hindi_font
		sign.text = poi.hindi+"\n"+poi.name
		sign.font_size = 32
		sign.pixel_size = .006
		sign.position = p+(Vector3(0,2.5,3) if poi.name == "Crazy Cafe · VDN" else Vector3(-8,2.5,-6))
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
			var palace=preload("res://palace_architecture.gd").new()
			palace.world=self
			palace.build_palace(p)

func district_at(at: Vector3) -> Dictionary:
	if at.z < -3650*CITY_COMPRESSION:
		return {"id":"vki","name":"VKI South","hindi":"विश्वकर्मा औद्योगिक क्षेत्र"}
	return {"id":"vdn","name":"Vidhyadhar Nagar","hindi":"विद्याधर नगर"}

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
