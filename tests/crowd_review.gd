extends SceneTree
func _initialize() -> void:
 call_deferred("run")
func run() -> void:
 var stage:=Node3D.new()
 root.add_child(stage)
 var environment:=WorldEnvironment.new()
 var env:=Environment.new()
 env.background_mode=Environment.BG_COLOR
 env.background_color=Color("c1b7a4")
 env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color=Color.WHITE
 env.ambient_light_energy=.65
 environment.environment=env
 stage.add_child(environment)
 var light:=DirectionalLight3D.new()
 light.rotation_degrees=Vector3(-40,-30,0)
 light.light_energy=1.2
 stage.add_child(light)
 var camera:=Camera3D.new()
 stage.add_child(camera)
 camera.position=Vector3(0,1.8,-6.5)
 camera.look_at(Vector3(0,1,0))
 camera.fov=48
 camera.make_current()
 var figures=[]
 for i in 11:
  var human=load("res://human.gd").new()
  human.crowd=true
  human.kind="child" if i>=8 else ("elder" if i>=6 else "adult")
  human.variant=i-8 if i>=8 else (i if i<6 else i-6)
  human.position=Vector3((i-5)*.72,0,0)
  stage.add_child(human)
  figures.append(human)
  if human.legacy_model:
   push_error("Missing crowd variant");quit(1);return
 for i in 15:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://designs/20-jaipur-road-and-people/engine-residents.png")
 for h in figures:
  assert(h.animator.has_animation("Walk"))
  h.movement_speed=1.3
 for i in 30:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://designs/20-jaipur-road-and-people/engine-residents-walking.png")
 print("CROWD REVIEW: 11 distinct assets loaded and animated")
 quit()
