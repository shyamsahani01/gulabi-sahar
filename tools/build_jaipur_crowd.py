"""Export distinct stylized residents on the existing licensed crowd rig.
Run: blender --background --factory-startup --python tools/build_jaipur_crowd.py
Original face/body edits, garments and accessories; no downloaded likenesses.
"""
import bpy, math, json, sys
from pathlib import Path
from mathutils import Vector, kdtree
sys.path.insert(0,str(Path(__file__).resolve().parent))
from share_crowd_textures import share
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/characters/crowd';OUT.mkdir(exist_ok=True)
# Casual and traditional everyday clothes, varied age, build and skin tone.
SPECS=[
 ('man_shirt_01','shirt',False,'8c593d','537f98',1.03,1.04,0),
 ('woman_kurti_01','kurti',True,'b47a55','168d83',.91,.96,1),
 ('man_kurta_01','kurta',False,'6c422e','e4d9b6',1.10,1.01,2),
 ('woman_dress_01','sari',True,'9f6847','b74164',1.03,.97,3),
 ('man_shirt_02','shirt',False,'bd8b65','b97d40',.89,1.07,4),
 ('woman_kurti_02','kurti',True,'754a34','565f9c',1.04,1.02,5),
 ('old_man_01','kurta',False,'a97a56','d4d4c3',.96,.98,6),
 ('old_woman_01','sari',True,'87583d','846e96',1.08,.96,7),
 ('boy_01','shirt',False,'af7953','ce9d38',.88,1.0,8),
 ('girl_01','kurti',True,'9a6545','bf577b',.90,1.0,9),
 ('boy_02','shirt',False,'704832','48917d',.94,1.0,10),
]
def color(h):
 return tuple(((int(h[i:i+2],16)/255+.055)/1.055)**2.4 for i in (0,2,4))+(1,)
def material(name,h):
 m=bpy.data.materials.new(name);m.diffuse_color=color(h);m.use_nodes=True
 n=m.node_tree.nodes.get('Principled BSDF');n.inputs['Base Color'].default_value=color(h);n.inputs['Roughness'].default_value=.88
 return m
