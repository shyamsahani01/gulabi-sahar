"""Project the approved portrait onto the native skinned mesh and bake its UV albedo."""
import bpy, pathlib, math
ROOT=pathlib.Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'tools/source/hero_source.blend'))
body=bpy.data.objects['Shyam']
# Bake in the mesh's rest space. Animation is restored after baking.
for mod in body.modifiers: mod.show_render=False;mod.show_viewport=False
uv=body.data.uv_layers.new(name='ApprovedPortrait')
mask=body.data.color_attributes.new(name='PortraitMask',type='FLOAT_COLOR',domain='POINT')
def clamp(x):return max(0,min(1,x))
def photo_y(z):
 points=[(1.43,610),(1.477,515),(1.526,437),(1.549,383),(1.587,322),(1.625,259),(1.70,135)]
 for (a,b),(c,d) in zip(points,points[1:]):
  if z<=c:return b+(z-a)/(c-a)*(d-b)
 return 135-(z-1.70)*1400
for v in body.data.vertices:
 x,y,z=v.co
 edge=clamp((.073-abs(x))/.024)
 front=clamp((-y-.075)/.035)
 vertical=clamp((z-1.455)/.035)*clamp((1.675-z)/.04)
 value=edge*front*vertical
 mask.data[v.index].color=(value,value,value,1)
for loop in body.data.loops:
 x,y,z=body.data.vertices[loop.vertex_index].co
 uv.data[loop.index].uv=((1180+x*1900)/1536,1-photo_y(z)/1024)
base_uv=body.data.uv_layers[0];body.data.uv_layers.active=base_uv
mat=bpy.data.materials.new('Approved03C_BakedSkin');mat.use_nodes=True
n=mat.node_tree.nodes;n.clear();links=mat.node_tree.links
out=n.new('ShaderNodeOutputMaterial');emit=n.new('ShaderNodeEmission');links.new(emit.outputs[0],out.inputs['Surface'])
base=n.new('ShaderNodeTexImage');base.image=bpy.data.images.load(str(ROOT/'assets/characters/shyam_young_lightskinned_male_diffuse3.png'))
basecoord=n.new('ShaderNodeUVMap');basecoord.uv_map=base_uv.name;links.new(basecoord.outputs[0],base.inputs[0])
photo=n.new('ShaderNodeTexImage');photo.image=bpy.data.images.load(str(ROOT/'designs/01-character/shyam-concept-03c.png'));photo.extension='EXTEND'
coord=n.new('ShaderNodeUVMap');coord.uv_map=uv.name;links.new(coord.outputs[0],photo.inputs[0])
attr=n.new('ShaderNodeVertexColor');attr.layer_name='PortraitMask'
mix=n.new('ShaderNodeMixRGB');links.new(attr.outputs['Color'],mix.inputs[0]);links.new(base.outputs['Color'],mix.inputs[1]);links.new(photo.outputs['Color'],mix.inputs[2]);links.new(mix.outputs[0],emit.inputs[0])
body.data.materials.clear();body.data.materials.append(mat)
for p in body.data.polygons:p.material_index=0
baked=bpy.data.images.new('shyam_approved_skin',width=2048,height=2048,alpha=False)
bake=n.new('ShaderNodeTexImage');bake.image=baked;n.active=bake
bpy.ops.object.select_all(action='DESELECT');body.select_set(True);bpy.context.view_layer.objects.active=body
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=1;scene.render.bake.margin=12
bpy.ops.object.bake(type='EMIT')
baked.filepath_raw=str(ROOT/'assets/characters/shyam_approved_skin.png');baked.file_format='PNG';baked.save()
# Keep only the baked native UV material for export.
n.clear();out=n.new('ShaderNodeOutputMaterial');bsdf=n.new('ShaderNodeBsdfPrincipled');tex=n.new('ShaderNodeTexImage');tex.image=baked
links.new(tex.outputs['Color'],bsdf.inputs['Base Color']);links.new(bsdf.outputs[0],out.inputs['Surface']);bsdf.inputs['Roughness'].default_value=.85
body.data.uv_layers.remove(uv)
# Slightly fuller jaw/cheeks and a softer mouth, using consistent deltas for all expressions.
for key in body.data.shape_keys.key_blocks:
 for v in key.data:
  x,y,z=v.co
  if 1.47<z<1.62 and y<-.055:
   weight=math.sin((z-1.47)/.15*math.pi)
   v.co.x += x*.075*weight
for o in list(bpy.data.objects):
 if 'eyebrow' in o.name:bpy.data.objects.remove(o,do_unlink=True)
 elif 'short01' in o.name and o.type=='MESH':
  for v in o.data.vertices:
   x,y,z=v.co
   if z>1.64:
    weight=min(1,(z-1.64)/.06)
    v.co.z += weight*(.002*math.sin(x*120+y*90)+.001*math.sin(y*160))
    v.co.x += weight*.002*math.sin(y*110)
for mod in body.modifiers:mod.show_render=True;mod.show_viewport=True
bpy.ops.object.select_all(action='SELECT')
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'tools/source/hero_approved.blend'))
bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets/characters/shyam_hero.glb'),export_format='GLB',use_selection=True,export_animations=True,export_animation_mode='ACTIONS',export_force_sampling=True,export_morph=True,export_yup=True)
print('APPROVED_FACE_BAKED',flush=True)
