"""CMU Graphics Lab motion-capture reader (ASF skeleton + AMC motion) with forward kinematics.
Pure numpy; shared by the analysis step and the Blender retarget (tools/cmu_retarget.py).

The CMU database (http://mocap.cs.cmu.edu) is free for any use, including commercial, with the
request to acknowledge: "The data used in this project was obtained from mocap.cs.cmu.edu.
The database was created with funding from NSF EIA-0196217."

Conventions: ASF is Y-up, angles in degrees, lengths in 1/0.45 inch units (1 unit = 0.056444 m).
A bone's local rotation at a frame is C · R(amc) · C^-1 with C the bone's `axis` rotation;
its world rotation is the parent's world rotation times that.  Bone positions follow the
`direction` * `length` offsets.
"""
import re, math, numpy as np

UNIT_M = 2.54 / 100 / 0.45  # metres per CMU length unit


def rot_x(a):
    c, s = math.cos(a), math.sin(a)
    return np.array([[1, 0, 0], [0, c, -s], [0, s, c]])


def rot_y(a):
    c, s = math.cos(a), math.sin(a)
    return np.array([[c, 0, s], [0, 1, 0], [-s, 0, c]])


def rot_z(a):
    c, s = math.cos(a), math.sin(a)
    return np.array([[c, -s, 0], [s, c, 0], [0, 0, 1]])


def euler(angles_deg, order='XYZ'):
    """ASF/AMC euler: rotations applied in the listed order, i.e. R = Rz · Ry · Rx for XYZ."""
    m = np.eye(3)
    for axis, a in zip(order, angles_deg):
        r = {'X': rot_x, 'Y': rot_y, 'Z': rot_z}[axis](math.radians(a))
        m = r @ m
    return m


class Bone:
    __slots__ = ('name', 'direction', 'length', 'axis', 'order', 'dof', 'parent', 'children', 'C', 'Cinv')

    def __init__(self, name):
        self.name = name; self.direction = np.zeros(3); self.length = 0.0; self.axis = np.zeros(3)
        self.order = 'XYZ'; self.dof = []; self.parent = None; self.children = []
        self.C = np.eye(3); self.Cinv = np.eye(3)


def read_asf(path):
    text = open(path).read()
    bones = {'root': Bone('root')}
    root = bones['root']
    root_sec = re.search(r':root(.*?):bonedata', text, re.S).group(1)
    m = re.search(r'order\s+(.*)', root_sec); root.dof = m.group(1).split()
    m = re.search(r'axis\s+(\w+)', root_sec); root.order = m.group(1)
    bonedata = re.search(r':bonedata(.*?):hierarchy', text, re.S).group(1)
    for block in re.findall(r'begin(.*?)end', bonedata, re.S):
        name = re.search(r'name\s+(\S+)', block).group(1)
        b = Bone(name)
        b.direction = np.array([float(x) for x in re.search(r'direction\s+(.*)', block).group(1).split()[:3]])
        b.length = float(re.search(r'length\s+(\S+)', block).group(1))
        ax = re.search(r'axis\s+(.*)', block).group(1).split()
        b.axis = np.array([float(x) for x in ax[:3]]); b.order = ax[3] if len(ax) > 3 else 'XYZ'
        m = re.search(r'dof\s+(.*)', block)
        b.dof = m.group(1).split() if m else []
        b.C = euler(b.axis, b.order); b.Cinv = b.C.T
        bones[name] = b
    hier = re.search(r':hierarchy\s*begin(.*?)end', text, re.S).group(1)
    for line in hier.strip().splitlines():
        parts = line.split()
        if len(parts) < 2:
            continue
        parent = bones[parts[0]]
        for child in parts[1:]:
            bones[child].parent = parent; parent.children.append(bones[child])
    return bones


def read_amc(path):
    frames = []
    current = None
    for line in open(path):
        line = line.strip()
        if not line or line.startswith('#') or line.startswith(':'):
            continue
        if line.isdigit():
            current = {}; frames.append(current); continue
        parts = line.split()
        current[parts[0]] = [float(x) for x in parts[1:]]
    return frames


def forward_kinematics(bones, frame):
    """Return {bone: (world_rotation 3x3, start_position, end_position)} in metres, Y-up."""
    out = {}
    root = bones['root']
    vals = frame['root']
    t = np.zeros(3); angles = [0.0, 0.0, 0.0]
    for dof, v in zip(root.dof, vals):
        if dof == 'TX': t[0] = v
        elif dof == 'TY': t[1] = v
        elif dof == 'TZ': t[2] = v
        elif dof == 'RX': angles[0] = v
        elif dof == 'RY': angles[1] = v
        elif dof == 'RZ': angles[2] = v
    R = euler(angles, root.order)
    pos = t * UNIT_M
    out['root'] = (R, pos, pos)

    def recurse(bone, parent_R, parent_end):
        vals = frame.get(bone.name, [])
        angles = {'rx': 0.0, 'ry': 0.0, 'rz': 0.0}
        for dof, v in zip(bone.dof, vals):
            angles[dof] = v
        local = bone.C @ euler([angles['rx'], angles['ry'], angles['rz']], 'XYZ') @ bone.Cinv
        W = parent_R @ local
        start = parent_end
        end = start + W @ (bone.direction * bone.length * UNIT_M)
        out[bone.name] = (W, start, end)
        for child in bone.children:
            recurse(child, W, end)

    for child in root.children:
        recurse(child, R, pos)
    return out


def yup_to_zup(v):
    """CMU (x right, y up, z toward viewer) → Blender (x right, y back, z up)."""
    v = np.asarray(v)
    return np.array([v[0], -v[2], v[1]])


YUP_TO_ZUP = np.array([[1, 0, 0], [0, 0, -1], [0, 1, 0]], dtype=float)
