"""Native geometry pass: face proportions, individual hair strands, spherical eyes.
Uses approved 03C adaptation as a base. Does not alter the approved design sheet.
"""
import bpy, pathlib, math, random
from mathutils import Vector
from mathutils.bvhtree import BVHTree
ROOT=pathlib.Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'tools/source/hero_approved.blend'))
rig=next(o for o in bpy.data.objects if o.type=='ARMATURE')
random.seed(31)
# Record changes in a sibling model to allow visual comparison against installed v04.
def sculpt(co):
 x,y,z=co
 w=max(0,min(1,(z-1.44)/.04))
 if w:
  jaw=math.exp(-((z-1.50)/.055)**2)
  x*=1+.10*jaw*w
  # Reduce the long pointed lower face and high forehead.
  z=1.58+(z-1.58)*(1-.08*w)
  # Fit the eye opening to the reference's softer, more open eyelids.
  eye_weight=math.exp(-((abs(x)-.0308)/.016)**2-((z-1.586)/.013)**2)*max(0,min(1,(-y-.105)/.025))
  z+=(z-1.586)*.24*eye_weight
  # Preserve a natural bridge; reduce the projecting generic nose tip.
  nose=math.exp(-(x/.018)**2-((z-1.552)/.025)**2)
  y+=.006*nose*max(0,min(1,(-y-.13)/.02))
 return Vector((x,y,z))
for o in list(bpy.data.objects):
 if o.type!='MESH':continue
 if 'low-poly' in o.name:
  bpy.data.objects.remove(o,do_unlink=True);continue
 if o.data.shape_keys:
  for key in o.data.shape_keys.key_blocks:
   for v in key.data:v.co=sculpt(v.co)
 else:
  for v in o.data.vertices:v.co=sculpt(v.co)
 if 'short01' in o.name:
  for v in o.data.vertices:
   x,y,z=v.co
   front=max(0,min(1,(-y-.075)/.055))
   band=math.exp(-((z-1.674)/.045)**2)
   v.co.z-=.014*front*band*(.75+.25*math.sin(x*95))
 if 't-shirt' in o.name:
  # Relax the tucked-in waist and add restrained cloth compression folds.
  for v in o.data.vertices:
   x,y,z=v.co
   w=math.exp(-((z-1.01)/.10)**2)
   v.co.x*=1+.055*w
   v.co.y+=math.copysign(.008*w,y)
   v.co.y+=.0025*math.sin(z*125+x*32)*w
 for p in o.data.polygons:p.use_smooth=True

def material(name,color,roughness=.7):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
 b=m.node_tree.nodes.get('Principled BSDF');b.inputs['Base Color'].default_value=(*color,1);b.inputs['Roughness'].default_value=roughness
 return m
white=material('HeroEye_Sclera',(.63,.61,.55),.24)
pupil=material('HeroEye_Pupil',(.002,.0015,.001),.16)
iris_mats=[material('HeroEye_Iris_%d'%i,(.065+i*.008,.033+i*.004,.013+i*.002),.32) for i in range(8)]
hair_mats=[material('HeroHair_Strand_%d'%i,(.009+i*.002,.007+i*.0017,.005+i*.0013),.65) for i in range(5)]
# All new components use the same object space and skin bind as the original mesh.
body=bpy.data.objects['Shyam']
def bind(o):
 o.parent=body.parent;o.matrix_parent_inverse=body.matrix_parent_inverse.copy();o.matrix_basis=body.matrix_basis.copy()
 group=o.vertex_groups.new(name='head');group.add(list(range(len(o.data.vertices))),1,'REPLACE')
 mod=o.modifiers.new('HeroSkin','ARMATURE');mod.object=rig
 for p in o.data.polygons:p.use_smooth=True
