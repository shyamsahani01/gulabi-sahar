"""Original, editable exterior study from observed Cinestar architecture.

blender --background --factory-startup --python tools/build_cinestar_study.py
Blender coordinates: X width, Y depth, Z up; front is -Y.
Dimensions are design estimates, not a measured survey. No photo pixels used.
"""
import bpy
import json
import math
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'designs/21-cinestar-model-study'
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)

def material(name, rgb, rough=.8, metal=0):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*rgb, 1)
    m.use_nodes = True
    p = m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value = (*rgb, 1)
    p.inputs['Roughness'].default_value = rough
    p.inputs['Metallic'].default_value = metal
    return m

stone = material('Stone_sandstone_tiles', (.53, .32, .21))
trim = material('Stone_cut_edges', (.65, .48, .32))
panel = material('Panel_weathered_cladding', (.69, .70, .63))
concrete = material('Concrete_walkways', (.34, .31, .25))
cream = material('Plaster_columns', (.72, .65, .48))
dark = material('Recess_shadow', (.055, .065, .059))
metal = material('Metal_dark_bronze', (.16, .13, .085), .45, .55)
glass = material('Glass_smoky', (.095, .16, .17), .17, .38)
white = material('Sign_ivory', (.88, .84, .70))
red = material('Sign_burgundy', (.34, .035, .025))
blue = material('Sign_blue', (.025, .10, .25))
ochre = material('Sign_ochre', (.49, .29, .06))
shutter = material('Shutter_painted', (.27, .19, .13), .68)

def finish(o, name, mat, bevel=0):
    o.name = name
    if mat:
        o.data.materials.append(mat)
    # Tiny trim has no visible benefit from several rings of bevel geometry.
    if bevel and min(o.dimensions) >= .14:
        mod = o.modifiers.new('Small real edge bevel', 'BEVEL')
        mod.width = bevel
        mod.segments = 1
        mod = o.modifiers.new('Weighted corner normals', 'WEIGHTED_NORMAL')
        mod.keep_sharp = True
    return o

def box(name, at, size, mat, bevel=.025):
    bpy.ops.mesh.primitive_cube_add(size=1, location=at)
    o = bpy.context.object
    o.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return finish(o, name, mat, bevel)

def cylinder(name, at, radius, length, mat, axis='Z', vertices=32):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=length, location=at)
    o = bpy.context.object
    if axis == 'Y':
        o.rotation_euler.x = math.pi/2
    elif axis == 'X':
        o.rotation_euler.y = math.pi/2
    for p in o.data.polygons:
        p.use_smooth = len(p.vertices) == 4
    return finish(o, name, mat, .015 if mat else 0)

def rod(name, start, end, radius, mat):
    a, b = Vector(start), Vector(end)
    o = cylinder(name, (a+b)/2, radius, (b-a).length, mat, vertices=10)
    o.rotation_euler = (b-a).to_track_quat('Z', 'Y').to_euler()
    return o

def subtract(target, tool):
    bpy.context.view_layer.objects.active = target
    mod = target.modifiers.new('Actual through opening', 'BOOLEAN')
    mod.operation = 'DIFFERENCE'
    mod.object = tool
    bpy.ops.object.modifier_apply(modifier=mod.name)
    bpy.data.objects.remove(tool, do_unlink=True)

def text(name, value, at, size, mat, rotation=(math.pi/2, 0, 0)):
    curve = bpy.data.curves.new(name, 'FONT')
    curve.body = value
    curve.align_x = 'CENTER'
    curve.align_y = 'CENTER'
    curve.size = size
    curve.resolution_u = 4
    curve.extrude = .009
    curve.bevel_depth = .002
    obj = bpy.data.objects.new(name, curve)
    bpy.context.collection.objects.link(obj)
    obj.location, obj.rotation_euler = at, rotation
    obj.data.materials.append(mat)
    return obj

def ring(name, x, y, z, r, thickness=.09):
    bpy.ops.mesh.primitive_torus_add(major_radius=r, minor_radius=thickness,
        major_segments=64, minor_segments=8, location=(x,y,z), rotation=(math.pi/2,0,0))
    o=finish(bpy.context.object,name,trim)
    for p in o.data.polygons:p.use_smooth=True

