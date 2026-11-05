"""Build the approved hero variation and native facial morphs from the user's rig.
Requires Blender and the local MPFB expression-unit targets; no source files are changed.
"""
import bpy, gzip, pathlib
from mathutils import Vector, kdtree
ROOT=pathlib.Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath='/home/shyam/MyWork/apps/jaipur-story-game/shyam_character.blend')
source=bpy.data.objects['Shyam']
for mod in source.modifiers: mod.show_viewport=False
bpy.context.view_layer.update()
evaluated=source.evaluated_get(bpy.context.evaluated_depsgraph_get())
coords=[v.co.copy() for v in evaluated.data.vertices]
# Evaluated shape-key geometry is available through to_mesh.
mesh=evaluated.to_mesh(); coords=[v.co.copy() for v in mesh.vertices]; evaluated.to_mesh_clear()
kd=kdtree.KDTree(len(coords))
for i,p in enumerate(coords): kd.insert(p,i)
kd.balance()
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath='/home/shyam/Downloads/Walking.fbx')
rig=next(o for o in bpy.data.objects if o.type=='ARMATURE' and o.animation_data and o.animation_data.action)
rig.animation_data.action.name='Walk'
keep=[rig]+[o for o in rig.children if o.type=='MESH']
for o in list(bpy.data.objects):
 if o not in keep:bpy.data.objects.remove(o,do_unlink=True)
body=bpy.data.objects['Shyam']
mapping=[]; distances=[]
for v in body.data.vertices:
 p,i,d=kd.find(v.co);mapping.append(i);distances.append(d)
print('MAPPING',len(mapping),'mean',sum(distances)/len(distances),'max',max(distances),flush=True)
# The clean body retains the first 13,380 source indices exactly; helpers overlap
# body positions, so nearest-point transfer alone can select a helper vertex.
mapping=list(range(len(body.data.vertices)))
targets=pathlib.Path('/home/shyam/.config/blender/5.2/extensions/user_default/mpfb/data/targets/expression/units/asian')
def target(name):
 result={}
 with gzip.open(targets/(name+'.target.gz'),'rt') as f:
  for line in f:
   if not line.strip() or line.startswith('#'):continue
   i,x,y,z=line.split();result[int(i)]=Vector((float(x),-float(z),float(y)))*0.1
 return result
body.shape_key_add(name='Basis')
for name,units in {'BlinkLeft':{'eye-left-closure':1},'BlinkRight':{'eye-right-closure':1},'Smile':{'mouth-corner-puller':0.4,'mouth-upward-retraction':0.15},'Serious':{'eyebrows-left-down':0.55,'eyebrows-right-down':0.55},'Surprised':{'eyebrows-left-up':0.7,'eyebrows-right-up':0.7,'eye-left-opened-up':0.15,'eye-right-opened-up':0.15}}.items():
 offsets={}
 for unit,weight in units.items():
  for i,offset in target(unit).items():offsets[i]=offsets.get(i,Vector())+offset*weight
 key=body.shape_key_add(name=name)
 for v,base,i in zip(key.data,body.data.shape_keys.key_blocks['Basis'].data,mapping):v.co=base.co+offsets.get(i,Vector())
# Keep a straight, proportionate head. The existing head is about 1/7.7 of body height.
# Use the approved warm off-white / charcoal wardrobe, preserving fabric geometry.
for o in keep:
 if o.type!='MESH':continue
 for slot in o.material_slots:
  mat=slot.material
  if mat and mat.use_nodes:
   bsdf=next((n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED'),None)
   if bsdf:
    if 't-shirt' in o.name:bsdf.inputs['Base Color'].default_value=(0.88,0.85,0.77,1)
    elif 'pants' in o.name:bsdf.inputs['Base Color'].default_value=(0.065,0.075,0.085,1)
bpy.context.scene.frame_start=int(rig.animation_data.action.frame_range[0]);bpy.context.scene.frame_end=int(rig.animation_data.action.frame_range[1])
bpy.context.scene.frame_set(bpy.context.scene.frame_start)
bpy.ops.object.select_all(action='SELECT');bpy.context.view_layer.objects.active=rig
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'tools/source/hero_source.blend'))
bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets/characters/shyam_hero.glb'),export_format='GLB',use_selection=True,export_animations=True,export_animation_mode='ACTIONS',export_force_sampling=True,export_morph=True,export_yup=True)
print('HERO_EXPORTED',flush=True)