for side in [-1,1]:
 center=sculpt(Vector((side*.0308,-.1265,1.587)))
 bpy.ops.mesh.primitive_uv_sphere_add(segments=32,ring_count=20,radius=.0129,location=(0,0,0))
 eye=bpy.context.object;eye.name='HeroEye_Sclera_'+str(side)
 for v in eye.data.vertices:v.co+=center
 eye.data.materials.append(white);bind(eye)
 # Curved iris and black pupil are actual geometry, not a painted white eyeball.
 vertices=[];faces=[];rings=5;segments=48
 for r in range(rings+1):
  radius=.0060*r/rings
  for j in range(segments):
   a=j*math.tau/segments
   vertices.append(center+Vector((math.cos(a)*radius,-math.sqrt(.0129**2-radius**2)-.00007,math.sin(a)*radius)))
 for r in range(rings):
  for j in range(segments):faces.append((r*segments+j,r*segments+(j+1)%segments,(r+1)*segments+(j+1)%segments,(r+1)*segments+j))
 mesh=bpy.data.meshes.new('IrisGeometry');mesh.from_pydata(vertices,[],faces);mesh.update()
 o=bpy.data.objects.new('HeroEye_Iris_'+str(side),mesh);bpy.context.collection.objects.link(o)
 for m in [pupil]+iris_mats:o.data.materials.append(m)
 for p in mesh.polygons:
  ring=p.index//segments
  p.material_index=0 if ring<2 else 1+(p.index*7+ring)%8
 bind(o)
# Fine swept strands break up the smooth cap. Each is a 3D tapered fiber.
cap=next(o for o in bpy.data.objects if o.type=='MESH' and 'short01' in o.name)
cap_bvh=BVHTree.FromPolygons([v.co for v in cap.data.vertices],[tuple(p.vertices) for p in cap.data.polygons])
scalp_center=Vector((0,-.025,1.59))
curves=[]
for i in range(470):
 theta=random.uniform(-math.pi,math.pi);phi=random.uniform(.12,1.1)
 x=.073*math.sin(phi)*math.cos(theta)
 y=-.025+.087*math.sin(phi)*math.sin(theta)
 z=1.630+.075*math.cos(phi)
 # Let the fringe extend over the front rather than forming a tall quiff.
 length=random.uniform(.020,.048)
 if i>=330:
  x=random.uniform(-.064,.055);y=-.095+random.uniform(-.008,.008);z=1.695+random.uniform(-.006,.009)
  length=random.uniform(.035,.052)
 curve=bpy.data.curves.new('HairFiber','CURVE');curve.dimensions='3D';curve.resolution_u=1;curve.bevel_depth=random.uniform(.00022,.00045);curve.bevel_resolution=1
 spline=curve.splines.new('POLY');spline.points.add(7)
 for k,p in enumerate(spline.points):
  t=k/7
  co=sculpt(Vector((x+.018*t,y-length*t,z+.012*math.sin(t*math.pi)-(.050 if i>=330 else .006)*t*t)))
  hit=cap_bvh.find_nearest(co)
  if hit[0] is not None:
   co=hit[0]+(hit[0]-scalp_center).normalized()*(.0006+.0028*math.sin(t*math.pi))
  p.co=(*co,1);p.radius=max(.05,1-t*.92)
 o=bpy.data.objects.new('HairFiber',curve);bpy.context.collection.objects.link(o);o.data.materials.append(hair_mats[i%5]);curves.append(o)
bpy.ops.object.select_all(action='DESELECT')
for o in curves:o.select_set(True)
bpy.context.view_layer.objects.active=curves[0];bpy.ops.object.convert(target='MESH');bpy.ops.object.join()
hair=bpy.context.object;hair.name='HeroHair_Fibers';bind(hair)
bpy.ops.object.select_all(action='SELECT')
bpy.context.view_layer.objects.active=rig
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'tools/source/hero_v05.blend'))
bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets/characters/shyam_hero_v05.glb'),export_format='GLB',use_selection=True,export_animations=True,export_animation_mode='ACTIONS',export_force_sampling=True,export_morph=True,export_yup=True)
print('REFINED_HERO_EXPORTED',flush=True)