def front_rails(x, z, width, y=-14.18):
    for level in [0, .26, .52, .78]:
        rod('Horizontal balcony rail', (x-width/2,y,z+level), (x+width/2,y,z+level), .028, metal)
    for dx in [-width/2, 0, width/2]:
        rod('Railing upright',(x+dx,y,z-.1),(x+dx,y,z+.83),.035,metal)

# Main mass: rear enclosure leaves real exterior galleries in front and at the right.
box('Raised plinth', (0,0,.5), (36,28,1), stone)
box('Rear wall - unobserved simplified enclosure', (0,13.7,10.5), (36,.5,19), stone)
box('Left return - approximate', (-17.75,0,10.5), (.5,28,19), stone)
box('Main enclosed core', (-1.5,1.4,11.6), (31.8,21.8,16.6), stone)
box('Front recessed upper corridor wall', (-2,-11.65,16.7), (32,.25,6.3), dark)
box('Roof slab', (0,0,20.1), (36.4,28.4,.32), trim)
for z in [5.4,9.55,13.7,17.85]:
    box('Side gallery floor slab', (16.3,0,z), (3.4,28.2,.24), stone)
    box('Side gallery soffit edge',(18.05,0,z+.02),(.16,28.25,.35),trim)

# Perforated facade, not dark disks pasted onto a solid box.
upper = box('Upper facade with true circular openings', (-2,-13.75,16.8), (32,.5,6.4), stone, 0)
circle_centres = [-14, -7.2, 3.0, 9.8]
for x in circle_centres:
    subtract(upper,cylinder('Opening cutter',(x,-13.75,16.7),2.12,1.5,None,'Y',64))
    ring('Carved circular stone surround',x,-14.04,16.7,2.17,.085)
    box('Visible slab through circle',(x,-12.9,15.65),(4.0,2.1,.32),cream)
    front_rails(x,16.05,3.85,-13.48)
    box('Circle upper lintel behind facade',(x,-12.65,18.1),(3.7,1.5,.18),concrete)
subtract(upper,cylinder('Centre small round opening',(-2.1,-13.75,14.65),.87,1.5,None,'Y',48))
ring('Centre small round trim',-2.1,-14.04,14.65,.91,.06)
front_rails(-2.1,14.22,1.45,-13.5)
subtract(upper,cylinder('Centre keyhole crown',(-2.1,-13.75,18),.95,1.5,None,'Y',48))
subtract(upper,box('Centre keyhole stem',(-2.1,-13.75,17.25),(1.25,1.5,1.5),None,0))
box('Centre keyhole deep sill',(-2.1,-13.2,16.55),(1.4,1.3,.15),trim)
bevel=upper.modifiers.new('Stone edge rounding','BEVEL');bevel.width=.035;bevel.segments=2

# Two large weathered gridded cladding fields. Geometry gives joints real relief.
for lo,hi in [(-17.6,-3.65),(-.6,12.4)]:
    cols,rows=11,7
    bw,bh=(hi-lo)/cols,7.9/rows
    for row in range(rows):
        for col in range(cols):
            box('Individual pale cladding panel',(lo+(col+.5)*bw,-14.015,5.55+(row+.5)*bh),
                (bw-.035,.19,bh-.027),panel,.008)
for x in [-3.35,-.25]:
    cylinder('Tall entry column',(x,-14.65,9.3),.25,7.5,cream)
    cylinder('Entry column base',(x,-14.65,5.64),.40,.28,trim)
    bpy.ops.mesh.primitive_cone_add(vertices=40,radius1=.28,radius2=.63,depth=.45,location=(x,-14.65,13.15))
    finish(bpy.context.object,'Flared column capital',cream,.02)
box('Central display recess',(-1.8,-13.7,9.1),(2.8,.25,6.6),dark)
box('Original cinema display',(-1.8,-13.88,8.9),(2.55,.05,5.5),ochre)
text('Original display title','GULABI\nSAHAR',(-1.8,-13.93,9.45),.42,white)
text('Original display subtitle','PICTURE HOUSE',(-1.8,-13.94,7.6),.17,white)

