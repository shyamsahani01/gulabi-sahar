# v0.9.5 real motion: motion capture, ragdoll, foot IK

Actual Godot renders (`tests/mocap_review.gd`, `tests/physics_review.gd`) of the hero in the Street outfit. Each sheet shows three moments of one clip (early, middle, late). Evidence for review, not approval.

**Source of the motion:** the CMU Graphics Lab Motion Capture Database (http://mocap.cs.cmu.edu, free for any use; "The data used in this project was obtained from mocap.cs.cmu.edu. The database was created with funding from NSF EIA-0196217."). The ASF/AMC trials are read by `tools/cmu_mocap.py`, retargeted onto the hero's own rig by `tools/cmu_retarget.py` (world-rotation deltas with a per-bone rest alignment, heading normalised so every clip faces the hero's forward, pelvis vertical scaled by hip height, horizontal travel removed because the game moves the body) and exported to `assets/characters/hero_mocap.glb`. `human.gd` swaps them in for the hand-keyed clips of the same name; the authored clips stay as the fallback for rigs without them.

| Clip (sheet) | CMU trial | What it replaces |
|---|---|---|
| `jump`, `jumpair`, `jumpland` | 13_11 forward jump | the keyframed dip / tuck / landing |
| `hardland` | 02_04 jump, balance | the keyframed deep landing |
| `jab`, `cross` | 141_14 punch and kick | the keyframed punches |
| `kick` | 74_04 kick | the keyframed kick |
| `guard` | 13_17 boxing (stance loop) | the keyframed guard |
| `dodge`, `crouch` | 77_09 duck to avoid flying object | the keyframed duck |
| `fall` | 90_18 rug-pull fall | the resident knockdown tween (punch) |
| `wave` | 141_16 wave hello | the keyframed wave |
| `sit`, `sitdown`, `standup` | 13_04 sit on stepstool | the keyframed seated pose (now with transitions) |
| `sithigh`, `sithighdown`, `sithighup` | 13_01 sit on high stool, stand up | the keyframed stool pose |
| `talk`, `listen` | 18_08 / 19_08 conversation with hand gestures | the keyframed gesture loops |
| `lookaround`, `fidget` | 77_04 looking around, 140_06 idle | the keyframed glance (idle now alternates) |
| `hit` | — | still keyframed (no suitable public clip) |

**Physics layer (`hero_physics.gd`):** `ragdoll.png` is the kick knockdown: a `PhysicalBoneSimulator3D` ragdoll (12 capsule bodies, cone/hinge joints) built on the rig at first use, pushed in the direction of the blow; punches use the mocap fall instead. The hero's own knockout ragdolls for 2.4 s before the hospital respawn. Foot IK (`SkeletonIK3D`, both legs) slides the feet onto steps and slopes while walking; the Street necklace and the hoodie hood swing on pendulums driven by the body's acceleration.

**Honest limits:** 30 fps keys from 120 fps capture; proportions are the hero's, so hands can float a little from where the subject's did; there is no blend from the ragdoll pose back to animation (it snaps on recovery); the CMU subjects were not the character, so the style is "a person", not a performance of this character.
