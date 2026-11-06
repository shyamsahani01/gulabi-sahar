extends RefCounted
static func install(world: Node3D) -> void:
	var colors: Dictionary={"arch_white":"eeeae2","arch_plaster":"bcbeb8","arch_black":"151719","arch_frame":"58665d","arch_walnut":"513120","arch_oak":"c48442","arch_cane":"bda375","arch_cushion":"b5aca0","arch_rope":"d3d0b9","arch_green":"315f50","arch_turf":"36543b","arch_soil":"352b22","arch_leaf":"557b3e","arch_leaf_dark":"314d2b","arch_step":"a3a7a4","arch_teal":"187b85","arch_red":"a62f32","arch_glazing":"45636b","arch_seam":"797c79"}
	for key in colors:
		var mat:=StandardMaterial3D.new()
		mat.albedo_color=Color(colors[key])
		mat.roughness=.82
		mat.metallic_specular=.22
		world.mats[key]=mat
	# Existing CC0 textures, correctly scaled in metres instead of per tiny primitive.
	for spec in [["arch_walnut","wood_Diffuse.jpg",Vector3(.24,1,.6)],["arch_oak","wood_Diffuse.jpg",Vector3(.18,.6,.6)],["arch_plaster","paintedwall_Diffuse.jpg",Vector3(.2,.2,.2)],["arch_step","concrete_Diffuse.jpg",Vector3(.18,.18,.18)]]:
		var mat: StandardMaterial3D=world.mats[spec[0]]
		mat.albedo_texture=load("res://assets/textures/"+spec[1])
		mat.uv1_triplanar=true
		mat.uv1_world_triplanar=true
		mat.uv1_scale=spec[2]
		mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	for key in ["arch_walnut","arch_oak"]:
		var wood:=ShaderMaterial.new()
		wood.shader=load("res://assets/textures/cafe_wood.gdshader")
		wood.set_shader_parameter("grain",load("res://assets/textures/wood_Diffuse.jpg"))
		if key=="arch_oak":
			wood.set_shader_parameter("dark_color",Color("a8642d"))
			wood.set_shader_parameter("light_color",Color("d69b55"))
		world.mats[key]=wood
	var glass:=StandardMaterial3D.new()
	glass.albedo_color=Color(.65,.8,.79,.09)
	glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.cull_mode=BaseMaterial3D.CULL_DISABLED
	glass.roughness=.16
	world.mats["arch_glass"]=glass
	var neon:=StandardMaterial3D.new()
	neon.albedo_color=Color("ffdf9f")
	neon.emission_enabled=true
	neon.emission=Color("ffd78e")
	neon.emission_energy_multiplier=1.7
	world.mats["arch_neon"]=neon
	var cylinder:=CylinderMesh.new()
	cylinder.top_radius=.5
	cylinder.bottom_radius=.5
	cylinder.height=1
	cylinder.radial_segments=16
	cylinder.rings=1
	world.architecture_meshes["cylinder"]=cylinder
	var pot_mesh:=CylinderMesh.new()
	pot_mesh.top_radius=.5
	pot_mesh.bottom_radius=.34
	pot_mesh.height=1
	pot_mesh.radial_segments=16
	pot_mesh.rings=1
	world.architecture_meshes["pot"]=pot_mesh
