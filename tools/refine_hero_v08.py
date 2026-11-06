"""Give the continuous hero head real facial structure, a full smile and matching neck skin.
Run with the portable Blender 4.2: ~/MyWork/Tools/Blender/blender-4.2.3-linux-x64/blender --background --python tools/refine_hero_v08.py
Input is the playable v07 GLB (the Blender 5.2 sources cannot be opened by 4.2); the rig, the
Walk clip, skin weights and the existing Blink/Serious/Surprised keys are preserved.

What it does (all measured in the mesh's own space: x right, -y forward, z up):
1. Anatomical sculpt of the head: the v07 fit had pushed the photo onto an almost flat surface
   (nose tip only 1 cm ahead of the lips, nasion level with the forehead, filled eye sockets).
   Brow ridge, nasion recess, nasal dorsum/tip/alae, orbital recess with eyeball convexity,
   zygomatic arch, cheek hollow, lip rolls, mentolabial sulcus, chin, gonial angle and a
   tightened submental plane are added as smooth displacement fields.  Every shape key receives
   the same displacement so the morphs keep working.
2. Smile is rebuilt as a zygomatic smile: corners pull up/out/back, cheeks lift, nasolabial fold,
   lower lids rise (Duchenne squint).  BrowRaise and BrowFurrow keys are added for the eyebrows.
3. Skin texture: the photo region is de-lit (low-frequency shading normalised, the geometry now
   supplies it) and every non-photo texel is colour-matched to the photo skin tone through a
   vertex-baked correction, which removes the lighter neck/temple bands.
"""
import bpy, math, pathlib, subprocess, sys, numpy as np
from mathutils import Vector
from mathutils.kdtree import KDTree
ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRATCH = ROOT / 'builds' / 'hero-v08-work'
SCRATCH.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=str(ROOT / 'assets/characters/shyam_hero_v07.glb'))
body = next(o for o in bpy.data.objects if o.name.startswith('HeroFace_Continuous'))
rig = body.parent
stray = bpy.data.objects.get('Icosphere')
if stray is not None and stray.parent is None and len(stray.data.vertices) <= 64:
    # A leftover 42-vertex primitive at the origin exported with v07; it carries no material.
    print('REMOVING stray', stray.name, [tuple(round(c, 3) for c in v.co) for v in stray.data.vertices[:2]])
    bpy.data.objects.remove(stray, do_unlink=True)
mesh = body.data
keys = mesh.shape_keys.key_blocks
basis = keys['Basis']
n = len(mesh.vertices)
V = np.array([v.co[:] for v in basis.data])
V07 = V.copy()
for i, v in enumerate(mesh.vertices):
    v.co = basis.data[i].co
mesh.update()
N = np.array([v.normal[:] for v in mesh.vertices])
HEAD_CENTER = np.array([0.0, -0.045, 1.56])
outward = np.einsum('ij,ij->i', N, V - HEAD_CENTER) > 0
front = N[:, 1] < -0.05


def bump(t):
    """Smooth compact bump: 1 at t=0, 0 beyond |t|>=1."""
    t = np.clip(np.abs(t), 0, 1)
    return (1 - t * t) ** 2


def plateau(t, flat, fall):
    """1 while |t|<flat, smooth to 0 at |t|=flat+fall."""
    a = np.clip((np.abs(t) - flat) / fall, 0, 1)
    return 1 - a * a * (3 - 2 * a)


def along(dirs, amount):
    return dirs * amount[:, None]


X, Y, Z = V[:, 0], V[:, 1], V[:, 2]
AX = np.abs(X)
SX = np.sign(X)
FWD = np.tile(np.array([0.0, -1.0, 0.0]), (n, 1))
UP = np.tile(np.array([0.0, 0.0, 1.0]), (n, 1))
OUT = np.stack([SX, np.zeros(n), np.zeros(n)], axis=1)
head = (Z > 1.455) & (Y < 0.03) & outward
face = head & front
# Depth features also move the interior lid and mouth-cavity shells (they are not outward
# facing) so the recessed sockets never expose the geometry behind the lids.
face_any = (Z > 1.455) & (Y < -0.06)

# ---------------------------------------------------------------- 1. structure sculpt
D = np.zeros((n, 3))
def add(mask, dirs, field):
    D[mask] += along(dirs, field)[mask]

