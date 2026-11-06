"""Retarget CMU motion-capture clips onto the hero rig and export them as one GLB.
Run: ~/MyWork/Tools/Blender/blender-4.2.3-linux-x64/blender --background --python tools/cmu_retarget.py

Input: ASF/AMC trials in builds/cmu/ (downloaded from http://mocap.cs.cmu.edu, free for any use;
see tools/cmu_mocap.py for the acknowledgement text).  Output: assets/characters/hero_mocap.glb
with the hero armature and one action per clip; human.gd swaps these in for the hand-keyed
action clips of the same name.

Method: for every mapped bone the CMU world rotation delta (relative to the ASF rest) is applied
to the hero bone, after a per-bone rest alignment that turns the hero's A-pose rest direction
into the CMU rest direction.  Bone lengths stay the hero's, so proportions are preserved.
The pelvis keeps only its vertical motion (the game moves the body) scaled by hip height; for
jumps only the dips are kept because physics provides the flight.
"""
import bpy, sys, math, pathlib, numpy as np
from mathutils import Matrix, Vector, Quaternion
ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from cmu_mocap import read_asf, read_amc, forward_kinematics, yup_to_zup, YUP_TO_ZUP
CMU = ROOT / 'builds' / 'cmu'
FPS_OUT = 30

# name: trial, start s, end s, loop, speed, pelvis mode ('dips' keeps only drops, 'full' keeps rises too, 'none')
CLIPS = {
    'Jump':       ('13_11', 1.55, 1.95, False, 1.0, 'dips'),
    'JumpAir':    ('13_11', 2.00, 2.38, True,  1.0, 'none'),
    'JumpLand':   ('13_11', 2.38, 3.15, False, 1.0, 'dips'),
    'HardLand':   ('02_04', 1.40, 2.50, False, 1.0, 'dips'),
    'Kick':       ('74_04', 1.11, 2.00, False, 1.0, 'dips'),
    'Jab':        ('141_14', 1.05, 1.58, False, 1.0, 'none'),
    'Cross':      ('141_14', 1.38, 1.95, False, 1.0, 'none'),
    'Guard':      ('13_17', 6.50, 7.70, True,  1.0, 'none'),
    'Dodge':      ('77_09', 1.90, 3.00, False, 1.6, 'full'),
    'Crouch':     ('77_09', 2.45, 2.95, True,  1.0, 'full'),
    'Fall':       ('90_18', 0.55, 1.75, False, 1.0, 'full'),
    'Wave':       ('141_16', 0.00, 2.10, False, 1.0, 'none'),
    'Sit':        ('13_04', 3.50, 7.50, True,  1.0, 'full'),
    'SitDown':    ('13_04', 2.00, 3.50, False, 1.3, 'full'),
    'StandUp':    ('13_04', 8.35, 9.45, False, 1.4, 'full'),
    'SitHigh':    ('13_01', 4.50, 7.50, True,  1.0, 'full'),
    'SitHighDown':('13_01', 3.50, 4.50, False, 1.2, 'full'),
    'SitHighUp':  ('13_01', 7.95, 8.90, False, 1.3, 'full'),
    'Talk':       ('18_08', 9.00, 12.60, True, 1.0, 'none'),
    'Listen':     ('19_08', 4.00, 7.60, True,  1.0, 'none'),
    'LookAround': ('77_04', 0.00, 3.40, False, 1.0, 'none'),
    'Fidget':     ('140_06', 8.00, 14.00, True, 1.0, 'none'),
}
# hero bone -> CMU bone
MAP = {
    'pelvis': 'root', 'spine_01': 'lowerback', 'spine_02': 'upperback', 'spine_03': 'thorax',
    'neck_01': 'upperneck', 'head': 'head',
    'clavicle_l': 'lclavicle', 'upperarm_l': 'lhumerus', 'lowerarm_l': 'lradius', 'hand_l': 'lhand',
    'clavicle_r': 'rclavicle', 'upperarm_r': 'rhumerus', 'lowerarm_r': 'rradius', 'hand_r': 'rhand',
    'thigh_l': 'lfemur', 'calf_l': 'ltibia', 'foot_l': 'lfoot', 'ball_l': 'ltoes',
    'thigh_r': 'rfemur', 'calf_r': 'rtibia', 'foot_r': 'rfoot', 'ball_r': 'rtoes',
}

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=str(ROOT / 'assets/characters/shyam_hero_v07.glb'))
rig = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
for o in list(bpy.data.objects):
    if o is not rig:
        bpy.data.objects.remove(o, do_unlink=True)
