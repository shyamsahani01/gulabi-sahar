"""Smaller playable crop, retaining the existing centre and restoring education south.
Read-only inputs: archived Jaipur and the previous VKI/VDN crop. No new place claims.
"""
import copy
import json
from pathlib import Path
import build_compact_city as clip

ROOT = Path(__file__).resolve().parents[1]
BOUNDS = (-2600., -4850., -1300., -1975.)

def build():
    old = json.loads((ROOT/'assets/data/vki_vdn_city.json').read_text())
    archive = json.loads((ROOT/'assets/data/jaipur_city.json').read_text())
    clip.BOUNDS = BOUNDS
    out = copy.deepcopy(old)
    out['roads'] = [dict(r, p=line) for r in archive['roads'] for line in clip.lines(r['p'])]
    out['navigation'] = [line for r in archive['navigation'] for line in clip.lines(r)]
    out['buildings'] = [b for b in old['buildings'] if clip.footprint(b)]
    old_bounds = old['meta']['playable_bounds']
    def old_inside(p):
        return old_bounds[0] <= p[0] <= old_bounds[2] and old_bounds[1] <= p[1] <= old_bounds[3]
    out['buildings'] += [b for b in archive['buildings'] if not old_inside((b['x'],b['z'])) and clip.footprint(b)]
    out['amenities'] = [a for a in old['amenities'] if clip.footprint(dict(x=a['p'][0],z=a['p'][1],w=a['w'],d=a['d'],a=a['a']))]
    known = {a.get('osm_id') for a in out['amenities']}
    for a in archive['amenities']:
        if a.get('osm_id') not in known and clip.footprint(dict(x=a['p'][0],z=a['p'][1],w=a['w'],d=a['d'],a=a['a'])):
            out['amenities'].append(a)
            known.add(a.get('osm_id'))
    # These imported point records share the same Biyani campus. Keep their
    # names searchable, but do not stack three solid buildings on one plot.
    for a in out['amenities']:
        if a.get('osm_id') in (9926097117,9926105017):
            a['shared_campus'] = 9926090617
    out['parks'] = [p for p in archive['parks'] if all(clip.inside(q) for q in p['p'])]
    assert all(clip.inside(p['p']) for p in out['pois'])
    out['meta']['playable_bounds'] = list(BOUNDS)
    out['meta']['edition'] = 'vki-vdn-focused-v2'
    out['meta']['playable_note'] = 'Smaller VKI/VDN corridor including the archived school/college area to the south. Original object scale retained. Original datasets unchanged. OSM records are dated imports, not newly verified tenancies.'
    target = ROOT/'assets/data/vki_vdn_city_small.json'
    target.write_text(json.dumps(out,ensure_ascii=False,separators=(',',':'))+'\n')
    folder = ROOT/'designs/22-startup-and-smaller-map'
    folder.mkdir(exist_ok=True)
    area = (BOUNDS[2]-BOUNDS[0])*(BOUNDS[3]-BOUNDS[1])*.88**2
    before = (old_bounds[2]-old_bounds[0])*(old_bounds[3]-old_bounds[1])*.88**2
    summary = {'date':'2026-11-19','bounds':list(BOUNDS),'area_km2':area/1e6,'previous_area_km2':before/1e6,'area_reduction_percent':100*(1-area/before),
        'counts':{k:len(out[k]) for k in ('roads','buildings','amenities','parks','pois')},
        'education':[a['name'] for a in out['amenities'] if a['kind']=='school'],
        'removed_amenities':[a['name'] for a in old['amenities'] if a not in out['amenities']],
        'source':'Existing archived OSM import; no invented real places or resized roads/buildings'}
    (folder/'map-scope.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps(summary,ensure_ascii=False,indent=2))

if __name__ == '__main__':build()