# Brow ridge (superciliary arch) and glabella.
brow = bump((Z - 1.604) / 0.009) * plateau(AX, 0.046, 0.018)
add(face_any, FWD, 0.0034 * brow)
# Nasion sits back from the glabella.
add(face_any, FWD, -0.0048 * bump((Z - 1.590) / 0.011) * bump(X / 0.015))
# Nasal dorsum, a rounded tip, alar wings and the base under the tip.
dorsum = bump((Z - 1.571) / 0.013) * bump(X / 0.009)
tip = bump((Z - 1.549) / 0.017) * bump(X / 0.0135)
alae = bump((AX - 0.017) / 0.011) * bump((Z - 1.545) / 0.011)
add(face_any, FWD, 0.0055 * dorsum + 0.0098 * tip + 0.0055 * alae)
add(face_any, OUT, 0.0025 * alae)
add(face_any, FWD, -0.0022 * bump((Z - 1.5355) / 0.006) * bump(X / 0.012))
# Orbits: recess the socket, keep the eyeball convex under the lids; the inner shell behind
# the lids drops a little further back so the two surfaces never coincide.
for sx in (-1, 1):
    ex = sx * 0.034
    socket = bump((X - ex) / 0.0205) * bump((Z - 1.588) / 0.0115)
    ball = bump((X - ex) / 0.0115) * bump((Z - 1.588) / 0.0075)
    add(face_any, FWD, -0.0046 * socket + 0.0028 * ball)
    add(face_any & ~outward, FWD, -0.0030 * bump((X - ex) / 0.024) * bump((Z - 1.588) / 0.014))
    # Zygomatic arch: out and forward where the cheekbone lies.
    zyg = bump((X - sx * 0.058) / 0.017) * bump((Z - 1.568) / 0.015) * plateau(Y + 0.07, 0.03, 0.03)
    add(head, N, 0.0042 * zyg)
    # Hollow below it.
    hollow = bump((X - sx * 0.052) / 0.015) * bump((Z - 1.540) / 0.013) * plateau(Y + 0.09, 0.035, 0.03)
    add(head, N, -0.0026 * hollow)
    # Gonial angle: a readable corner of the jaw.
    gon = bump((X - sx * 0.062) / 0.013) * bump((Z - 1.498) / 0.015) * plateau(Y + 0.035, 0.03, 0.03)
    add(head, N, 0.0032 * gon)
    # Temple hollow under the hairline.
    temple = bump((X - sx * 0.078) / 0.013) * bump((Z - 1.612) / 0.016) * plateau(Y + 0.055, 0.03, 0.025)
    add(head, N, -0.0020 * temple)
    # Mouth corners tuck in slightly.
    add(face, FWD, -0.0015 * bump((X - sx * 0.027) / 0.0065) * bump((Z - 1.523) / 0.0065))
# Lips, sulcus and chin along the centre line.
lipw = plateau(AX, 0.016, 0.012)
add(face_any, FWD, 0.0030 * bump((Z - 1.5305) / 0.0075) * lipw)   # upper lip roll
add(face_any, FWD, -0.0020 * bump((Z - 1.5230) / 0.0035) * lipw)  # stomion
add(face_any, FWD, 0.0036 * bump((Z - 1.5145) / 0.0075) * lipw)   # lower lip
add(face_any, FWD, -0.0030 * bump((Z - 1.5035) / 0.0065) * plateau(AX, 0.012, 0.014))  # mentolabial sulcus
add(face_any, FWD, 0.0050 * bump((Z - 1.4915) / 0.0105) * plateau(AX, 0.014, 0.016))   # chin
# Submental plane: lift the skin under the jaw so the jawline reads as an edge.
under = head & (N[:, 2] < -0.25) & (Y < -0.045)
add(under, UP, 0.0026 * bump((Z - 1.478) / 0.016) * plateau(AX, 0.04, 0.03))
D[~(head | face_any)] = 0

def smooth01(v):
    v = np.clip(v, 0, 1)
    return v * v * (3 - 2 * v)


