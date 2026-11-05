extends SceneTree
## Actual engine captures, not generated concept images.
const OUT := "res://designs/05-city-refresh/"
var scene: Node3D
var camera: Camera3D
func _initialize() -> void:
	call_deferred("capture")
func settle(count := 12) -> void:
	for i in count:
		await process_frame
	await RenderingServer.frame_post_draw
func shot(filename: String) -> void:
	await settle()
	root.get_texture().get_image().save_png(OUT+filename+".png")
	print("CAPTURED ",filename)
func capture() -> void:
	scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	DirAccess.make_dir_recursive_absolute(OUT)
	await settle(60)
	await shot("01-gameplay")
	scene.hud.map_open=true
	scene.hud.services_tab=true
	await shot("02-atlas-services")
	scene.hud.map_open=false
	scene.hud.hide()
	scene.actions.hide()
	scene.actions.set_process(false)
	camera=Camera3D.new()
	camera.fov=48
	scene.add_child(camera)
	camera.make_current()
	var car: Vector3=scene.vehicle.position
	camera.position=car+Vector3(5,3.2,5)
	camera.look_at(car+Vector3(0,.7,0))
	await shot("03-vehicle")
	for i in scene.world.services.size():
		var poi: Dictionary=scene.world.services[i]
		var b: Dictionary=poi.building
		var basis:=Basis(Vector3.UP,poi.rotation)
		var base:=Vector3(b.x,scene.world.terrain_height(b.x,b.z),b.z)
		scene.player.position=Vector3(poi.p[0],base.y+1,poi.p[1])
		scene.player.velocity=Vector3.ZERO
		scene.world.update_cells(base)
		camera.fov=70 if poi.kind=="grocery" else 48
		camera.position=base+basis*Vector3(0,3.3,b.d/2+6.5) if poi.kind=="grocery" else base+basis*Vector3(b.w*.15,4.4,b.d/2+11)
		camera.look_at(base+Vector3(0,2.4,0))
		await shot("%02d-%s"%[i+4,poi.kind])
	quit()
