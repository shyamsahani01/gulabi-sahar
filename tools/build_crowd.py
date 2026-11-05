"""Generate CC0 MakeHuman crowd variants with MPFB2 and export them as GLB for Godot.

Run with the portable Blender that has the MPFB extension installed:
  blender --background --python tools/build_crowd.py -- <mpfb_user_data_dir> <out_dir>

The user-data dir must contain the unzipped MakeHuman asset packs (system assets, skins,
hair, eyebrows, clothes). Every export uses the "game_engine" rig so the project's existing
Mixamo-derived Idle/Walk/Run clips (bone names Root, pelvis, spine_01, foot_l...) apply.
"""
import bpy, sys, os, glob, importlib, random

ARGS = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
USER_DATA = ARGS[0] if ARGS else os.path.expanduser("~/mpfb_data")
OUT = ARGS[1] if len(ARGS) > 1 else os.path.abspath("assets/characters/crowd")
os.makedirs(OUT, exist_ok=True)


def dynamic_import(package_suffix, key):
    for name in list(sys.modules):
        if name.endswith(package_suffix):
            module = importlib.import_module(name)
            return getattr(module, key)
    raise ImportError(package_suffix)


prefs = None
for key in bpy.context.preferences.addons.keys():
    if key.endswith("mpfb"):
        prefs = bpy.context.preferences.addons[key].preferences
if prefs is not None and hasattr(prefs, "mpfb_user_data"):
    prefs.mpfb_user_data = USER_DATA

HumanService = dynamic_import("mpfb.services.humanservice", "HumanService")
AssetService = dynamic_import("mpfb.services.assetservice", "AssetService")
ExportService = dynamic_import("mpfb.services.exportservice", "ExportService")
ObjectService = dynamic_import("mpfb.services.objectservice", "ObjectService")
TargetService = dynamic_import("mpfb.services.targetservice", "TargetService")
HumanObjectProperties = dynamic_import("mpfb.entities.objectproperties", "HumanObjectProperties")


def find(subdir, *keywords, ext=".mhclo", exclude=()):
    """First asset file under <user data>/data/<subdir> whose name contains all keywords."""
    hits = []
    for path in glob.glob(os.path.join(USER_DATA, "data", subdir, "**", "*" + ext), recursive=True):
        base = os.path.basename(path).lower()
        if all(k in base for k in keywords) and not any(x in base for x in exclude):
            hits.append(path)
    hits.sort()
    return hits[0] if hits else None


def listing(subdir, ext=".mhclo"):
    return sorted(os.path.basename(p) for p in glob.glob(os.path.join(USER_DATA, "data", subdir, "**", "*" + ext), recursive=True))


print("AVAILABLE skins:", listing("skins", ".mhmat"))
print("AVAILABLE hair:", listing("hair"))
print("AVAILABLE clothes:", listing("clothes"))
print("AVAILABLE eyebrows:", listing("eyebrows"))

# name, gender(0 male..1 female), age(0..1; 0.5 = 25y), skin keywords, hair keywords, clothes keyword lists
VARIANTS = [
    ("man_shirt_01", 0.0, 0.5, ("young", "caucasian", "male"), ("short",), [("shirt",), ("pants",), ("shoes",)]),
    ("man_shirt_02", 0.0, 0.55, ("young", "asian", "male"), ("short",), [("shirt",), ("jeans",), ("shoes",)]),
    ("man_kurta_01", 0.05, 0.6, ("middleage", "caucasian", "male"), ("short",), [("shirt",), ("pants",), ("shoes",)]),
    ("woman_kurti_01", 1.0, 0.5, ("young", "caucasian", "female"), ("long",), [("dress",), ("shoes",)]),
    ("woman_kurti_02", 1.0, 0.45, ("young", "asian", "female"), ("ponytail",), [("shirt",), ("skirt",), ("shoes",)]),
    ("woman_dress_01", 1.0, 0.55, ("middleage", "caucasian", "female"), ("bob",), [("dress",), ("shoes",)]),
    ("boy_01", 0.0, 0.18, ("young", "caucasian", "male"), ("short",), [("shirt",), ("short",), ("shoes",)]),
    ("boy_02", 0.0, 0.22, ("young", "asian", "male"), ("short",), [("shirt",), ("pants",), ("shoes",)]),
    ("girl_01", 1.0, 0.2, ("young", "caucasian", "female"), ("long",), [("dress",), ("shoes",)]),
    ("old_man_01", 0.0, 0.9, ("old", "caucasian", "male"), ("short",), [("shirt",), ("pants",), ("shoes",)]),
    ("old_woman_01", 1.0, 0.88, ("old", "caucasian", "female"), ("bob",), [("dress",), ("shoes",)]),
]