x7, y7, z7 = V07[:, 0], V07[:, 1], V07[:, 2]
photo = smooth01((.067 - np.abs(x7)) / .018) * smooth01((z7 - 1.488) / .018) * smooth01((1.632 - z7) / .018) * smooth01((-y7 - .065) / .025)
photo *= front
edges = np.array([e.vertices[:] for e in mesh.edges])
degree = np.zeros(n); np.add.at(degree, edges[:, 0], 1); np.add.at(degree, edges[:, 1], 1)
def neighbour_mean(values):
    acc = np.zeros_like(values)
    np.add.at(acc, edges[:, 0], values[edges[:, 1]]); np.add.at(acc, edges[:, 1], values[edges[:, 0]])
    return acc / np.maximum(degree, 1)[:, None] if values.ndim == 2 else acc / np.maximum(degree, 1)
# The v07 fit left the lids' inner shells level with the lid skin, which renders as faceted
# outlines around the eyes.  Any eye-region vertex that is not the front-most surface at its
# (x, z) spot is an inner shell: send it 4 mm back.
Vn = V + D
eye_zone = np.where((np.abs(np.abs(Vn[:, 0]) - 0.034) < 0.03) & (np.abs(Vn[:, 2] - 1.588) < 0.022) & (Vn[:, 1] < -0.08))[0]
inner = []
for i in eye_zone:
    close = eye_zone[(np.abs(Vn[eye_zone, 0] - Vn[i, 0]) < 0.0025) & (np.abs(Vn[eye_zone, 2] - Vn[i, 2]) < 0.0025)]
    if Vn[i, 1] > Vn[close, 1].min() + 0.0015:
        inner.append(i)
inner = np.array(inner, dtype=int)
D[inner, 1] += 0.004
print('EYE inner-shell vertices pushed back', len(inner))
for key in keys:
    data = np.array([d.co[:] for d in key.data]) + D
    key.data.foreach_set('co', data.ravel())
for i, v in enumerate(mesh.vertices):
    v.co = basis.data[i].co
mesh.update()
V = np.array([v.co[:] for v in basis.data])
X, Y, Z = V[:, 0], V[:, 1], V[:, 2]
AX = np.abs(X)
N = np.array([v.normal[:] for v in mesh.vertices])
# The folded lid topology left by the fit gives the lids faceted vertex normals.  Replace the
# normals around each eye with a smooth field averaged over the front skin surface only.
smooth_normals = N.copy()
eye_zone = np.where((np.abs(np.abs(X) - 0.034) < 0.036) & (np.abs(Z - 1.588) < 0.027) & (Y < -0.09))[0]
front_skin = eye_zone[np.isin(eye_zone, inner, invert=True) & outward[eye_zone] & front[eye_zone]]
for i in eye_zone:
    d = np.linalg.norm(V[front_skin] - V[i], axis=1)
    w = np.exp(-(d / 0.0035) ** 2) * (d < 0.009)
    if w.sum() > 1e-6:
        nrm = (N[front_skin] * w[:, None]).sum(axis=0)
        if np.linalg.norm(nrm) > 1e-6:
            smooth_normals[i] = nrm / np.linalg.norm(nrm)
mesh.normals_split_custom_set_from_vertices([tuple(v) for v in smooth_normals])
print('NORMALS smoothed around the eyes for', len(eye_zone), 'vertices')
print('SCULPT applied to', int(head.sum()), 'head vertices; max displacement %.4f m' % np.linalg.norm(D, axis=1).max())

# ---------------------------------------------------------------- 2. expression keys
def new_key(name, delta):
    key = keys.get(name)
    if key is None:
        key = body.shape_key_add(name=name, from_mix=False)
    data = V + delta
    key.data.foreach_set('co', data.ravel())
    moved = int((np.linalg.norm(delta, axis=1) > 1e-6).sum())
    print('KEY', name, 'moves', moved, 'vertices, max %.4f m' % np.linalg.norm(delta, axis=1).max())
    return key


def seg_dist(px, pz, ax, az, bx, bz):
    abx, abz = bx - ax, bz - az
    t = np.clip(((px - ax) * abx + (pz - az) * abz) / (abx * abx + abz * abz), 0, 1)
    return np.hypot(px - (ax + t * abx), pz - (az + t * abz))