# Recessed ground-floor bays: shaded shopfronts, depth, mullions, entry platforms.
for i,(lo,hi,label,bg) in enumerate([(-17.5,-9.4,'PIZZA HUT',dark),(-9.1,-3.7,'SHOPS',ochre),
                                   (-.5,5.4,'SHOPS',dark),(5.7,12.4,'HDFC BANK',blue)]):
    cx=(lo+hi)/2; width=hi-lo
    box('Shop interior backing',(cx,-11.75,2.9),(width,.12,3.7),dark)
    box('Shop glazing',(cx,-12.55,2.95),(width-.2,.055,3.6),glass)
    for j in range(5):
        box('Shop mullion',(lo+j*width/4,-12.64,2.95),(.065,.12,3.7),metal,.01)
    for z in [1.2,3.25,4.75]:box('Shop glazing crossbar',(cx,-12.64,z),(width,.1,.065),metal,.01)
    box('Shop fascia',(cx,-13.94,5.1),(width,.25,.65),bg)
    text('Shop sign - observed or generic',label,(cx,-14.08,5.1),.35,white)
    box('Shop threshold',(cx,-13.4,1.04),(width,1.9,.13),concrete)
    for k in range(5):
        box('Broad entrance tread',(cx,-14.3-(4-k)*.35,.105*(k+1)),(width-.18,.37,.21*(k+1)),trim,.02)
    for sx in [lo+.35,hi-.35]:
        rod('Stair handrail',(sx,-15.8,1),(sx,-14.2,1.9),.026,metal)
        for sy,sz in [(-15.8,.28),(-14.2,1.02)]:
            rod('Stair handrail post',(sx,sy,sz),(sx,sy,sz+.85),.025,metal)
box('Cinema entrance ceiling',(-1.8,-12.8,4.8),(3.1,2.7,.2),cream)
box('Entrance dark depth',(-1.8,-10.6,2.9),(3,.12,3.8),dark)
for x in [-3.3,-.3]:box('Entrance jamb',(x,-12.7,2.9),(.18,2.8,3.8),trim)
text('Entrance label','CINEMA',(-1.8,-14.08,5.1),.31,white)
for k in range(5):box('Cinema entry steps',(-1.8,-14.3-(4-k)*.35,.105*(k+1)),(3,.37,.21*(k+1)),trim)

# Right-hand stacked arched landings and stepped silhouette.
for level in range(3):
    z=1+level*4.15
    wall=box('Stair landing with open arch',(15.25,-13.75,z+1.95),(5.5,.5,3.9),stone,0)
    subtract(wall,box('Arch rectangular opening',(15.25,-13.75,z+1.0),(3.25,1.5,2.0),None,0))
    subtract(wall,cylinder('Arch round crown',(15.25,-13.75,z+2.0),1.625,1.5,None,'Y',48))
    front_rails(15.25,z+.2,3.2,-13.2)
    box('Landing floor',(15.25,-12.7,z+.05),(5.5,2.5,.2),concrete)
    # Stair flights are visible inside the openings, not an asserted interior survey.
    for k in range(8):
        box('Approximate visible stair flight',(14.2,-11.6+k*.26,z+.18+k*.20),(1.4,.28,.18),concrete,.008)
for j in range(3):
    box('Stepped corner parapet',(17.8,-13.6+j*1.55,13.0+j*1.65),(.35,1.7,1.3),stone)

