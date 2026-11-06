extends RefCounted
static func install(world: Node3D) -> void:
	var colors: Dictionary={"arch_white":"eeeae2","arch_plaster":"c3c0b8","arch_black":"151719","arch_frame":"22262a","arch_walnut":"513120","arch_oak":"8a4b2a","arch_cane":"c9ad7a","arch_cushion":"a9a49c","arch_rope":"d8d3bb","arch_green":"315f50","arch_turf":"3f6a43","arch_soil":"352b22","arch_leaf":"5d8745","arch_leaf_dark":"33502c","arch_step":"a3a7a4","arch_teal":"187b85","arch_red":"a62f32","arch_glazing":"5c7f8a","arch_seam":"797c79","arch_rust":"b9775a","arch_ceiling":"e8e1d3","arch_banner":"5b3324","arch_berry":"b7322c","arch_cream":"e4ddcf","arch_quartz":"dcd8cf"}
	for key in colors:
		var mat:=StandardMaterial3D.new()
		mat.albedo_color=Color(colors[key])
		mat.roughness=.82
		mat.metallic_specular=.22
		world.mats[key]=mat
	# Existing CC0 textures, correctly scaled in metres instead of per tiny primitive.
	for spec in [["arch_walnut","wood_Diffuse.jpg",Vector3(.24,1,.6)],["arch_oak","wood_Diffuse.jpg",Vector3(.18,.6,.6)],["arch_plaster","plaster_Diffuse.jpg",Vector3(.28,.28,.28)],["arch_step","concrete_Diffuse.jpg",Vector3(.18,.18,.18)],["arch_rust","roughplaster_Diffuse.jpg",Vector3(.3,.3,.3)],["arch_cream","plasterwall_Diffuse.jpg",Vector3(.25,.25,.25)]]:
		var mat: StandardMaterial3D=world.mats[spec[0]]
		mat.albedo_texture=load("res://assets/textures/"+spec[1])
		mat.uv1_triplanar=true
		mat.uv1_world_triplanar=true
		mat.uv1_scale=spec[2]
		mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	world.mats["arch_rust"].roughness=.9
	world.mats["arch_quartz"].roughness=.3
	world.mats["arch_quartz"].metallic_specular=.5
	for key in ["arch_walnut","arch_oak"]:
		var wood:=ShaderMaterial.new()
		wood.shader=load("res://assets/textures/cafe_wood.gdshader")
		wood.set_shader_parameter("grain",load("res://assets/textures/wood_Diffuse.jpg"))
		if key=="arch_oak":
			# Photographed floor: warm honey-to-chestnut planks with a soft sheen.
			wood.set_shader_parameter("dark_color",Color("5a2c16"))
			wood.set_shader_parameter("light_color",Color("b3652f"))
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
	var strip:=StandardMaterial3D.new()
	strip.albedo_color=Color("fff1cf")
	strip.emission_enabled=true
	strip.emission=Color("ffe3a8")
	strip.emission_energy_multiplier=1.1
	world.mats["arch_strip"]=strip
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
	var cone:=CylinderMesh.new()
	cone.top_radius=.14
	cone.bottom_radius=.5
	cone.height=1
	cone.radial_segments=16
	cone.rings=1
	world.architecture_meshes["cone"]=cone