def build(name, gender, age, skin_keys, hair_keys, clothes_keys):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    basemesh = HumanService.create_human()
    # Indian phenotype: a mix leaning asian/caucasian with warmer skin handled by the texture tint in-game.
    HumanObjectProperties.set_value("gender", gender, entity_reference=basemesh)
    HumanObjectProperties.set_value("age", age, entity_reference=basemesh)
    HumanObjectProperties.set_value("african", 0.25, entity_reference=basemesh)
    HumanObjectProperties.set_value("asian", 0.35, entity_reference=basemesh)
    HumanObjectProperties.set_value("caucasian", 0.4, entity_reference=basemesh)
    HumanObjectProperties.set_value("muscle", random.uniform(0.4, 0.6), entity_reference=basemesh)
    HumanObjectProperties.set_value("weight", random.uniform(0.45, 0.6), entity_reference=basemesh)
    HumanObjectProperties.set_value("height", random.uniform(0.45, 0.55), entity_reference=basemesh)
    TargetService.reapply_macro_details(basemesh)
    skin = find("skins", *skin_keys, ext=".mhmat") or find("skins", "male" if gender < 0.5 else "female", ext=".mhmat")
    if skin:
        HumanService.set_character_skin(skin, basemesh, skin_type="GAMEENGINE")
    for subdir, keys, atype in [("eyes", ("low-poly",), "Eyes"), ("eyebrows", ("eyebrow001",), "Eyebrows"), ("eyelashes", ("eyelashes01",), "Eyelashes"), ("teeth", ("teeth_base",), "Teeth")]:
        path = find(subdir, *keys) or find(subdir)
        if path:
            HumanService.add_mhclo_asset(path, basemesh, asset_type=atype, material_type="GAMEENGINE")
    hair = find("hair", *hair_keys) or find("hair")
    if hair:
        HumanService.add_mhclo_asset(hair, basemesh, asset_type="Hair", material_type="GAMEENGINE")
    gender_word = "male" if gender < 0.5 else "female"
    for keys in clothes_keys:
        path = find("clothes", gender_word, *keys, exclude=("fe" + "male",) if gender_word == "male" else ()) or find("clothes", *keys)
        if path:
            HumanService.add_mhclo_asset(path, basemesh, asset_type="Clothes", material_type="GAMEENGINE")
        else:
            print("MISSING clothes", keys)
    HumanService.add_builtin_rig(basemesh, "game_engine")
    export_root = ExportService.create_character_copy(basemesh, name_suffix="_export")
    export_basemesh = ObjectService.find_object_of_type_amongst_nearest_relatives(export_root, "Basemesh")
    ExportService.bake_modifiers_remove_helpers(export_basemesh, bake_masks=True, bake_subdiv=True, remove_helpers=True, also_proxy=True)
    export_root.name = "Shyam.rig"
    bpy.ops.object.select_all(action="DESELECT")
    export_root.select_set(True)
    for child in ObjectService.get_list_of_children(export_root):
        child.select_set(True)
    bpy.context.view_layer.objects.active = export_root
    path = os.path.join(OUT, name + ".glb")
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=True, export_animations=False, export_apply=True, export_yup=True, export_skins=True, export_image_format="JPEG", export_jpeg_quality=85)
    print("WROTE", path, flush=True)


for variant in VARIANTS:
    try:
        build(*variant)
    except Exception as error:  # keep going so one missing asset does not stop the batch
        import traceback
        traceback.print_exc()
        print("FAILED", variant[0], error, flush=True)
print("DONE")