S = np.zeros((n, 3))
for sx in (-1, 1):
    cx = sx * 0.027
    # Zygomaticus major: corner up, out and back toward the cheekbone.
    corner = bump((X - cx) / 0.018) * bump((Z - 1.523) / 0.014)
    S += along(UP, 0.0095 * corner) + along(OUT, 0.0062 * corner) + along(FWD, -0.0035 * corner)
    # Malar fat pad lifts and bulges.
    apple = bump((X - sx * 0.046) / 0.022) * bump((Z - 1.550) / 0.018) * plateau(Y + 0.1, 0.04, 0.03)
    S += along(UP, 0.0060 * apple) + along(N, 0.0025 * apple)
    # Nasolabial fold.
    fold = bump(seg_dist(X, Z, sx * 0.019, 1.546, sx * 0.036, 1.512) / 0.0055)
    S += along(FWD, -0.0014 * fold)
    # Lower lid rises (Duchenne), upper lid relaxes a touch.
    lower_lid = bump((X - sx * 0.034) / 0.018) * bump((Z - 1.5775) / 0.007)
    S += along(UP, 0.0032 * lower_lid)
    upper_lid = bump((X - sx * 0.034) / 0.016) * bump((Z - 1.5975) / 0.006)
    S += along(UP, -0.0010 * upper_lid)
    # Outer brow drifts up a little with a genuine smile.
    S += along(UP, 0.0012 * bump((X - sx * 0.044) / 0.016) * bump((Z - 1.606) / 0.010))
# Lip centre lifts and thins; chin skin tightens up.
S += along(UP, 0.0018 * bump(X / 0.02) * bump((Z - 1.527) / 0.012))
S += along(UP, 0.0012 * bump(X / 0.022) * bump((Z - 1.496) / 0.012))
S[~face_any] = 0
new_key('Smile', S)

B = np.zeros((n, 3))
brow_band = plateau(AX, 0.048, 0.02) * bump((Z - 1.604) / 0.016)
B += along(UP, 0.0075 * brow_band * (1 + 0.25 * np.clip(AX / 0.045, 0, 1)))
B += along(UP, 0.0022 * plateau(AX, 0.048, 0.02) * bump((Z - 1.628) / 0.014))  # forehead skin follows
for sx in (-1, 1):
    B += along(UP, 0.0018 * bump((X - sx * 0.034) / 0.016) * bump((Z - 1.5965) / 0.006))  # upper lids lift
B[~face] = 0
new_key('BrowRaise', B)

F = np.zeros((n, 3))
for sx in (-1, 1):
    inner = bump((X - sx * 0.019) / 0.016) * bump((Z - 1.604) / 0.012)
    F += along(UP, -0.0052 * inner) + along(OUT, -0.0030 * inner)
F += along(FWD, 0.0016 * bump(X / 0.012) * bump((Z - 1.600) / 0.012))  # glabella knots
F[~face] = 0
new_key('BrowFurrow', F)

# ---------------------------------------------------------------- 3. skin tone work
uv_layer = mesh.uv_layers[0]
# The base mesh packs the eyelid-margin faces into near-zero UV area; each samples a single
# texel and renders as a flat patch on the lower lids.  Give those loops the UV of the nearest
# properly mapped skin vertex so they show the same skin as their surroundings.
mesh.calc_loop_triangles()
loop_uv = np.array([uv_layer.data[l.index].uv[:] for l in mesh.loops])
loop_vert = np.array([l.vertex_index for l in mesh.loops])
good_vertex = np.zeros(n, dtype=bool)
bad_loops = []
for tri in mesh.loop_triangles:
    c = V[list(tri.vertices)].mean(axis=0)
    if not (abs(abs(c[0]) - 0.034) < 0.04 and abs(c[2] - 1.586) < 0.03 and c[1] < -0.08):
        continue
    uvs = loop_uv[list(tri.loops)]
    uv_area = abs((uvs[1][0] - uvs[0][0]) * (uvs[2][1] - uvs[0][1]) - (uvs[2][0] - uvs[0][0]) * (uvs[1][1] - uvs[0][1])) * 0.5
    ratio = uv_area / max(tri.area, 1e-12)
    if ratio < 0.4 or uvs[:, 0].min() < 0.6:
        bad_loops.extend(tri.loops)
    else:
        good_vertex[list(tri.vertices)] = True
