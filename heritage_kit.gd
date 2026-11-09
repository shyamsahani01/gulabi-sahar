extends "res://cafe_reference.gd"
## Original reusable 3D architecture. All curved meshes share the city's MultiMesh batches.
## Local +Z is the facade; walkable openings are separate from the decorative mesh.
static func mineral_texture() -> NoiseTexture2D:
	var noise:=FastNoiseLite.new()
	noise.seed=42
	noise.frequency=.045
	noise.fractal_octaves=3
	var gradient:=Gradient.new()
	gradient.set_color(0,Color(.82,.82,.82))
	gradient.set_color(1,Color(.88,.88,.88))
	var texture:=NoiseTexture2D.new()
	texture.width=128
	texture.height=128
	texture.seamless=true
	texture.generate_mipmaps=true
	texture.noise=noise
	texture.color_ramp=gradient
	return texture

static func install(target: Node3D) -> void:
	var colors: Dictionary={"heritage_rose":"be7964","heritage_lime":"d6c8ae","heritage_blue":"28556b","heritage_ink":"254047","heritage_red":"813c39","heritage_gold":"b99758","heritage_tile":"c2b79f","heritage_water":"477f7e"}
	for key in colors:
		var mat:=StandardMaterial3D.new()
		mat.albedo_color=Color(colors[key])
		mat.roughness=.86
		mat.metallic_specular=.18
		target.mats[key]=mat
	var mineral:=mineral_texture()
	for key in ["heritage_rose","heritage_lime","heritage_tile"]:
		var mat: StandardMaterial3D=target.mats[key]
		mat.albedo_texture=mineral
		mat.uv1_triplanar=true
		mat.uv1_world_triplanar=true
		mat.uv1_scale=Vector3.ONE*.22
	for spec in [["sand","766952"],["scrub","536346"],["grass","64764e"],["hedge","3e5a39"]]:
		var mat:=StandardMaterial3D.new()
		mat.albedo_color=Color(spec[1])
		mat.albedo_texture=mineral
		mat.uv1_triplanar=true
		mat.uv1_world_triplanar=true
		mat.uv1_scale=Vector3.ONE*.08
		mat.roughness=1
		mat.metallic_specular=.12
		target.mats[spec[0]]=mat
	target.mats["heritage_gold"].metallic=.55
	target.mats["heritage_gold"].roughness=.36
	target.mats["heritage_water"].roughness=.22
	target.architecture_meshes["arch_ring"]=arch_mesh(false)
	target.architecture_meshes["arch_fill"]=arch_mesh(true)
	target.architecture_meshes["dome"]=lathe_mesh([Vector2(.0,.62),Vector2(.08,.54),Vector2(.18,.46),Vector2(.32,.35),Vector2(.44,.2),Vector2(.5,.06),Vector2(.49,0)],32)
	target.architecture_meshes["column"]=lathe_mesh([Vector2(.32,1),Vector2(.34,.94),Vector2(.22,.89),Vector2(.16,.8),Vector2(.13,.2),Vector2(.19,.1),Vector2(.3,.06),Vector2(.3,0)],16)

static func quad(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,d0: Vector3) -> void:
	for v in [a,b,c,a,c,d0]:
		st.add_vertex(v)

static func arch_mesh(fill: bool) -> ArrayMesh:
	var st:=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 56:
		var a:=i*PI/56
		var b:=(i+1)*PI/56
		# Nine soft cusps, a continuous extruded surface (not stacked boxes).
		var ra:=.5-.032*absf(sin(a*9))
		var rb:=.5-.032*absf(sin(b*9))
		var ia:=Vector2(cos(a)*ra,sin(a)*ra)
		var ib:=Vector2(cos(b)*rb,sin(b)*rb)
		var oa:=Vector2(ia.x,.62) if fill else Vector2(cos(a)*.59,sin(a)*.59)
		var ob:=Vector2(ib.x,.62) if fill else Vector2(cos(b)*.59,sin(b)*.59)
		var af:=Vector3(ia.x,ia.y,.5)
		var bf:=Vector3(ib.x,ib.y,.5)
		var cf:=Vector3(ob.x,ob.y,.5)
		var df:=Vector3(oa.x,oa.y,.5)
		quad(st,af,bf,cf,df)
		quad(st,df-Vector3.BACK,cf-Vector3.BACK,bf-Vector3.BACK,af-Vector3.BACK)
		quad(st,af-Vector3.BACK,bf-Vector3.BACK,bf,af)
		quad(st,df,cf,cf-Vector3.BACK,df-Vector3.BACK)
	st.generate_normals()
	return st.commit()

static func lathe_mesh(profile: Array,segments: int) -> ArrayMesh:
	var st:=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for j in range(profile.size()-1):
		for i in segments:
			var a:=TAU*i/segments
			var b:=TAU*(i+1)/segments
			var p: Vector2=profile[j]
			var q: Vector2=profile[j+1]
			quad(st,Vector3(cos(a)*p.x,p.y,sin(a)*p.x),Vector3(cos(b)*p.x,p.y,sin(b)*p.x),Vector3(cos(b)*q.x,q.y,sin(b)*q.x),Vector3(cos(a)*q.x,q.y,sin(a)*q.x))
	st.generate_normals()
	return st.commit()

