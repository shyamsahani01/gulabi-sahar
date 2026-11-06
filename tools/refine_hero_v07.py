"""Bake fitted facial detail onto a continuous skinned head; preserve the rig/morphs.
Run with Blender 5.2: blender --background --python tools/refine_hero_v07.py.
This improves seams, clothing and hair. It does not reconstruct a scanned head or
claim a complete articulated eye rig. Source images and prior candidates are kept.
"""
import bpy, math, random, pathlib
from mathutils import Vector
from mathutils.bvhtree import BVHTree
from mathutils.geometry import barycentric_transform
ROOT=pathlib.Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'tools/source/hero_v05.blend'))
original_keys={key.name:[v.co.copy() for v in key.data] for key in bpy.data.objects['Shyam'].data.shape_keys.key_blocks}
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'tools/source/hero_reference_fit.blend'))
body=bpy.data.objects['Shyam']; face=bpy.data.objects['HeroFace_ReferenceFit'];rig=body.parent
# Keep all local texture dependencies reproducible when opening on another machine.
for image in bpy.data.images:
 if image.name=='short01_diffuse.png':image.filepath=str(ROOT/'assets/characters/shyam_short01_diffuse.png')
 elif image.name=='brown_eye.png':image.filepath=str(ROOT/'assets/characters/shyam_brown_eye.png')
face.data.calc_loop_triangles();triangles=list(face.data.loop_triangles)
points=[v.co.copy() for v in face.data.vertices]
bvh=BVHTree.FromPolygons(points,[tuple(t.vertices) for t in triangles],all_triangles=True)
face_uv=face.data.uv_layers[0]
uv=body.data.uv_layers.new(name='FittedReferenceUV')
mask=body.data.color_attributes.new(name='FittedBlend',type='FLOAT_COLOR',domain='POINT')
def smooth(v):
 v=max(0,min(1,v));return v*v*(3-2*v)
for key in body.data.shape_keys.key_blocks:
 for i,v in enumerate(key.data):
  if original_keys[key.name][i].z>1.43:
   v.co=original_keys[key.name][i].copy()
   if 1.46<v.co.z<1.587 and v.co.y<-.075:
    w=max(0,min(1,(v.co.z-1.46)/.025));v.co.z+=(1.587+(v.co.z-1.587)*.84-v.co.z)*w
# Update the rest mesh before reading its outer-surface normals.
for i,v in enumerate(body.data.vertices):v.co=body.data.shape_keys.key_blocks['Basis'].data[i].co
body.data.update()
base=body.data.shape_keys.key_blocks['Basis'];projected={};weights={} 
for i,v in enumerate(base.data):
 x,y,z=v.co;weights[i]=0
 if y>-.06 or not 1.475<z<1.65:continue
 hit,normal,index,distance=bvh.ray_cast(Vector((x,-1,z)),Vector((0,1,0)))
 if hit is None:continue
 # Feather the photo into the existing whole-head skin before its outer boundary.
 w=smooth((.067-abs(x))/.018)*smooth((z-1.488)/.018)*smooth((1.632-z)/.018)*smooth((-y-.065)/.025)
 if w<=0:continue
 tri=triangles[index]
 coords=[Vector((*face_uv.data[j].uv,0)) for j in tri.loops]
 projected[i]=barycentric_transform(hit,*[points[j] for j in tri.vertices],*coords)
 weights[i]=w
 dy=(hit.y-y)*w if body.data.vertices[i].normal.y<-.05 else 0.0
 for key in body.data.shape_keys.key_blocks:key.data[i].co.y+=dy
for i,entry in enumerate(mask.data):entry.color=(weights[i],)*3+(1,)
for loop in body.data.loops:
 point=projected.get(loop.vertex_index,Vector((.77,.55,0)))
 uv.data[loop.index].uv=(point.x,point.y)
