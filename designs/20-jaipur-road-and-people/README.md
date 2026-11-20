# Cinestar road, pavement and residents — 0.9.13 / code 22

17 November 2026. This pass improves the western approximately 256 m block of OSM way 261520115 studied in [pack 19](../19-cinestar-approach/README.md), plus the game's shared resident models.

## Actual street references

[Local photo gallery](reference-gallery.html) · [Capture provenance](captures.json) · [Photo checks](survey-validation.json)

Twenty additional **2560 × 1440 headed Google Chrome screenshots** focus on the road surface, kerbs, shop edges, parking and junction approaches. They retain Google attribution and show March 2026 Street View imagery. These are closer views at the same six panorama positions as pack 19, whose 48 overlapping frames already cover the horizontal 360° at each position. The new frames are not another complete spherical survey. Across packs 17–20 there are now 210 local reference frames from 17 distinct panorama positions.

The images show an unmarked, undivided two-way block, worn gray/brown asphalt, dusty parking edges, cars and scooters, trees, carts, intermittent paving and low kerbs. The endpoint approach also shows painted junction kerbs and faded crossing markings. The block itself does not receive a central divider. Occluded buildings, side-lane interiors and exact measured dimensions remain unverified. The source PNGs stay local and are excluded from Git and Android exports; no Google pixels are game textures.

## Game changes

- The two surveyed road segments use a visual width estimate of 9 source units (7.92 compact game metres), with original centerline vertices retained. The remainder of the OSM way keeps its existing width. Asphalt and paving use original procedural shaders.
- A dusty parking edge, intermittent low kerbs, paving, drain covers and shallow driveway ramps distinguish the road from its footpath. Pedestrian routes use checked pavement space. Shoulder scooters, parked cars and two fitted vendor pockets add roadside activity. Object placement is an approximation within the compact map, not a claim that every object occupies its photographed coordinates.
- Only six previously generated infill facades move outward where needed for the pavement. Imported named buildings, Cinestar/Funstar destinations and original road connectivity are retained. Side-road openings remain clear.
- Traffic can use the observed block. Outward and return travel get separate left-hand lanes; obstacle checks include pedestrians.
- Eleven real resident GLBs replace the missing-file fallback that had made everyone use the same crowd mesh. Casual shirts, kurta/kurti and sari-inspired clothing, varied builds, modest face-shape edits, skin palettes, hair buns, glasses and footwear provide visible variation. Children and elders use separate variants. They share the established rig/animations; these are stylized authored characters, not scanned people or a finished photoreal crowd.

The approved player hero asset is separate from this crowd work. The new generator is `tools/build_jaipur_crowd.py`, using the existing licensed MakeHuman-derived crowd mesh and Walk rig. `tools/share_crowd_textures.py` keeps common textures shared across the variants.

## Review and delivery

Original Godot previews: [street west](engine-west.png), [street east](engine-east.png), [overview](engine-overview.png), [residents](engine-residents.png), [walking residents](engine-residents-walking.png), [vendor detail](engine-vendor.png).

Runtime validation and tablet delivery are recorded in `validation.json` after the final build. This remains a partial reconstruction of one surveyed block. Exact continuous frontages, realistic vegetation, the exposed concrete frame and the adjacent hidden inner lane remain unfinished.