func arch(at: Vector3,width: float,spring: float,rise: float,material: String,depth := .3,solid := true) -> void:
	# at is the opening's bottom centre. A clear rectangle remains below the arch.
	for side in [-1,1]:
		box(at+Vector3(side*(width/2+.09),spring/2,0),Vector3(.18,spring,depth),material,solid)
		box(at+Vector3(side*(width/2+.09),.12,0),Vector3(.29,.24,depth+.12),material)
		box(at+Vector3(side*(width/2+.09),spring-.06,0),Vector3(.32,.15,depth+.15),material)
	shape(at+Vector3(0,spring,0),Vector3(width,rise*2,depth),material,"arch_ring")

func framed_window(at: Vector3,width: float,height: float) -> void:
	box(at+Vector3(0,height*.44,-.08),Vector3(width,height*.88,.08),"heritage_ink")
	arch(at,width,height*.58,height*.37,"heritage_lime",.18,false)
	for side in [-1,1]:
		box(at+Vector3(side*width*.27,height*.38,.01),Vector3(width*.37,height*.66,.06),"arch_walnut")
		for k in 5:
			box(at+Vector3(side*width*.27,.17+k*height*.11,.05),Vector3(width*.34,.035,.025),"heritage_gold")
	box(at+Vector3(0,-.08,.18),Vector3(width*1.3,.16,.6),"heritage_lime")
	box(at+Vector3(0,height*1.03,.25),Vector3(width*1.48,.12,.85),"heritage_lime")
	for side in [-1,1]:
		rod(at+Vector3(side*width*.47,height*.82,.02),at+Vector3(side*width*.47,height,.5),.045,"heritage_lime")

func lantern(at: Vector3) -> void:
	rod(at+Vector3(0,.4,-.2),at+Vector3(0,.4,.1),.025,"heritage_ink")
	box(at+Vector3(0,.12,.1),Vector3(.18,.32,.18),"arch_neon")
	for x in [-.12,.12]:
		for z in [-.02,.22]:
			rod(at+Vector3(x,-.08,z),at+Vector3(x,.31,z),.015,"heritage_ink")
	for y in [-.09,.32]:
		box(at+Vector3(0,y,.1),Vector3(.3,.04,.3),"heritage_ink")
	shape(at+Vector3(0,.41,.1),Vector3(.3,.15,.3),"heritage_gold","cone")

func pavilion(at: Vector3,size: float) -> void:
	box(at+Vector3(0,.12,0),Vector3(size+.4,.24,size+.4),"heritage_lime")
	for x in [-1,1]:
		for z in [-1,1]:
			shape(at+Vector3(x*size*.38,.24,z*size*.38),Vector3(.62,size*.68,.62),"heritage_lime","column")
	box(at+Vector3(0,size*.68+.3,0),Vector3(size+.65,.22,size+.65),"heritage_lime")
	shape(at+Vector3(0,size*.68+.4,0),Vector3(size+.5,size*.85,size+.5),"heritage_lime","dome")
	shape(at+Vector3(0,size*1.22+.42,0),Vector3(.22,.55,.22),"heritage_gold","cone")

func jali(at: Vector3,width: float,height: float,material := "heritage_lime") -> void:
	for x in [-1,1]:
		box(at+Vector3(x*width/2,0,0),Vector3(.07,height,.09),material)
	for y in [-1,1]:
		box(at+Vector3(0,y*height/2,0),Vector3(width,.07,.09),material)
	var count:=maxi(2,int(width/.22))
	for i in count:
		var x: float=-width/2+(i+.5)*width/count
		rod(at+Vector3(x,-height/2,0),at+Vector3(x,height/2,0),.015,material)
	for i in range(1,maxi(2,int(height/.22))):
		var y: float=-height/2+i*.22
		rod(at+Vector3(-width/2,y,0),at+Vector3(width/2,y,0),.013,material)

func date_palm(at: Vector3,scale_factor := 1.0) -> void:
	# Curved rachises and individual narrow leaflets keep the silhouette feathery.
	for i in 8:
		var y: float=(i+.5)*.4*scale_factor
		shape(at+Vector3(.04*sin(i*.3),y,0),Vector3(.24,.42,.24)*scale_factor,"arch_walnut","pot")
	var crown:=at+Vector3(0,3.3,0)*scale_factor
	for frond in 9:
		var angle: float=frond*TAU/9
		var radial:=Vector3(cos(angle),0,sin(angle))
		var across:=Vector3(-sin(angle),0,cos(angle))
		var previous:=crown
		for i in range(1,7):
			var t:=i/6.0
			var point:=crown+(radial*t*1.8+Vector3.UP*(sin(t*PI)*.55-t*.35))*scale_factor
			rod(previous,point,.018*scale_factor,"arch_leaf_dark")
			for side in [-1,1]:
				var tip: Vector3=point+(across*side*(.4*(1-t)+.12)+radial*.23-Vector3.UP*.17)*scale_factor
				shape((point+tip)/2,Vector3(.065*scale_factor,point.distance_to(tip),.025*scale_factor),"arch_leaf" if frond%2 else "arch_leaf_dark","sphere",Basis(Quaternion(Vector3.UP,(tip-point).normalized())))
			previous=point