original_uv=body.data.uv_layers[0];body.data.uv_layers.active=original_uv
mat=bpy.data.materials.new('ContinuousHead_Bake');mat.use_nodes=True
nodes=mat.node_tree.nodes;nodes.clear();links=mat.node_tree.links
out=nodes.new('ShaderNodeOutputMaterial');emit=nodes.new('ShaderNodeEmission');links.new(emit.outputs[0],out.inputs['Surface'])
old=nodes.new('ShaderNodeTexImage');old.image=bpy.data.images.load(str(ROOT/'assets/characters/shyam_young_lightskinned_male_diffuse3.png'))
u=nodes.new('ShaderNodeUVMap');u.uv_map=original_uv.name;links.new(u.outputs[0],old.inputs[0])
photo=nodes.new('ShaderNodeTexImage');photo.image=bpy.data.images.load(str(ROOT/'assets/characters/shyam_face_reference.png'));photo.extension='EXTEND'
u=nodes.new('ShaderNodeUVMap');u.uv_map=uv.name;links.new(u.outputs[0],photo.inputs[0])
attr=nodes.new('ShaderNodeVertexColor');attr.layer_name=mask.name
mix=nodes.new('ShaderNodeMixRGB');links.new(attr.outputs[0],mix.inputs[0]);tint=nodes.new('ShaderNodeMixRGB');tint.blend_type='MULTIPLY';tint.inputs[0].default_value=1;tint.inputs[2].default_value=(1.0,.89,.79,1);links.new(old.outputs[0],tint.inputs[1]);links.new(tint.outputs[0],mix.inputs[1]);links.new(photo.outputs[0],mix.inputs[2]);links.new(mix.outputs[0],emit.inputs[0])
body.data.materials.clear();body.data.materials.append(mat)
for polygon in body.data.polygons:polygon.material_index=0;polygon.use_smooth=True
for modifier in body.modifiers:modifier.show_viewport=False;modifier.show_render=False
for key in body.data.shape_keys.key_blocks:key.value=0
baked=bpy.data.images.new('shyam_continuous_skin',width=2048,height=2048,alpha=False)
target=nodes.new('ShaderNodeTexImage');target.image=baked;nodes.active=target
bpy.ops.object.select_all(action='DESELECT');body.select_set(True);bpy.context.view_layer.objects.active=body
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=1;scene.render.bake.margin=12
bpy.ops.object.bake(type='EMIT')
baked.filepath_raw=str(ROOT/'assets/characters/shyam_continuous_skin.png');baked.file_format='PNG';baked.save()
nodes.clear();out=nodes.new('ShaderNodeOutputMaterial');bsdf=nodes.new('ShaderNodeBsdfPrincipled');texture=nodes.new('ShaderNodeTexImage');texture.image=baked
links.new(texture.outputs['Color'],bsdf.inputs['Base Color']);links.new(bsdf.outputs[0],out.inputs['Surface']);bsdf.inputs['Roughness'].default_value=.67
body.data.uv_layers.remove(uv);body.data.color_attributes.remove(mask)
for modifier in body.modifiers:modifier.show_viewport=True;modifier.show_render=True
body.name='HeroFace_Continuous'
bpy.data.objects.remove(face,do_unlink=True)
# A relaxed hem, knee compression and ankle folds replace the smooth plastic fit.
for o in bpy.data.objects:
 if o.type!='MESH':continue
 if 't-shirt' in o.name:
  for v in o.data.vertices:
   x,y,z=v.co
   hem=math.exp(-((z-.98)/.085)**2)
   v.co.z-=.035*hem
   v.co.x*=1+.035*hem
   v.co.y+=math.copysign(.006*hem,y)
   fold=.0035*math.sin(z*112+x*26)*hem+.0018*math.sin(x*67+z*36)*math.exp(-((z-1.15)/.2)**2)
   v.co.y+=math.copysign(fold,y)
 elif 'pants' in o.name:
  for v in o.data.vertices:
   x,y,z=v.co
   knee=math.exp(-((z-.50)/.09)**2);ankle=math.exp(-((z-.16)/.07)**2)
   v.co.y+=math.copysign(.0035*math.sin(z*135+x*16)*(knee+ankle),y)
 for polygon in o.data.polygons:polygon.use_smooth=True
# Replace scratchy flyaway fibers with coherent tapered locks attached to the head.
old_hair=bpy.data.objects.get('HeroHair_Fibers')
if old_hair:bpy.data.objects.remove(old_hair,do_unlink=True)
cap=next(o for o in bpy.data.objects if o.type=='MESH' and 'short01' in o.name)
for v in cap.data.vertices:
 x,y,z=v.co
 top=smooth((z-1.64)/.05)
 v.co.z+=top*(.003*math.sin(x*82+y*34)+.002*math.sin(y*93))
cap_bvh=BVHTree.FromPolygons([v.co for v in cap.data.vertices],[tuple(p.vertices) for p in cap.data.polygons])
def material(name,color,rough=.7):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True;b=m.node_tree.nodes.get('Principled BSDF');b.inputs['Base Color'].default_value=(*color,1);b.inputs['Roughness'].default_value=rough;return m
def bind(o,bone):
 o.parent=body.parent;o.matrix_parent_inverse=body.matrix_parent_inverse.copy();o.matrix_basis=body.matrix_basis.copy()
 group=o.vertex_groups.new(name=bone);group.add(list(range(len(o.data.vertices))),1,'REPLACE')
 mod=o.modifiers.new('RigBind','ARMATURE');mod.object=rig
 for p in o.data.polygons:p.use_smooth=True