bad_loops = np.array(sorted(set(bad_loops)), dtype=int)
good_idx = np.where(good_vertex & outward & front)[0]
good_uv = np.zeros((n, 2)); good_cnt = np.zeros(n)
for l in mesh.loops:
    if good_vertex[l.vertex_index]:
        good_uv[l.vertex_index] += loop_uv[l.index]; good_cnt[l.vertex_index] += 1
good_uv /= np.maximum(good_cnt, 1)[:, None]
for l in bad_loops:
    vi = loop_vert[l]
    d = np.linalg.norm(V[good_idx] - V[vi], axis=1)
    j = good_idx[np.argmin(d)]
    uv_layer.data[int(l)].uv = tuple(good_uv[j])
print('UV repaired lid loops', len(bad_loops), 'using', len(good_idx), 'reference vertices')
vuv = np.zeros((n, 2)); cnt = np.zeros(n)
for loop in mesh.loops:
    vuv[loop.vertex_index] += uv_layer.data[loop.index].uv[:]
    cnt[loop.vertex_index] += 1
vuv /= np.maximum(cnt, 1)[:, None]
skin = next(i for i in bpy.data.images if 'continuous_skin' in i.name)
W, H = skin.size
px = np.zeros(W * H * 4, dtype=np.float32)
skin.pixels.foreach_get(px)
px = px.reshape(H, W, 4)
ui = (vuv[:, 0] * W).astype(int) % W
vi = (vuv[:, 1] * H).astype(int) % H
C = px[vi, ui, :3].astype(np.float64)
luma = C @ np.array([0.299, 0.587, 0.114])


skin_like = luma > 0.42
# Cheek skin only: no lips, nostril shadow or brow in the reference tone.
target = C[(photo > 0.9) & skin_like & (np.abs(x7) > 0.024) & (np.abs(x7) < 0.05) & (z7 > 1.535) & (z7 < 1.58)].mean(axis=0)
print('TARGET photo skin tone', np.round(target, 3))
tree = KDTree(n)
for i in range(n):
    tree.insert(Vector(V07[i]), i)
tree.balance()
local = np.ones((n, 3))
for i in range(n):
    acc = np.zeros(3); wsum = 0.0
    for _, j, dist in tree.find_range(Vector(V07[i]), 0.035):
        if not skin_like[j]:
            continue
        w = math.exp(-(dist / 0.02) ** 2)
        acc += C[j] * w; wsum += w
    if wsum > 0:
        local[i] = acc / wsum
    else:
        local[i] = target
ratio = np.clip(target / np.maximum(local, 1e-3), 0.72, 1.32)
mult = ratio * (1 - photo)[:, None] + photo[:, None]
tone_attr = mesh.color_attributes.new(name='ToneFix', type='FLOAT_COLOR', domain='POINT')
tone_attr.data.foreach_set('color', np.concatenate([mult * 0.5, np.ones((n, 1))], axis=1).ravel())
# R: photo weight. G: neck and head skin outside the photo, whose painted shading gets relaxed too.
# B: the under-eye zone where the photo's baked shadows are lifted.
neck = smooth01((z7 - 1.27) / 0.12) * (1 - photo)
under_eye = np.zeros(n)
for sx in (-1, 1):
    under_eye = np.maximum(under_eye, bump((x7 - sx * 0.034) / 0.024) * bump((z7 - 1.571) / 0.011))
under_eye *= front * (y7 < -0.09)
mask_attr = mesh.color_attributes.new(name='PhotoMask', type='FLOAT_COLOR', domain='POINT')
mask_attr.data.foreach_set('color', np.stack([photo, neck, under_eye, np.ones(n)], axis=1).ravel())
# Zone bake: R = the strip between the eyebrows and the hairline, where the reference photo's
# own hair was projected as dark scribbles at the temples.
hairline = smooth01((z7 - 1.612) / 0.006) * smooth01((1.65 - z7) / 0.008) * front * (np.abs(x7) < 0.085)
zone_attr = mesh.color_attributes.new(name='ZoneMask', type='FLOAT_COLOR', domain='POINT')
zone_attr.data.foreach_set('color', np.stack([hairline, np.zeros(n), np.zeros(n), np.ones(n)], axis=1).ravel())


