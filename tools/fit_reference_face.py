"""Reference-fitted facial surface study from local approved landmarks.
Approximate inferred depth, not a scan or a claim of exact reconstruction.
"""
import bpy,pathlib,json,math,shutil
from mathutils import Vector
from mathutils.bvhtree import BVHTree
ROOT=pathlib.Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'tools/source/hero_v05.blend'))
body=bpy.data.objects['Shyam'];rig=body.parent
landmarks=json.loads((ROOT/'tools/source/approved_face_landmarks.json').read_text())['landmarks']
left=landmarks[468];right=landmarks[473]
pixel_distance=math.sqrt(((right[0]-left[0])*1536)**2+((right[1]-left[1])*1024)**2)
scale=.0616/pixel_distance
raw=[Vector((p[0]*1536*scale,p[2]*1536*scale*.55,-p[1]*1024*scale)) for p in landmarks]
center=(raw[468]+raw[473])/2
x_axis=(raw[473]-raw[468]).normalized();up=(raw[10]-raw[152]).normalized();z_axis=(up-x_axis*up.dot(x_axis)).normalized();y_axis=z_axis.cross(x_axis).normalized()
points=[]
for p in raw:
 d=p-center;points.append(Vector((d.dot(x_axis),-.140+d.dot(y_axis),1.587+d.dot(z_axis))))
# Fit the face boundary to the existing skull instead of floating a mask over it.
# Old facial vertices stay as support just behind the new surface.
for key in body.data.shape_keys.key_blocks:
 for v in key.data:
  x,y,z=v.co
  if 1.46<z<1.587 and y<-.075:
   w=max(0,min(1,(z-1.46)/.025))
   v.co.z+=(1.587+(z-1.587)*.84-z)*w
base=body.data.shape_keys.key_blocks[0]
old_bvh=BVHTree.FromPolygons([v.co for v in base.data],[tuple(p.vertices) for p in body.data.polygons])
outline=[10,338,297,332,284,251,389,356,454,323,361,288,397,365,379,378,400,377,152,148,176,149,150,136,172,58,132,93,234,127,162,21,54,103,67,109]
for i,p in enumerate(points[:468]):
 d=min(math.hypot(p.x-points[j].x,p.z-points[j].z) for j in outline)
 edge=max(0,1-d/.019)**2
 hit=old_bvh.ray_cast(Vector((p.x,-1,p.z)),Vector((0,1,0)))
 if hit[0] is not None:
  p.y=p.y*(1-edge)+(hit[0].y-.001)*edge
# The inferred surface already contains reference-registered eyes. Separate sphere
# placement requires a fitted cornea rig; remove the unmatched temporary eyeballs.
for o in list(bpy.data.objects):
 if o.type=='MESH' and o.name.startswith('HeroEye'):
  bpy.data.objects.remove(o,do_unlink=True)
for o in bpy.data.objects:
 if o.type=='MESH' and 'short01' in o.name:
  for v in o.data.vertices:
   if v.co.z>1.63 and v.co.y<-.08:v.co.z+=.007
faces=[]
for line in pathlib.Path('/home/shyam/MyWork/Tools/FaceReference/canonical_face_model.obj').read_text().splitlines():
 if line.startswith('f '):faces.append(tuple(int(p.split('/')[0])-1 for p in line.split()[1:]))
face_bvh=BVHTree.FromPolygons(points[:468],faces)
for key in body.data.shape_keys.key_blocks:
 for v in key.data:
  x,y,z=v.co
  if z>1.47 and y<-.08:
   hit=face_bvh.ray_cast(Vector((x,-1,z)),Vector((0,1,0)))
   if hit[0] is not None:v.co.y=max(v.co.y,hit[0].y+.003)
mesh=bpy.data.meshes.new('ReferenceFitFace');mesh.from_pydata(points[:468],[],faces);mesh.update()
face=bpy.data.objects.new('HeroFace_ReferenceFit',mesh);bpy.context.collection.objects.link(face)
face.parent=body.parent;face.matrix_parent_inverse=body.matrix_parent_inverse.copy();face.matrix_basis=body.matrix_basis.copy()
uv=mesh.uv_layers.new(name='ReferencePhoto')
for loop in mesh.loops:
 p=landmarks[loop.vertex_index];uv.data[loop.index].uv=(p[0],1-p[1])
path=ROOT/'assets/characters/shyam_face_reference.png';shutil.copyfile(ROOT/'designs/01-character/shyam-concept-03c.png',path)
mat=bpy.data.materials.new('ReferenceFitSkin');mat.use_nodes=True
bsdf=mat.node_tree.nodes.get('Principled BSDF');bsdf.inputs['Roughness'].default_value=.75
tex=mat.node_tree.nodes.new('ShaderNodeTexImage');tex.image=bpy.data.images.load(str(path));mat.node_tree.links.new(tex.outputs['Color'],bsdf.inputs['Base Color']);face.data.materials.append(mat)
# Subdivide once before creating expressions; keep interpolated photographic UVs.
bpy.ops.object.select_all(action='DESELECT');face.select_set(True);bpy.context.view_layer.objects.active=face
sub=face.modifiers.new('SurfaceRefinement','SUBSURF');sub.levels=2;bpy.ops.object.modifier_apply(modifier=sub.name)
for p in face.data.polygons:p.use_smooth=True
face.shape_key_add(name='Basis')
eyes=[points[468],points[473]];mouth=(points[61]+points[291])/2
for name in ['BlinkLeft','BlinkRight','Smile','Serious','Surprised']:
 key=face.shape_key_add(name=name)
 for v,b in zip(key.data,face.data.shape_keys.key_blocks[0].data):
  v.co=b.co.copy();x,y,z=b.co
  if name.startswith('Blink'):
   eye=eyes[0 if name=='BlinkLeft' else 1]
   w=math.exp(-((x-eye.x)/.015)**4-((z-eye.z)/.012)**4)
   v.co.z+=(eye.z-z)*w*.92
  elif name=='Smile':
   w=math.exp(-((abs(x)-.026)/.013)**2-((z-mouth.z)/.015)**2)
   v.co.z+=.0025*w;v.co.x+=math.copysign(.0015*w,x)
  elif name=='Serious':
   w=math.exp(-((abs(x)-.025)/.016)**2-((z-1.613)/.012)**2)
   v.co.z-=.0024*w;v.co.x-=math.copysign(.001*w,x)
  else:
   w=math.exp(-((abs(x)-.025)/.019)**2-((z-1.613)/.015)**2)
   v.co.z+=.0038*w
# Face shares the head bind. The existing sphere eyes now sit in the fitted sockets.
group=face.vertex_groups.new(name='head');group.add(list(range(len(face.data.vertices))),1,'REPLACE')
mod=face.modifiers.new('HeadSkin','ARMATURE');mod.object=rig
bpy.ops.object.select_all(action='SELECT');bpy.context.view_layer.objects.active=rig
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'tools/source/hero_reference_fit.blend'))
bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets/characters/shyam_hero_v06.glb'),export_format='GLB',use_selection=True,export_animations=True,export_animation_mode='ACTIONS',export_force_sampling=True,export_morph=True,export_yup=True)
print('REFERENCE_FIT_EXPORTED',len(face.data.vertices),'eye distance',pixel_distance,'scale',scale,flush=True)