# Long side arcade: repeated floors, recessed windows, rails, round street columns.
for i in range(8):
    y=-11.3+i*3.25
    cylinder('Ground arcade round column',(17.5,y,3.15),.26,4.3,cream)
    for z in [7.55,11.7,15.85,19.0]:
        box('Upper side gallery pier',(17.75,y,z),(.28,.3,3.5 if z<18 else 1.7),cream)
    for z in [6,10.15,14.3,18.45]:
        box('Recessed side window',(14.94,y,z+1.1),(.06,2.5,1.9),glass)
        box('Side window vertical frame',(15.0,y,z+1.1),(.09,.05,1.9),metal,.01)
        box('Gallery parapet base',(17.9,y,z-.25),(.18,3.0,.22),stone)
        box('Gallery handrail',(17.9,y,z+.65),(.23,3.05,.16),trim)
        for k in range(9):
            box('Balustrade spindle',(17.9,y-1.35+k*.3375,z+.18),(.10,.095,.77),trim,0)
    box('Side shop shutter',(15.06,y,2.8),(.10,2.8,3.2),shutter)
    for k in range(20):box('Shutter slat',(15.13,y,1.25+k*.15),(.04,2.8,.025),metal,.002)
    box('Side shop board',(17.95,y,5.02),(.17,3.1,.65),blue if i%3==0 else ochre)
    # Side sign text faces +X. Generic tenancy avoids mixing 2024 boards with 2026.
    text('Side generic sign','SHOPS' if i%2 else 'MARKET',(18.05,y,5.02),.29,white,(math.pi/2,0,math.pi/2))
    if i%2==0:
        box('AC outdoor cabinet',(17.9,y,11.7),(.56,.9,.62),cream)
        cylinder('AC fan grille',(18.22,y,11.7),.23,.04,metal,'X',24)
for y in [-12.3,11.8]:
    rod('Side rainwater pipe',(18.25,y,1.2),(18.25,y,19.8),.045,metal)

# Rooftop nameboard, service pipes and two original poster panels.
box('Rooftop signboard',(6,-12.9,21.12),(12.2,.22,1.65),white)
text('Rooftop cinema name','CINESTAR',(6,-13.04,21.22),.93,red)
for x in [.5,11.4]:rod('Sign support',(x,-12.8,20.25),(x,-12.8,21.9),.045,metal)
for z,title,mat in [(17.9,'GULABI SAHAR',dark),(15.65,'JAIPUR NIGHTS',red)]:
    box('Original poster frame',(15.25,-14.2,z),(5.5,.20,2.05),metal)
    box('Original poster artwork',(15.25,-14.32,z),(5.28,.035,1.83),mat)
    text('Original poster title',title,(15.25,-14.35,z+.2),.35,white)
    text('Original poster small type','NOW SHOWING',(15.25,-14.35,z-.45),.19,white)

# Save editable source before joining objects for a small number of draw surfaces.
(OUT/'source').mkdir(exist_ok=True)
(OUT/'source/.gdignore').touch()
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source/cinestar-study.blend'))
objects=[o for o in bpy.context.scene.objects if o.type in {'MESH','FONT'}]
for o in objects:
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True);bpy.context.view_layer.objects.active=o
    bpy.ops.object.convert(target='MESH')
bpy.ops.object.select_all(action='SELECT')
bpy.context.view_layer.objects.active=next(o for o in bpy.context.scene.objects if o.type=='MESH')
bpy.ops.object.join()
model=bpy.context.object;model.name='Cinestar_Exterior_Study'
bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
model.data.calc_loop_triangles()
stats={'vertices':len(model.data.vertices),'triangles':len(model.data.loop_triangles),
       'material_slots':len(model.data.materials),'dimensions_metres':list(model.dimensions),
       'status':'Exterior review candidate; approximate scale; not integrated into city or tablet tested',
       'unobserved':'Roof service layout, rear and internal stair flights are simplified estimates'}
(OUT/'model-stats.json').write_text(json.dumps(stats,indent=2)+'\n')
bpy.ops.export_scene.gltf(filepath=str(OUT/'cinestar-study.glb'),export_format='GLB',use_selection=True,
    export_animations=False,export_yup=True)
lod=model.modifiers.new('Distant exterior simplification','DECIMATE')
lod.ratio=.32
bpy.ops.object.modifier_apply(modifier=lod.name)
model.data.calc_loop_triangles()
stats['lod1_triangles']=len(model.data.loop_triangles)
bpy.ops.export_scene.gltf(filepath=str(OUT/'cinestar-study-lod1.glb'),export_format='GLB',use_selection=True,
    export_animations=False,export_yup=True)
(OUT/'model-stats.json').write_text(json.dumps(stats,indent=2)+'\n')
print('CINESTAR_STUDY',json.dumps(stats),flush=True)