def bake_attribute(attr_name, out_name):
    mat = bpy.data.materials.new('Bake_' + attr_name); mat.use_nodes = True
    nodes = mat.node_tree.nodes; nodes.clear(); links = mat.node_tree.links
    out = nodes.new('ShaderNodeOutputMaterial'); emit = nodes.new('ShaderNodeEmission')
    attr = nodes.new('ShaderNodeVertexColor'); attr.layer_name = attr_name
    links.new(attr.outputs[0], emit.inputs[0]); links.new(emit.outputs[0], out.inputs['Surface'])
    image = bpy.data.images.new(out_name, width=W, height=H, alpha=False, float_buffer=True, is_data=True)
    tex = nodes.new('ShaderNodeTexImage'); tex.image = image; nodes.active = tex
    saved = [m for m in mesh.materials]
    mesh.materials.clear(); mesh.materials.append(mat)
    for poly in mesh.polygons:
        poly.material_index = 0
    for key in keys:
        key.value = 0
    for mod in body.modifiers:
        mod.show_viewport = False; mod.show_render = False
    bpy.ops.object.select_all(action='DESELECT'); body.select_set(True); bpy.context.view_layer.objects.active = body
    scene = bpy.context.scene; scene.render.engine = 'CYCLES'; scene.cycles.samples = 1; scene.cycles.device = 'CPU'
    scene.render.bake.margin = 16; scene.render.bake.use_clear = True
    bpy.ops.object.bake(type='EMIT')
    for mod in body.modifiers:
        mod.show_viewport = True; mod.show_render = True
    mesh.materials.clear()
    for m in saved:
        mesh.materials.append(m)
    arr = np.zeros(W * H * 4, dtype=np.float32); image.pixels.foreach_get(arr)
    np.save(str(SCRATCH / (out_name + '.npy')), arr.reshape(H, W, 4)[:, :, :3])
    print('BAKED', out_name)


bake_attribute('ToneFix', 'tone')
bake_attribute('PhotoMask', 'mask')
bake_attribute('ZoneMask', 'zone')
np.save(str(SCRATCH / 'skin.npy'), px[:, :, :3])
np.save(str(SCRATCH / 'target.npy'), target)
mesh.color_attributes.remove(mesh.color_attributes['ToneFix'])
mesh.color_attributes.remove(mesh.color_attributes['PhotoMask'])
mesh.color_attributes.remove(mesh.color_attributes['ZoneMask'])
corrected = ROOT / 'assets/characters/shyam_structured_skin.png'
result = subprocess.run([sys.executable if False else '/usr/bin/python3', str(ROOT / 'tools/hero_v08_texture.py'), str(SCRATCH), str(corrected)], capture_output=True, text=True)
print(result.stdout); print(result.stderr[-2000:])
if result.returncode:
    raise SystemExit('texture step failed')
new_skin = bpy.data.images.load(str(corrected))
new_skin.name = 'shyam_structured_skin'
for mat in mesh.materials:
    for node in mat.node_tree.nodes:
        if node.type == 'TEX_IMAGE' and node.image is skin:
            node.image = new_skin
new_skin.pack()

# ---------------------------------------------------------------- export
for key in keys:
    key.value = 0
bpy.ops.object.select_all(action='SELECT')
bpy.context.view_layer.objects.active = rig
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT / 'tools/source/hero_v08.blend'))
bpy.ops.export_scene.gltf(filepath=str(ROOT / 'assets/characters/shyam_hero_v08.glb'), export_format='GLB', use_selection=True,
                          export_animations=True, export_animation_mode='ACTIONS', export_force_sampling=True, export_morph=True,
                          export_yup=True, export_image_format='AUTO')
lap = np.linalg.norm(neighbour_mean(V) - V, axis=1)
neck_zone = (Z > 1.36) & (Z < 1.47) & (np.abs(X) > 0.03)
worst = np.argsort(-lap * neck_zone)[:5]
print('NECK laplacian worst', [(round(float(lap[i]), 5), tuple(np.round(V[i], 3))) for i in worst])
print('STRUCTURED_HERO_EXPORTED', n, 'vertices; keys', [k.name for k in keys], flush=True)
