extends SceneTree
## Catch invisible/inverted surfaces and shared-transform regressions.
var failures:=0
var statistics: Dictionary={}
func _initialize() -> void: call_deferred("run")
func expect(ok: bool,message: String) -> void:
	if not ok:
		failures+=1
		push_error(message)
func run() -> void:
	for kind in ["sedan","taxi","police","suv","ambulance"]:
		var car=load("res://vehicle_design.gd").new()
		car.style=kind
		root.add_child(car)
		var duplicate=load("res://vehicle_design.gd").new()
		duplicate.style=kind
		root.add_child(duplicate)
		expect(car.get_child(0).mesh==duplicate.get_child(0).mesh,kind+": cached geometry shared")
		var mesh: ArrayMesh=car.get_child(0).mesh
		# A ray through the driver's torso must not hit a painted bonnet slab.
		var shell:=mesh.surface_get_arrays(0)
		var vertices: PackedVector3Array=shell[Mesh.ARRAY_VERTEX]
		var indices: PackedInt32Array=shell[Mesh.ARRAY_INDEX]
		var cabin_blocked:=false
		for i in range(0,indices.size(),3):
			var hit=Geometry3D.ray_intersects_triangle(Vector3(.39,car.roof_height-.15,-.3),Vector3.DOWN,vertices[indices[i]],vertices[indices[i+1]],vertices[indices[i+2]])
			if hit!=null and hit.y>car.belt-.2: cabin_blocked=true; break
		expect(not cabin_blocked,kind+": no body slab occludes driver torso")
		var triangles:=0
		for instance in [car.get_child(0),car.wheels[0].get_child(0)]:
			var m: ArrayMesh=instance.mesh
			for s in m.get_surface_count():
				var a:=m.surface_get_arrays(s)
				triangles+=a[Mesh.ARRAY_INDEX].size()/3
				for n in a[Mesh.ARRAY_NORMAL]: expect(n.is_finite(),kind+": finite shading normals")
		var wheel_mesh: ArrayMesh=car.wheels[0].get_child(0).mesh
		var rubber:=wheel_mesh.surface_get_arrays(0)
		var count:=0
		var outward:=0.0
		for i in rubber[Mesh.ARRAY_VERTEX].size():
			var p: Vector3=rubber[Mesh.ARRAY_VERTEX][i]
			if Vector2(p.y,p.z).length()>car.tire_radius-.015:
				outward+=rubber[Mesh.ARRAY_NORMAL][i].dot(Vector3(0,p.y,p.z).normalized())
				count+=1
		expect(count>100 and outward/count>.7,kind+": tyre tread normals point outward")
		car.animate_wheels(1,.8)
		expect(absf(car.wheels[0].rotation.y)>.01,kind+": front axle steers")
		expect(is_zero_approx(car.wheels[1].rotation.y),kind+": rear axle stays straight")
		expect(duplicate.wheels[0].get_child(0).rotation.is_zero_approx(),kind+": shared mesh does not share wheel rotation")
		statistics[kind]={"body_and_one_wheel_triangles":triangles,"body_surfaces":mesh.get_surface_count()}
		car.queue_free()
		duplicate.queue_free()
	print("VEHICLE GEOMETRY RESULT: ",failures," failures ",JSON.stringify(statistics))
	quit(1 if failures else 0)
