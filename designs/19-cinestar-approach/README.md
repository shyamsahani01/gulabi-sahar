# Cinestar approach — western block of OSM 261520115

Surveyed 16 November 2026 using actual headed Google Chrome page screenshots of March 2026 Google Street View. This bounded block runs from the western junction near 26.9650616, 75.7805289 through Cinestar to the eastern junction near 26.9639712, 75.7828006 (approximately 256 m). It does not cover the remainder of the longer OSM way.

[Local photo gallery](reference-gallery.html) · [Station plan](plan.json) · [Capture provenance](captures.json)

Six distinct panorama stations, eight overlapping 75° views per station at 45° heading increments: complete horizontal 360° coverage at each station. This is a sequence of street panoramas, not a stitched spherical texture or a survey of hidden alleys/interiors. Original PNGs remain local, with Google attribution intact; Git carries URLs, hashes, tools and original game geometry. Photos are excluded from the APK.

The west-end photos show Cinestar's circular facade openings, an opposite exposed concrete frame, street trees, parked cars, carts and a junction. Middle views show cream commercial galleries with green shades, rose/cream apartment fronts with white balcony rails and AC units, ground-floor shops and parking. The east end shows a mobile mast, trees, a pottery seller and the next junction. Buildings behind trees and inside blocks remain partly hidden.

The 0.9.12 game pass adapts the observed cream/green galleries and rose apartment balcony vocabulary to existing generated plots, adds nine individually checked tree/parking pockets. Existing Cinestar and Funstar destinations remain. All original road vertices, widths and imported named places are retained. Footprint scale, heights, window counts and object placement are approximate; generic shop shells do not assert actual business tenancy. The exposed concrete frame, pottery stall and exact continuous building frontage remain future modeling work. The mast placement guard skips its proposed location because an imported footway crosses it. Side-wall windows are inferred continuations of the observed vocabulary. This is a surveyed block with a partial facade pass, not a completed replica of the whole lane.

0.9.12 / code 21 is built, signed, installed in place and launched on the Redmi Pad 2 Pro 5G via wireless debugging. The new port was discovered on the already known tablet address. Package and signing identity are unchanged. [Validation](validation.json): street clearance at 21 positions × 3 lateral offsets × 2 heights passes; Cinestar/Funstar destination, entrance and route regression passes; APK signature, 16 KB alignment and archive checks pass. Six facades and nine clear tree/parking pockets are present. [Photo validation](survey-validation.json): all 48 hashes/dimensions pass, all three contact sheets reviewed, adjacent panorama spacing at most 57.7 m.

Original game previews: [west](engine-west.png), [east](engine-east.png), [overview](engine-overview.png).

Native tablet check: MAP → search **Cinestar** → keyboard Done → select result → **GO HERE** passed on the relaunched app. [Actual arrival screenshot](tablet-cinestar-arrival.png). A first rapid automated attempt ended after an injected Android Back command (process exit status 9, no matching app crash stack); the cause was not confirmed. The slower retry completed and the process remained running.

## Continuation — 17 November, 0.9.13

[Pack 20](../20-jaipur-road-and-people/README.md) adds 20 close surface/pavement screenshots at these same six panorama stations, improves the roadway and roadside activity, and replaces the identical crowd fallback with eleven authored variants. This later pass overrides the width of only the two surveyed road segments, moves the six generated infill facades outward where needed and replaces the earlier nine-pocket street treatment. The 0.9.12 descriptions above remain historical delivery records. Original centerline vertices, imported named places and the unobserved remainder of the way are retained.

## Detailed building review — 19 November

[Pack 21: Cinestar model study](../21-cinestar-model-study/README.md) provides an editable Blender exterior, GLBs and actual Godot front/corner/entrance previews. It adds real circular openings, recessed shops, open arched landings and a deep side arcade using the user's screenshots and four additional views from their panorama. This is an isolated review candidate, not an update to the playable city or installed APK. Its approximate dimensions still require fitting to the compact map; integration and tablet performance checks remain pending.

## 20 November: whole-game scope and smaller map

The user clarified that the playable area should shrink while graphics improve across the game. [Pack 22](../22-startup-and-smaller-map/README.md) records the 30.3% smaller boundary, startup loader, material pass, campuses, hospital reception actions and park seating. Full-map realism and complete cinema interiors remain unfinished; this older approach study is not a claim that those are complete.