bpy.ops.outliner.orphans_purge(do_recursive=True) if hasattr(bpy.ops.outliner, 'orphans_purge') else None
if rig.animation_data:
    rig.animation_data.action = None
    for track in list(rig.animation_data.nla_tracks):
        rig.animation_data.nla_tracks.remove(track)
for a in list(bpy.data.actions):
    bpy.data.actions.remove(a)
bpy.context.view_layer.objects.active = rig
rig.select_set(True)
bpy.ops.object.mode_set(mode='POSE')
for pb in rig.pose.bones:
    pb.rotation_mode = 'QUATERNION'
    pb.matrix_basis = Matrix.Identity(4)
order = [b.name for b in rig.data.bones]  # already parent-first from the importer
# check parents come before children
seen = set()
for name in order:
    b = rig.data.bones[name]
    assert b.parent is None or b.parent.name in seen, name
    seen.add(name)
HIP_HEIGHT = rig.data.bones['pelvis'].head_local.z


def rotation_between(a, b):
    a = Vector(a).normalized(); b = Vector(b).normalized()
    return a.rotation_difference(b).to_matrix()


def np3(m):
    return Matrix([[float(x) for x in row] for row in m])


asf_cache = {}
def skeleton_for(subject):
    if subject not in asf_cache:
        asf_cache[subject] = read_asf(CMU / f'{subject}.asf')
    return asf_cache[subject]


def rest_alignment(bones):
    """Per hero bone: matrix A that maps the hero rest direction onto the CMU rest direction."""
    align = {}
    for hero_name, cmu_name in MAP.items():
        if cmu_name == 'root':
            align[hero_name] = Matrix.Identity(3)
            continue
        cb = bones[cmu_name]
        d_src = Vector(yup_to_zup(cb.direction))
        hb = rig.data.bones[hero_name]
        d_dst = (hb.tail_local - hb.head_local).normalized()
        if d_src.length < 1e-6 or cb.length < 1e-6:
            align[hero_name] = Matrix.Identity(3)
        else:
            align[hero_name] = rotation_between(d_dst, d_src)
    return align


