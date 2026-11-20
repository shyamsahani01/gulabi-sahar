extends Node3D

var camera: Camera3D
var title: Label
var view_index := 0
var dragging := false
var focus := Vector3(0,9,0)
var orbit_yaw := .72
var orbit_pitch := .18
var orbit_distance := 66.0
const VIEWS = [
 ["FRONT / facade proportions", Vector3(0,7,62), Vector3(0,10.0,0), 49.0],
 ["CORNER / gallery depth", Vector3(44,12,53), Vector3(0,9,0), 51.0],
 ["ENTRY / recessed shops and steps", Vector3(12,3.0,30), Vector3(-1,6,13), 60.0],
 ["SIDE / arcade and balconies", Vector3(46,7,-3), Vector3(9,9,0), 65.0],
 ["OPENINGS / stone thickness and rails", Vector3(-4,16,31), Vector3(-4,16,13), 64.0]
]

func _ready() -> void:
 var environment := Environment.new()
 environment.background_mode=Environment.BG_SKY
 var sky := Sky.new()
 var sky_material := ProceduralSkyMaterial.new()
 sky_material.sky_top_color=Color("769eb8")
 sky_material.sky_horizon_color=Color("cfd7d7")
 sky_material.ground_bottom_color=Color("706958")
 sky_material.ground_horizon_color=Color("cfd7d7")
 sky.sky_material=sky_material
 environment.sky=sky
 environment.ambient_light_source=Environment.AMBIENT_SOURCE_SKY
 environment.ambient_light_energy=.45
 environment.tonemap_mode=Environment.TONE_MAPPER_ACES
 var world_env := WorldEnvironment.new()
 world_env.environment=environment
 add_child(world_env)
 var sun := DirectionalLight3D.new()
 sun.rotation_degrees=Vector3(-48,-32,0)
 sun.light_color=Color("fff0d5")
 sun.light_energy=1.2
 sun.shadow_enabled=true
 sun.directional_shadow_max_distance=120
 sun.shadow_bias=.035
 sun.shadow_normal_bias=.5
 add_child(sun)
 var model_path := "res://cinestar-study-lod1.glb" if "--lod" in OS.get_cmdline_user_args() else "res://cinestar-study.glb"
 var model: Node3D=load(model_path).instantiate()
 add_child(model)
 surface_pass(model)
 var floor_mesh := MeshInstance3D.new()
 var plane := PlaneMesh.new()
 plane.size=Vector2(220,220)
 floor_mesh.mesh=plane
 floor_mesh.material_override=surface(Color("8b8071"),2)
 floor_mesh.position.y=-.035
 add_child(floor_mesh)
 camera=Camera3D.new()
 camera.near=.15
 camera.far=300
 add_child(camera)
 camera.make_current()
 var layer := CanvasLayer.new()
 add_child(layer)
 title=Label.new()
 title.position=Vector2(36,30)
 title.add_theme_font_size_override("font_size",22)
 title.add_theme_color_override("font_color",Color("202a2d"))
 layer.add_child(title)
 var caption := Label.new()
 caption.position=Vector2(36,940)
 caption.add_theme_font_size_override("font_size",17)
 caption.add_theme_color_override("font_color",Color("f5f1e6"))
 caption.add_theme_color_override("font_shadow_color",Color("272621"))
 caption.add_theme_constant_override("shadow_offset_x",1)
 caption.add_theme_constant_override("shadow_offset_y",1)
 caption.text="EXTERIOR STUDY 01  /  Approximate dimensions  /  Original geometry  /  Godot Mobile renderer\n1–5: saved views   •   Drag: orbit   •   Wheel: zoom   •   Esc: close"
 layer.add_child(caption)
 show_view(0)
 if "--capture" in OS.get_cmdline_user_args():
  await capture()

func surface(color: Color, kind: int) -> ShaderMaterial:
 var mat := ShaderMaterial.new()
 mat.shader=load("res://surface.gdshader")
 mat.set_shader_parameter("base_color",color)
 mat.set_shader_parameter("surface_kind",float(kind))
 return mat

func surface_pass(node: Node) -> void:
 if node is MeshInstance3D:
  for i in node.mesh.get_surface_count():
   var mat: Material=node.mesh.surface_get_material(i)
   if mat==null:continue
   if mat.resource_name.begins_with("Stone_sandstone"):
    node.set_surface_override_material(i,surface(Color("c49b7e"),0))
   elif mat.resource_name.begins_with("Panel_"):
    node.set_surface_override_material(i,surface(Color("deded0"),1))
 for child in node.get_children():surface_pass(child)

func show_view(index: int) -> void:
 view_index=index
 camera.position=VIEWS[index][1]
 focus=VIEWS[index][2]
 camera.fov=VIEWS[index][3]
 camera.look_at(focus)
 var offset := camera.position-focus
 orbit_distance=offset.length()
 orbit_yaw=atan2(offset.x,offset.z)
 orbit_pitch=asin(offset.y/orbit_distance)
 title.text="CINESTAR / 3D MODEL REVIEW\n"+VIEWS[index][0]

func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed:
  if event.keycode==KEY_ESCAPE:get_tree().quit()
  if event.keycode>=KEY_1 and event.keycode<=KEY_5:show_view(event.keycode-KEY_1)
 if event is InputEventMouseButton:
  if event.button_index==MOUSE_BUTTON_LEFT:dragging=event.pressed
  if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
   orbit_distance=clampf(orbit_distance*(.9 if event.button_index==MOUSE_BUTTON_WHEEL_UP else 1.1),5,120)
   orbit()
 if event is InputEventMouseMotion and dragging:
  orbit_yaw-=event.relative.x*.007
  orbit_pitch=clampf(orbit_pitch+event.relative.y*.005,-.2,1.2)
  orbit()

func orbit() -> void:
 camera.position=focus+Vector3(sin(orbit_yaw)*cos(orbit_pitch),sin(orbit_pitch),cos(orbit_yaw)*cos(orbit_pitch))*orbit_distance
 camera.look_at(focus)

func capture() -> void:
 var names := ["front","corner","entrance","side","openings"]
 for i in VIEWS.size():
  var distant := "--lod" in OS.get_cmdline_user_args()
  if distant and i!=1:continue
  show_view(i)
  for frame in 16:await get_tree().process_frame
  await RenderingServer.frame_post_draw
  var suffix := "-lod1" if distant else ""
  var error := get_viewport().get_texture().get_image().save_png("res://engine-"+names[i]+suffix+".png")
  if error!=OK:
   push_error("Capture failed: "+names[i])
   get_tree().quit(1)
   return
  print("CAPTURE ",names[i])
 get_tree().quit()
