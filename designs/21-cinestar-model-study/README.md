# Cinestar exterior — detailed model study

19 November 2026. An isolated, editable 3D review candidate based on the user's Cinestar Street View screenshots, the existing pack 17 cinema references and four additional browser screenshots captured on 18 November. This is an actual Blender model rendered in Godot, not a generated concept picture. It is not yet the building in the playable city or installed APK.

## See the result

- [Front elevation](engine-front.png)
- [Front-right corner and side galleries](engine-corner.png)
- [Shop entrances and steps](engine-entrance.png)
- [Side arcade](engine-side.png)
- [Circular opening detail](engine-openings.png)
- [Distant-mesh inspection](engine-corner-lod1.png)
- [Earlier in-game building](../17-sector-2-central-spine/engine-cinestar-front.png) — different scene, lighting and framing; not a controlled performance comparison.

The standalone review supports keys **1–5** for those views, left-drag to orbit, the wheel to zoom and Escape to close. It uses Godot's Mobile renderer on the development laptop, not a tablet screenshot. From the main project directory:

```sh
./play.sh --path "$PWD/designs/21-cinestar-model-study"
```

## What changed in the model

- Four large circular holes cut through a thick upper facade, with inset slabs, horizontal rails and stone surrounds. The centre has the observed keyhole-shaped and smaller circular opening. These are actual voids, not dark discs placed on an unbroken wall.
- Separate pale cladding panels, recessed central display, tall flared-cap columns, rooftop nameboard and original text-only poster boards.
- Recessed ground-floor shop bays, frames, platforms, separate stair treads and handrails.
- Three open arched landings at the right corner, plus deep side galleries with floor slabs, balustrades, round ground-level columns, inset windows, shutters, AC cabinets and drainpipes.
- Original world-scaled stone joints and cladding stains in the Godot shader. The GLB includes base materials; the procedural weathering is applied by this review scene.
- Small trim has simplified geometry. A separately exported distant mesh is included; automatic distance switching in the city remains integration work.

## Evidence and limits

[Capture manifest](captures.json) contains source/resolved URLs, panorama IDs, hashes, dates visible in Street View and inspection notes. New captures are four directions at **one** user-supplied panorama, not four new stations or a complete 360°/rear survey. The `facade.png` capture is cropped context, not a full elevation. `gallery.png` is the clearest new view of the front-right corner.

The user's screenshots include March 2026 and November 2024 imagery. This study uses observed structural features without treating all older shop signs as current tenants. Pizza Hut and HDFC Bank labels follow the supplied front photo; other shop boards are generic. Movie posters are original text designs. Google image pixels are not textures in the model.

Width, height, depth, bay spacing and stair dimensions are estimated. Rear enclosure, roof and inner stair flights are simplified assumptions. Side-gallery extent and the stepped corner silhouette still need closer proportion matching; this is not a measured replica or a photoreal finished asset. Surrounding plaza buildings, parking, vegetation and people are outside this isolated building study.

## Editable assets and reproduction

- [Blender source](source/cinestar-study.blend): separate named editable parts, modifiers and material assignments.
- [Detailed GLB](cinestar-study.glb) and [distant GLB](cinestar-study-lod1.glb).
- [Generator](../../tools/build_cinestar_study.py), [Godot review](review.gd), [surface shader](surface.gdshader).
- [Model counts](model-stats.json) and [geometry validation](validation.json).

Final review: **13 geometry checks pass**; five detailed-model captures and one distant-model capture were visually inspected. The detailed mesh has **115,986 triangles** (4.3 MB GLB), reduced from the first study's 314,834 without removing the architectural features. The distant mesh has **37,114 triangles** (2.1 MB GLB). [GPU capture evidence](render-validation.json) and [reference hash/dimension checks](reference-validation.json) record the exact files. Mobile-renderer captures ran on the laptop GTX 1650; no tablet benchmark was run.

```sh
/home/shyam/Downloads/blender-5.2.0-linux-x64/blender --background --factory-startup --python tools/build_cinestar_study.py
./play.sh --headless --path "$PWD/designs/21-cinestar-model-study" --editor --import
./play.sh --headless --path "$PWD/designs/21-cinestar-model-study" --script res://validate.gd
./play.sh --path "$PWD/designs/21-cinestar-model-study" -- --capture
./play.sh --path "$PWD/designs/21-cinestar-model-study" -- --lod --capture
```

Google screenshots and Godot import caches stay local. The review project is beneath the existing `designs/.gdignore`, so it is excluded from the main game's asset import/export. Geometry checks probe the holes and arcade using collision rays; render checks inspect the five actual GPU captures. Neither substitutes for device measurements.

## Next implementation steps

1. Review the facade proportions, side-gallery length and stepped corner against the photographs; refine this editable source where needed.
2. Fit the accepted model to the compact city. Its study dimensions differ from the existing approximate 22 × 13.5 m record, so do not simply overwrite the mesh or stretch it into the old footprint. Align the front, streets and plaza; check adjoining buildings and walkable access.
3. Add simplified gameplay collision, entrance/ramp handling and automatic detail reduction at distance. Re-run cinema destination, street-clearance and route checks in the real world scene.
4. Match materials and lighting in the actual city, then add reference-led parking, trees and plaza detail. Compare at the same in-game camera positions.
5. Measure memory, frame times and image quality on the Redmi tablet before an APK delivery. No tablet FPS or installation claim accompanies this review.
