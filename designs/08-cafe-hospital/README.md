# Café and hospital review — 2026-11-06

Actual engine captures: [exterior](exterior.png), [interior](interior.png),
[Shri Ram Hospital type](hospital.png).

The café uses the supplied permanent storefront/interior structure. Opening-day
balloons are omitted. This is modeled geometry with clear glazing, a left entrance,
five steps, black fascia/central pier, terrace furniture, plants, cane seating,
wood flooring and warm interior lighting. Dimensions are inferred from photographs.
All seven mapped café locations use the template, retaining their own names.

The 103 mapped hospitals/clinics and authored Sahar Hospital use an enterable
white/teal hospital template. Hospital-specific reference photos were not supplied.
Its exterior, reception and waiting seats are authored; the real map business names
are preserved. There is no claim of an exact individual hospital reconstruction.

Validation: city smoke, service refresh and café/hospital entrance checks passed.
The café check verifies walking up the steps into the interior, solid raised floor,
clear hospital reception approach, VKI district identification and route connectivity.

```sh
./play.sh --headless --fixed-fps 60 --script res://tests/cafe_review.gd
xvfb-run -a -s '-screen 0 1280x800x24' ./play.sh --fixed-fps 60 --script res://tests/cafe_review.gd
./build-android.sh
python3 tools/install_tablet.py <wireless-ip:port>
```
