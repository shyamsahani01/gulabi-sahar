extends "res://heritage_kit.gd"
## Pack 20: photo-informed western Cinestar block. Widths are visual estimates in the compact map.
const STUDY = preload("res://cinestar_street.gd")
static func prepare(data: Dictionary) -> void:
 for road in data.roads:
  if int(road.id)==STUDY.ROAD_ID:
   road["segment_widths"]=[]
   for i in range(road.p.size()-1):road.segment_widths.append(9.0 if i<2 else road.width)
   road["jaipur_block"]=true
 # Only generated facade plots move to make room for parking and a walkable pavement.
 var direction: Vector2=STUDY.START.direction_to(STUDY.END)
 var normal:=Vector2(-direction.y,direction.x)
 for b in data.buildings:
  if not b.has("cinestar_street"):continue
  var point:=Vector2(b.x,b.z)
  var side: float=direction.cross(point-STUDY.START)
  var bx:=Vector2(cos(b.a),-sin(b.a))
  var bz:=Vector2(sin(b.a),cos(b.a))
  var extent: float=absf(normal.dot(bx))*b.w/2+absf(normal.dot(bz))*b.d/2
  var required: float=11.0+extent
  if absf(side)<required:
   point+=normal*signf(side)*(required-absf(side))
   b.x=point.x;b.z=point.y

func install_materials() -> void:
 for spec in [["jaipur_asphalt","77746b",false],["jaipur_dust","a49a82",false],["jaipur_pavers","b9aa91",true]]:
  var mat:=ShaderMaterial.new()
  mat.shader=preload("res://assets/shaders/jaipur_street.gdshader")
  mat.set_shader_parameter("surface_color",Color(spec[1]))
  mat.set_shader_parameter("paving",spec[2])
  world.mats[spec[0]]=mat

func other_road(at: Vector2,radius: float) -> bool:
 for road in world.data.roads:
  if int(road.id)==STUDY.ROAD_ID:continue
  for i in range(road.p.size()-1):
   var a:=Vector2(road.p[i][0],road.p[i][1])
   var b:=Vector2(road.p[i+1][0],road.p[i+1][1])
   if Geometry2D.get_closest_point_to_segment(at,a,b).distance_to(at)<world.road_segment_width(road,i)/2+radius:return true
 return false

func streetscape(target: Node3D) -> void:
 world=target
 var start: Vector2=STUDY.START*world.CITY_COMPRESSION
 var end: Vector2=STUDY.END*world.CITY_COMPRESSION
 var direction:=start.direction_to(end)
 var normal:=Vector2(-direction.y,direction.x)
 var angle:=atan2(direction.x,direction.y)
 var length:=start.distance_to(end)
 var footpaths:=0
 var pockets:=0
 var ramps: Array=[]
 for step in range(3,int(length)-3,2):
  var center:=start+direction*step
  for side in [-1,1]:
   var apron: Vector2=center+normal*side*5.0
   # Broad dusty parking edge outside the unmarked two-way carriageway.
   if world.clear_arrival(apron,.8) and not other_road(apron,.3):
    world.road_piece(apron-direction,apron+direction,2.1,"jaipur_dust",.16)
   var at: Vector2=center+normal*side*7.2
   if not world.clear_arrival(at,1.0) or other_road(at,1.0):continue
   origin=Vector3(at.x,world.terrain_height(at.x,at.y),at.y)
   basis=Basis(Vector3.UP,angle)
   box(Vector3(0,.08,0),Vector3(1.8,.16,1.99),"jaipur_pavers",true)
   # Low pale kerb, interrupted at driveways and street junctions.
   if step%16>3:
    box(Vector3(side*.96,.12,0),Vector3(.16,.24,1.95),"arch_step")
   else:
    # A shallow driveway ramp lets the player enter without a stair-step controller.
    box(Vector3(side*1.15,.08,0),Vector3(.583,.025,1.95),"jaipur_pavers",true,Basis(Vector3.FORWARD,side*.2783))
    ramps.append([origin+basis*Vector3(side*1.65,.3,0),origin+Vector3(0,.3,0)])
   if step%12==3:
    box(Vector3(side*.96,.172,0),Vector3(.4,.018,.55),"arch_frame")
    for slot in 5:box(Vector3(side*.96,.184,-.20+slot*.10),Vector3(.33,.012,.027),"arch_step")
   footpaths+=1
 # Faded zebra stripes at both observed junction approaches, no invented central divider.
 for distance in [4.0,length-4.0]:
  origin=Vector3((start+direction*distance).x,0,(start+direction*distance).y)
  basis=Basis(Vector3.UP,angle)
  for stripe in range(-4,5):box(Vector3(stripe*.83,.17,0),Vector3(.38,.016,2.2),"heritage_lime")
 # Pedestrian routes are checked along the pavement, not placed in the traffic lane.
 for side in [-1,1]:
  for step in range(9,int(length)-18,12):
   var a: Vector2=start+direction*step+normal*side*7.2
   var b: Vector2=a+direction*8
   var clear:=true
   for k in 9:
    var at:=a.lerp(b,k/8.0)
    if not world.clear_arrival(at,.5) or other_road(at,.5):clear=false
   if clear:world.pedestrian_routes.append([Vector3(a.x,.2,a.y),Vector3(b.x,.2,b.y)])
 # Street pockets are outside the clear walking strip. Objects are fit to available plots.
 for spec in [[.12,-1,"food"],[.40,1,"food"],[.89,-1,"pottery"]]:
  var at: Vector2=start.lerp(end,spec[0])+normal*spec[1]*10.2
  var found:=false
  for shift in [0.0,-4.0,4.0,-8.0,8.0,-12.0,12.0]:
   var candidate: Vector2=at+direction*shift
   if world.clear_arrival(candidate,2.0) and not other_road(candidate,2.0):
    at=candidate;found=true;break
  if not found:continue
  origin=Vector3(at.x,world.terrain_height(at.x,at.y),at.y)
  basis=Basis(Vector3.UP,angle)
  if spec[2]=="food":food_cart()
  else:pottery()
  var vendor:=origin+basis*Vector3(1.4,0,0)
  world.patron_spots.append({"p":vendor,"yaw":angle-PI/2,"pose":"Stand","street_vendor":true})
  pockets+=1
 # Angled parked cars sit on checked shoulders, not across the footpath.
 for step in [18.0,42.0,70.0,102.0]:
  for side in [-1,1]:
   var at: Vector2=start+direction*step+normal*side*5.15
   if not world.clear_arrival(at,2.0) or other_road(at,2.0):continue
   var p:=Vector3(at.x,world.terrain_height(at.x,at.y),at.y)
   world.parked_vehicle(p,angle+.2,"car","white" if side<0 else "dark")
 var scooters:=0
 for spec in [[28.0,-1],[32.0,-1],[58.0,1],[62.0,1],[113.0,-1]]:
  var at: Vector2=start+direction*spec[0]+normal*spec[1]*5.2
  if not world.clear_arrival(at,1.4) or other_road(at,1.4):continue
  origin=Vector3(at.x,world.terrain_height(at.x,at.y)+.16,at.y)
  basis=Basis(Vector3.UP,angle+.5)
  scooter("heritage_blue" if scooters%2 else "heritage_red")
  scooters+=1
 world.set_meta("jaipur_parked_scooters",scooters)
 for step in [12.0,48.0,87.0,122.0]:
  for side in [-1,1]:
   var at: Vector2=start+direction*step+normal*side*9.5
   if world.clear_arrival(at,2.0) and not other_road(at,2.0):world.tree_at(Vector3(at.x,0,at.y))
 world.set_meta("jaipur_driveway_ramps",ramps)
 world.set_meta("jaipur_pavement_sections",footpaths)
 world.set_meta("jaipur_vendor_pockets",pockets)
 world.draw_detail=false

