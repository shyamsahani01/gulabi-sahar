# VKI / VDN and photographed café review — 2026-11-06

Actual Godot renders: [exterior](exterior.png), [interior](interior.png).

The supplied Crazy Coffee screenshots drive the black fascia, large white lettering,
square metal glazing grid, three entry steps, white plant pots, green terrace seating,
white fence, wood tables, cane-colored chairs, gray interior walls and warm lighting.
The central entrance is open and the raised interior floor has collision.
These are authored game meshes, not photo textures or a surveyed reconstruction.
No claim of exact photographic likeness or user design approval is made.

Crazy Coffee's VDN branch address is confirmed by the brand:
https://crazycoffeeindia.com/pages/jaipur
The game position at Central Spine is approximate; the screenshots do not establish
survey coordinates or measured dimensions. The same architectural template replaces
the generic treatment of the OSM café imported in VDN; other business types keep
their own hospital, school, store and pub facades.

Fresh OSM extracts cover VDN and **southern VKI**, not the entire industrial estate.
“VKL” in the request is interpreted as VKI (Vishwakarma Industrial Area).
51 additional real mapped amenities: 27 hospitals/clinics, 4 education locations,
14 shops, 3 restaurants, 1 café and 2 pubs (MOLECULE and refuio, OSM spelling).
There was no nightclub entry in these extracts. OSM coverage and tagging may be
incomplete or outdated; no nightclub business has been invented.
The separately authored Crazy Coffee brings this change to 52 added destinations.
OSM roads total 6,323 ways. Generic footprints under new places are removed.
Footprint sizes and offsets from roads are artistic; detailed real facades for
individual schools/hospitals/pubs need further photo references.

Data provenance and original OSM IDs/tags are in assets/data/jaipur_city.json.
© OpenStreetMap contributors, ODbL-1.0:
https://www.openstreetmap.org/copyright

Reproduce supplemental imports after the base map generator:

```sh
python3 tools/import_vki.py
python3 tools/import_vki.py --vdn
./play.sh --headless --fixed-fps 60 --script res://tests/cafe_review.gd
xvfb-run -a -s '-screen 0 1280x800x24' ./play.sh --fixed-fps 60 --script res://tests/cafe_review.gd
```

Re-running the importer reuses its local XML cache and avoids duplicate OSM IDs.
Delete the corresponding /tmp/gulabi-*.osm cache to request a fresh extract.
Existing authored amenities and city services are retained. Fast travel district
markers include VKI South and Crazy Coffee · VDN. The atlas adds café/pub/club/shop
symbols; nightclub rendering is supported when a verified mapped entry exists.

Validation: city_smoke.gd, city_combat.gd, city_refresh.gd and cafe_review.gd
passed with zero failures. Café checks cover an unobstructed doorway, the raised
solid floor, VKI route connectivity and district identification.