random.seed(707);curves=[];hair_mats=[material('SweptHair_'+str(i),(.012+i*.002,.009+i*.0015,.007+i*.001),.58) for i in range(3)]
for i in range(190):
 theta=random.uniform(-math.pi,math.pi);phi=random.uniform(.10,1.05)
 start=Vector((.075*math.sin(phi)*math.cos(theta),-.028+.085*math.sin(phi)*math.sin(theta),1.63+.074*math.cos(phi)))
 nearest=cap_bvh.find_nearest(start)
 if nearest[0] is None:continue
 start=nearest[0]
 curve=bpy.data.curves.new('SweptLock','CURVE');curve.dimensions='3D';curve.bevel_depth=random.uniform(.00025,.0005);curve.bevel_resolution=1
 spline=curve.splines.new('POLY');spline.points.add(6)
 for j,p in enumerate(spline.points):
  t=j/6;co=start+Vector((.012*t,-.018*t,-.009*t))
  # Smooth authored arc; no per-point nearest-card snapping (which caused zigzags).
  p.co=(*co,1);p.radius=max(.06,1-t*.94)
 o=bpy.data.objects.new('SweptLock',curve);bpy.context.collection.objects.link(o);o.data.materials.append(hair_mats[i%3]);curves.append(o)
bpy.ops.object.select_all(action='DESELECT')
for o in curves:o.select_set(True)
bpy.context.view_layer.objects.active=curves[0];bpy.ops.object.convert(target='MESH');bpy.ops.object.join();hair=bpy.context.object;hair.name='HeroHair_Swept';bind(hair,'head')
# Closed canvas shoes with sole, toe-cap, tongue and crossed laces, bound to each foot.
canvas=material('SneakerCanvas',(.075,.085,.09));sole=material('SneakerRubber',(.60,.58,.52));lace=material('SneakerLaces',(.8,.78,.7))
def ellipsoid(name,center,scale,mat,bone):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=20,ring_count=10,radius=1)
 o=bpy.context.object;o.name=name
 for v in o.data.vertices:v.co=Vector((v.co.x*scale[0],v.co.y*scale[1],v.co.z*scale[2]))+Vector(center)
 o.data.materials.append(mat);bind(o,bone);return o
for side in [-1,1]:
 x=side*.195;bone='foot_l' if side>0 else 'foot_r'
 ellipsoid('HeroShoe_Sole',(x,-.08,.024),(.062,.148,.022),sole,bone)
 ellipsoid('HeroShoe_Canvas',(x,-.067,.069),(.058,.13,.058),canvas,bone)
 ellipsoid('HeroShoe_Toecap',(x,-.177,.055),(.058,.05,.033),sole,bone)
 for j in range(5):
  for direction in [-1,1]:
   center=Vector((x,-.12+j*.023,.119))
   o=ellipsoid('HeroShoe_Lace',center,(.043,.002,.002),lace,bone)
   for v in o.data.vertices:
    d=v.co-center;a=direction*.38;v.co=center+Vector((d.x*math.cos(a)-d.y*math.sin(a),d.x*math.sin(a)+d.y*math.cos(a),d.z))
 shoe_parts=[o for o in bpy.data.objects if o.type=='MESH' and o.name.startswith('HeroShoe') and bone in o.vertex_groups]
 bpy.ops.object.select_all(action='DESELECT')
 for o in shoe_parts:o.select_set(True)
 bpy.context.view_layer.objects.active=shoe_parts[0];bpy.ops.object.join();bpy.context.object.name='HeroShoe_'+bone
# Keep the underlying bare toes inside the closed shoe during toe-bone animation.
for key in body.data.shape_keys.key_blocks:
 for v in key.data:
  if v.co.z<.10:
   center=Vector((math.copysign(.195,v.co.x),-.08,.05));v.co=center+(v.co-center)*.80
# Export the candidate with native morphs, weights and locomotion intact.
bpy.ops.object.select_all(action='SELECT');bpy.context.view_layer.objects.active=rig
for image in bpy.data.images:
 if image.source=='FILE' and image.filepath and pathlib.Path(bpy.path.abspath(image.filepath)).exists():
  try:image.pack()
  except RuntimeError:pass
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'tools/source/hero_continuous.blend'))
bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets/characters/shyam_hero_v07.glb'),export_format='GLB',use_selection=True,export_animations=True,export_animation_mode='ACTIONS',export_force_sampling=True,export_morph=True,export_yup=True)
print('CONTINUOUS_HERO_EXPORTED',len(body.data.vertices),'skinned vertices;',len(curves),'hair locks',flush=True)