for name,style,female,skin,cloth,width,height,index in SPECS:
 bpy.ops.wm.read_factory_settings(use_empty=True)
 bpy.ops.import_scene.gltf(filepath=str(ROOT/'assets/characters/crowd_walk.glb'))
 rig=next(o for o in bpy.data.objects if o.type=='ARMATURE')
 meshes=[o for o in bpy.data.objects if o.type=='MESH' and o.find_armature()==rig]
 body=next(o for o in meshes if o.name=='Shyam')
 # Rest-space changes preserve vertex groups and the established animation rest rig.
 for o in meshes:
  for v in o.data.vertices:
   z=v.co.z
   # Narrower shoulders / fuller hip silhouettes for some residents, independent body builds.
   hip=math.exp(-((z-.88)/.17)**2)
   shoulder=math.exp(-((z-1.30)/.15)**2)
   v.co.x *= width*(1+(0.07*hip-.09*shoulder if female else .02*shoulder))
   if z>1.45:
    t=max(0,min(1,(z-1.45)/.24));v.co.x*=.93+(index%4)*.045
    v.co.y += .012*math.sin(index*1.7)*math.sin(t*math.pi)
    v.co.z += .015*math.cos(index*1.3)*t
    jaw=math.exp(-((z-1.49)/.05)**2)
    cheek=math.exp(-((z-1.57)/.055)**2)
    v.co.x*=1+(-.13 if female else -.03+(index%3)*.035)*jaw+.04*math.sin(index)*cheek
    if v.co.y<-.07 and abs(v.co.x)<.03:
     v.co.y-=.009*math.cos(index)*math.exp(-((z-1.57)/.045)**2)
  for slot in o.material_slots:
   if not slot.material:continue
   m=slot.material.copy();slot.material=m
   n=m.node_tree.nodes.get('Principled BSDF') if m.use_nodes else None
   if not n:continue
   if o==body:
    # Retain facial texture detail, tint through the existing texture node using a multiply.
    links=list(n.inputs['Base Color'].links)
    if links:
     src=links[0].from_socket;m.node_tree.links.remove(links[0]);mix=m.node_tree.nodes.new('ShaderNodeMixRGB');mix.blend_type='MULTIPLY';mix.inputs[0].default_value=1;mix.inputs[2].default_value=(.73+(index%3)*.09,.55+(index%4)*.06,.42+(index%3)*.07,1);m.node_tree.links.new(src,mix.inputs[1]);m.node_tree.links.new(mix.outputs[0],n.inputs['Base Color'])
     # glTF cannot preserve arbitrary shader nodes: bake tint into base factor below.
     m.node_tree.links.remove(n.inputs['Base Color'].links[0]);m.node_tree.links.new(src,n.inputs['Base Color']);n.inputs['Base Color'].default_value=color(skin)
   if 't-shirt' in o.name or 'pants' in o.name:
    for link in list(n.inputs['Base Color'].links):m.node_tree.links.remove(link)
    n.inputs['Base Color'].default_value=color(cloth if 't-shirt' in o.name else ('d1bfa2' if style=='kurta' else '30394b'))
   n.inputs['Roughness'].default_value=.9
 # Custom garments transfer body skin weights to follow the same walking rig.
 kd=kdtree.KDTree(len(body.data.vertices))
 for v in body.data.vertices:kd.insert(body.matrix_world@v.co,v.index)
 kd.balance()
 def skinned_mesh(label,verts,faces,mat,bone=None):
  mesh=bpy.data.meshes.new(label);mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new(label,mesh);bpy.context.collection.objects.link(o);o.data.materials.append(mat);o.parent=rig
  for vg in body.vertex_groups:o.vertex_groups.new(name=vg.name)
  for v in mesh.vertices:
   if bone:
    g=o.vertex_groups.get(bone) or o.vertex_groups.new(name=bone);g.add([v.index],1,'REPLACE')
   else:
    _,idx,_=kd.find(v.co)
    for g in body.data.vertices[idx].groups:o.vertex_groups[g.group].add([v.index],g.weight,'REPLACE')
  mod=o.modifiers.new('Resident rig','ARMATURE');mod.object=rig
  for p in mesh.polygons:p.use_smooth=True
  return o
 fabric=material(name+'_cotton',cloth);trim=material(name+'_trim','d9b96e')
 if style!='shirt':
  # Open elliptical hem, with a narrow torso; full length sari or knee length kurta/kurti.
  hem=.18 if style=='sari' else .64
  rings=[(hem,.34 if style=='sari' else .31,.235),(.89,.285,.225),(1.02,.24,.205),(1.20,.245,.205)]
  verts=[];faces=[];n=32
  for z,rx,ry in rings:
   for k in range(n):
    a=math.tau*k/n;fold=1+.025*math.cos(a*12);verts.append((math.cos(a)*rx*width*fold,math.sin(a)*ry*fold-.035,z))
  for row in range(len(rings)-1):
   for k in range(n):faces.append((row*n+k,row*n+(k+1)%n,(row+1)*n+(k+1)%n,(row+1)*n+k))
  garment=skinned_mesh(name+'_garment',verts,faces,fabric)
  solid=garment.modifiers.new('Cotton thickness','SOLIDIFY');solid.thickness=.004
  if female:
   # Shoulder drape/dupatta, modeled cloth strip rather than painted-on clothing.
   verts=[(-.20,-.18,1.37),(-.08,-.20,1.38),(.16,-.27,.92),(.04,-.28,.88),(-.20,.10,1.37),(-.08,.12,1.38),(-.10,.25,.70),(-.22,.25,.72)]
   skinned_mesh(name+'_drape',verts,[(0,1,2,3),(4,7,6,5),(0,4,5,1)],trim)
 # Hair buns and glasses visibly change silhouettes, not only shirt colors.
 if female:
  bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=8,location=(0,.10,1.62),scale=(.085,.065,.085));o=bpy.context.object
  bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
  skinned_mesh(name+'_hair_bun',[tuple(v.co) for v in o.data.vertices],[tuple(p.vertices) for p in o.data.polygons],material(name+'_hair','77716a' if index==7 else '201b19'),'head');bpy.data.objects.remove(o,do_unlink=True)
 if index in [4,6,7]:
  mat=material(name+'_spectacles','302b26')
  for x in [-.038,.038]:
   bpy.ops.mesh.primitive_torus_add(major_segments=16,minor_segments=6,location=(x,-.111,1.56),rotation=(math.pi/2,0,0),major_radius=.029,minor_radius=.0025)
   o=bpy.context.object;bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
   skinned_mesh(name+'_glasses',[tuple(v.co) for v in o.data.vertices],[tuple(p.vertices) for p in o.data.polygons],mat,'head');bpy.data.objects.remove(o,do_unlink=True)
 # Simple original shoes on the existing foot bones, shared by everyday outfits.
 shoe_mat=material(name+'_footwear','34302d' if style=='shirt' else '654731')
 for side,x in [('l',.1885),('r',-.1885)]:
  bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=8,location=(x*width,-.075,.045),scale=(.073,.15,.056))
  o=bpy.context.object;bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
  skinned_mesh(name+'_shoe_'+side,[tuple(v.co) for v in o.data.vertices],[tuple(p.vertices) for p in o.data.polygons],shoe_mat,'foot_'+side);bpy.data.objects.remove(o,do_unlink=True)
 # Export a real variant with the original Walk animation and exactly the existing rig.
 rig.scale*=height
 bpy.ops.object.select_all(action='SELECT')
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',export_animations=True,export_animation_mode='ACTIONS',export_force_sampling=True,export_yup=True)
 share(OUT/(name+'.glb'))
 print('RESIDENT',name,flush=True)
(OUT/'variants.json').write_text(json.dumps([dict(name=s[0],clothes=s[1],build=s[5],height=s[6],source='Original edits to existing licensed crowd mesh and rig') for s in SPECS],indent=2)+'\n')