func food_cart() -> void:
 box(Vector3(0,.8,0),Vector3(1.8,.85,.85),"heritage_blue",true)
 box(Vector3(0,1.28,0),Vector3(2,.12,1.05),"chrome")
 for x in [-.85,.85]:
  rod(Vector3(x,.3,-.38),Vector3(x,2.25,-.38),.025,"arch_frame")
  shape(Vector3(x,.3,0),Vector3(.12,.55,.55),"kerb_black","cylinder",Basis(Vector3.FORWARD,PI/2))
 box(Vector3(0,2.25,0),Vector3(2.25,.08,1.45),"heritage_red")
 label(Vector3(0,1.02,.45),"CHAI • SNACKS",.16,"arch_white",1.7)
 for x in [-.55,0,.55]:shape(Vector3(x,1.45,0),Vector3(.27,.27,.27),"chrome")
 for x in [-1.2,1.2]:
  box(Vector3(x,.43,1.2),Vector3(.40,.07,.40),"heritage_red")
  for sx in [-.14,.14]:rod(Vector3(x+sx,0,1.2),Vector3(x+sx,.4,1.2),.025,"arch_frame")

func pottery() -> void:
 box(Vector3(0,.035,0),Vector3(3.8,.07,1.9),"jaipur_dust")
 for row in 3:
  for col in 7:
   var s: float=.3+(col%3)*.09
   shape(Vector3((col-3)*.48,s*.48,row*.48-.48),Vector3(s,s,s),"terracotta","pot")

func scooter(paint: String) -> void:
 for z in [-.62,.62]:
  shape(Vector3(0,.26,z),Vector3(.18,.52,.52),"kerb_black","cylinder",Basis(Vector3.FORWARD,PI/2))
  shape(Vector3(0,.26,z),Vector3(.19,.27,.27),"chrome","cylinder",Basis(Vector3.FORWARD,PI/2))
 box(Vector3(0,.30,0),Vector3(.48,.12,1.25),paint)
 box(Vector3(0,.55,-.35),Vector3(.54,.38,.65),paint)
 box(Vector3(0,.77,-.30),Vector3(.52,.13,.75),"arch_black")
 box(Vector3(0,.62,.50),Vector3(.48,.65,.15),paint)
 rod(Vector3(0,.25,.62),Vector3(0,1.04,.55),.035,"chrome")
 rod(Vector3(-.34,1.04,.55),Vector3(.34,1.04,.55),.027,"arch_black")
 box(Vector3(0,.90,.60),Vector3(.26,.16,.06),"arch_white")
 for x in [-.30,.30]:
  rod(Vector3(x,1.04,.55),Vector3(x,1.26,.55),.012,"chrome")
  shape(Vector3(x,1.26,.55),Vector3(.13,.08,.04),"chrome","sphere")
 rod(Vector3(0,.3,-.1),Vector3(.27,0,-.1),.018,"arch_frame")