def build_clip(name, trial, t0, t1, loop, speed, pelvis_mode):
    subject = trial.split('_')[0]
    bones = skeleton_for(subject)
    frames = read_amc(CMU / f'{trial}.amc')
    align = rest_alignment(bones)
    # standing hip height for the subject: 90th percentile of root height over the trial
    heights = np.array([forward_kinematics(bones, frames[i])['root'][1][1] for i in range(0, len(frames), 8)])
    stand_y = float(np.percentile(heights, 90))
    scale = HIP_HEIGHT / stand_y
    f0, f1 = int(t0 * 120), min(int(t1 * 120), len(frames) - 1)
    step = 120 / FPS_OUT * speed
    sample_frames = []
    f = f0
    while f <= f1:
        sample_frames.append(int(round(f))); f += step
    if sample_frames[-1] != f1:
        sample_frames.append(f1)
    action = bpy.data.actions.new(name)
    rig.animation_data_create()
    rig.animation_data.action = action
    rest_rot = {b.name: b.matrix_local.to_3x3() for b in rig.data.bones}
    rest_local = {b.name: b.matrix_local for b in rig.data.bones}
    # Heading: subjects faced whichever way they liked in the capture volume.  Turn the whole
    # clip so the first frame faces the hero's forward (-Y in rig space); relative turns stay.
    fk0 = forward_kinematics(bones, frames[sample_frames[0]])
    W0 = np3(YUP_TO_ZUP @ fk0['root'][0] @ YUP_TO_ZUP.T)
    forward0 = W0 @ Vector((0, -1, 0))
    heading = math.atan2(forward0.x, -forward0.y)
    unturn = Matrix.Rotation(-heading, 3, 'Z')
    keyed = []
    for k, fi in enumerate(sample_frames):
        fk = forward_kinematics(bones, frames[fi])
        pose_matrix = {}
        bone_quats = {}
        pelvis_loc = None
        for hero_name in order:
            hb = rig.data.bones[hero_name]
            parent = hb.parent.name if hb.parent else None
            if parent is None:
                L = rest_local[hero_name]
            else:
                L = pose_matrix[parent] @ rest_local[parent].inverted() @ rest_local[hero_name]
            cmu_name = MAP.get(hero_name)
            if cmu_name is None:
                M = L.copy()
            else:
                W_s = fk[cmu_name][0]
                W_b = unturn @ np3(YUP_TO_ZUP @ W_s @ YUP_TO_ZUP.T)
                W_t = W_b @ align[hero_name] @ rest_rot[hero_name]
                M = W_t.to_4x4()
                M.translation = L.translation
                if hero_name == 'pelvis':
                    dz = (fk['root'][1][1] - stand_y) * scale
                    if pelvis_mode == 'dips':
                        dz = min(0.0, dz)
                    elif pelvis_mode == 'none':
                        dz = 0.0
                    M.translation = L.translation + Vector((0, 0, dz))
            pose_matrix[hero_name] = M
            basis = L.inverted() @ M
            bone_quats[hero_name] = basis.to_quaternion().normalized()
            if hero_name == 'pelvis':
                pelvis_loc = basis.to_translation()
        keyed.append((k, bone_quats, pelvis_loc))
    # loop seam: ease the last 20% toward the first frame
    if loop and len(keyed) > 6:
        n = len(keyed)
        blend_from = int(n * 0.8)
        first_q = keyed[0][1]; first_loc = keyed[0][2]
        for k in range(blend_from, n):
            w = (k - blend_from + 1) / (n - blend_from)
            w = w * w * (3 - 2 * w)
            for hero_name in order:
                keyed[k][1][hero_name] = keyed[k][1][hero_name].slerp(first_q[hero_name], w)
            keyed[k] = (k, keyed[k][1], keyed[k][2].lerp(first_loc, w))
    for k, bone_quats, pelvis_loc in keyed:
        frame = k + 1
        for hero_name in order:
            pb = rig.pose.bones[hero_name]
            pb.rotation_quaternion = bone_quats[hero_name]
            pb.keyframe_insert('rotation_quaternion', frame=frame)
            if hero_name == 'pelvis':
                pb.location = pelvis_loc
                pb.keyframe_insert('location', frame=frame)
    action.frame_range = (1, len(keyed))
    action.use_frame_range = True
    for fc in action.fcurves:
        for kp in fc.keyframe_points:
            kp.interpolation = 'LINEAR'
    rig.animation_data.action = None
    track = rig.animation_data.nla_tracks.new()
    track.name = name
    strip = track.strips.new(name, 1, action)
    strip.name = name
    print('CLIP', name, trial, '%.2f-%.2fs' % (t0, t1), len(keyed), 'keys', 'loop' if loop else '', 'stand %.2f scale %.2f heading %.0f' % (stand_y, scale, math.degrees(heading)), flush=True)
    return action


bpy.context.scene.render.fps = FPS_OUT
for name, spec in CLIPS.items():
    build_clip(name, *spec)
bpy.ops.object.mode_set(mode='OBJECT')
for pb in rig.pose.bones:
    pb.matrix_basis = Matrix.Identity(4)
# Godot only builds a Skeleton3D (and bone animation tracks) for joints used by a skin, so a
# one-triangle skinned carrier mesh rides along; human.gd never renders it.
carrier_mesh = bpy.data.meshes.new('MocapCarrier')
carrier_mesh.from_pydata([(0, 0, 0.9), (0.01, 0, 0.9), (0, 0.01, 0.9)], [], [(0, 1, 2)])
carrier = bpy.data.objects.new('MocapCarrier', carrier_mesh)
bpy.context.collection.objects.link(carrier)
carrier.parent = rig
group = carrier.vertex_groups.new(name='pelvis')
group.add([0, 1, 2], 1.0, 'REPLACE')
mod = carrier.modifiers.new('Armature', 'ARMATURE'); mod.object = rig
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=str(ROOT / 'assets/characters/hero_mocap.glb'), export_format='GLB', use_selection=True,
                          export_animations=True, export_animation_mode='ACTIONS', export_force_sampling=True,
                          export_frame_range=False, export_yup=True, export_skins=True, export_morph=False,
                          export_all_influences=False)
print('MOCAP_EXPORTED', len(CLIPS), 'clips', flush=True)
