extends SceneTree
## Independent ray probes verify that the signature openings are real geometry.
var failures := 0
var checks: Array = []

func _initialize() -> void:
 call_deferred("run")

func check(ok: bool, description: String) -> void:
 checks.append({"passed":ok,"description":description})
 if not ok:
  failures+=1
  push_error(description)

func colliders(node: Node) -> void:
 if node is MeshInstance3D:
  node.create_trimesh_collision()
 for child in node.get_children():colliders(child)

func ray(space: PhysicsDirectSpaceState3D, a: Vector3, b: Vector3) -> Dictionary:
 return space.intersect_ray(PhysicsRayQueryParameters3D.create(a,b))

func run() -> void:
 var stage := Node3D.new()
 root.add_child(stage)
 var model: Node3D=load("res://cinestar-study.glb").instantiate()
 stage.add_child(model)
 colliders(model)
 for frame in 5:await physics_frame
 var space := stage.get_world_3d().direct_space_state
 for x in [-14.0,-7.2,3.0,9.8]:
  check(ray(space,Vector3(x,17.5,15),Vector3(x,17.5,13.2)).is_empty(),"Large circular opening is physically open at x="+str(x))
 check(not ray(space,Vector3(-10.6,19.1,15),Vector3(-10.6,19.1,13.2)).is_empty(),"Stone facade between openings remains solid")
 check(ray(space,Vector3(-2.1,17.5,15),Vector3(-2.1,17.5,13.2)).is_empty(),"Central keyhole opening is open")
 for y in [3.7,7.85,12.0]:
  check(ray(space,Vector3(15.25,y,15),Vector3(15.25,y,13.2)).is_empty(),"Right arch crown is open at height="+str(y))
 check(ray(space,Vector3(16.6,2,10),Vector3(16.6,2,-10)).is_empty(),"Side ground arcade has continuous clear space")
 var hit := ray(space,Vector3(17.0,7.1,11.3),Vector3(14.0,7.1,11.3))
 check(not hit.is_empty() and hit.position.x>14.8,"Recessed side window sits outside the core wall")
 var stats: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://model-stats.json"))
 check(stats.triangles<200000,"Review model is below 200k triangles after geometry cleanup")
 check(stats.lod1_triangles<stats.triangles*.4,"Distant model reduces triangles by more than 60 percent")
 var result := {"review_date":"2026-11-19","failures":failures,"checks":checks,
  "scope":"Isolated model geometry and import, not game navigation or tablet performance", "model":stats}
 var file := FileAccess.open("res://validation.json",FileAccess.WRITE)
 file.store_string(JSON.stringify(result,"  ")+"\n")
 print("CINESTAR MODEL REVIEW: ",checks.size()," checks, ",failures," failures")
 quit(1 if failures else 0)
