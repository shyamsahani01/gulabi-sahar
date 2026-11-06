# v0.9.4 hero face: structure, smile, neck and FACE zoom

All PNGs here are actual Godot renders of the playable hero (`tests/hero_portraits.gd`, neutral stage light, Classic outfit unless named `street-*`). They are implementation evidence for review, not user approval. The "before" set of the same camera positions (v0.9.3 hero v07) lives in ignored `builds/hero-before/`.

**What the user asked for (2026-11-06):** the face is not built on real structure, the smile needs work including the eyebrows, there is a line on the neck, and the FACE view should zoom in on the face the way the map zooms on a point.

**Analysis of v07 (measured in the mesh, see `tools/refine_hero_v08.py` header):** the single-photo fit had pressed the reference onto an almost flat surface: the nose tip stood only 1 cm ahead of the lips, the nasion sat level with the forehead, the eye sockets were filled, and the baked studio shading of the photo (dark sockets, nose shadow, jaw shadow) did the work the geometry should do. The old Smile key moved only the lips (5.8 mm, 898 vertices). The neck line was two things: the photo region's lighter skin ending at the jaw against the darker, more orange MakeHuman neck, and the Street outfit's stubble overlay stopping in a straight band across the neck 11.5 cm below the head joint. A jagged seam across the forehead and temples was the photo's per-vertex projection ending.

**v08 (this folder):**

| File | What to look at |
|---|---|
| `hero-front`, `hero-three-quarter`, `hero-profile` | Brow ridge, nasion, nose dorsum/tip/alae, orbital recess, cheekbones, cheek hollow, lip rolls, sulcus, chin, gonial angle, tightened submental plane. Profile: nose now projects about 2 cm beyond the lips. |
| `zoom-eyes`, `zoom-mouth-chin`, `zoom-nose-three-quarter`, `zoom-low-angle` | What the in-game FACE zoom shows at 2.5–4×. Forehead/temple seam removed; photo shading de-lit so engine light shapes the face. |
| `zoom-jaw-neck`, `street-jaw-neck` | No tone step between jaw and neck (body skin colour-matched to the photo through a vertex-baked correction); the Street stubble now fades out 2 cm under the jawline instead of ending in a band. |
| `hero-smile`, `smile-three-quarter`, `smile-zoom`, `street-smile` | Rebuilt zygomatic smile: corners up/out/back, cheeks lift, nasolabial fold, lower lids rise (Duchenne squint), a light brow lift that flashes higher at the onset. |
| `hero-serious`, `hero-surprised` | Serious adds BrowFurrow (inner brows down and in, glabella knot); Surprised adds full BrowRaise. |
| `hero-full-body` | Body, outfit and shoes unchanged. |

**v09 update (same evening):** `zoom-eyes.png`, `zoom-eyes-blink.png`, `zoom-eyes-gaze.png` now show real eyeballs in restored sockets, lids that close over them, eyelashes, and the gaze turned to the side. The front/three-quarter/profile/smile renders were re-captured with v09.

**Still open, honestly:** this is the same approximate single-photo likeness on the MakeHuman topology, now with modelled structure and real eyes; it is not a scan. The iris texture is MakeHuman's brown eye, tinted; there is no separate cornea layer or eye-direction bone (gaze is a texture slide). The hair cap edge is unchanged. Exact likeness to concept 03C remains the user's call.
