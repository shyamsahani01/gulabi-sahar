"""Merge the southern VKI OSM extract without replacing existing authored city data.
Usage: python3 tools/import_vki.py [cached.osm]
The bounding box covers southern VKI, not the entire industrial estate.
"""
import datetime
import json
import math
from pathlib import Path
import sys
import urllib.request
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
AREA = 'VDN' if '--vdn' in sys.argv else 'VKI south'
BBOX = [75.765,26.945,75.805,26.982] if AREA == 'VDN' else [75.755,26.973,75.788,27.005]
URL = 'https://api.openstreetmap.org/api/0.6/map?bbox=' + ','.join(map(str,BBOX))
args = [a for a in sys.argv[1:] if not a.startswith('--')]
path = Path(args[0]) if args else Path('/tmp/gulabi-' + AREA.replace(' ','-') + '.osm')
if not path.exists():
    path.write_bytes(urllib.request.urlopen(URL, timeout=90).read())
xml = ET.parse(path).getroot()
city_path = ROOT / 'assets/data/jaipur_city.json'
city = json.loads(city_path.read_text())
def xy(n):
    return [round((float(n['lon'])-75.8085)*99100*.65, 2),
            round(-(float(n['lat'])-26.9267)*111320*.65, 2)]
nodes = {n.attrib['id']: xy(n.attrib) for n in xml.findall('node')}
def tags(e):
    return {t.attrib['k']: t.attrib['v'] for t in e.findall('tag')}
def kind(t):
    a = t.get('amenity')
    if a in ('hospital','clinic') or t.get('healthcare') in ('hospital','clinic'): return 'hospital'
    if a in ('school','college','university'): return 'school'
    if a == 'cafe': return 'cafe'
    if a in ('pub','bar'): return 'pub'
    if a == 'nightclub' or t.get('club'): return 'club'
    if a in ('restaurant','fast_food'): return 'restaurant'
    if a == 'pharmacy': return 'pharmacy'
    if t.get('shop'): return 'shop'
widths = {'trunk':18,'primary':15,'secondary':12,'tertiary':10,'residential':6,'living_street':5,'unclassified':7,'service':4,'footway':2.5,'path':2.5}
road_ids = {r['id'] for r in city['roads']}
existing = {(a.get('osm_type','way' if a.get('osm_id',0)>100000000 else 'node'),a.get('osm_id')) for a in city['amenities']}
added = []
for e in list(xml.findall('way')) + list(xml.findall('node')):
    t = tags(e)
    pts = [nodes[n.attrib['ref']] for n in e.findall('nd') if n.attrib['ref'] in nodes] if e.tag == 'way' else [nodes[e.attrib['id']]]
    if not pts: continue
    ident = int(e.attrib['id'])
    road_kind = t.get('highway','').replace('_link','')
    if e.tag == 'way' and road_kind in widths and ident not in road_ids and len(pts)>1:
        city['roads'].append(dict(id=ident,name=t.get('name',''),kind=road_kind,width=widths[road_kind],p=pts,source='osm'))
        # Retain original OSM vertices so shared junctions stay connected.
        for p,q in zip(pts,pts[1:]):
            city['navigation'].append([[round(v,1) for v in p],[round(v,1) for v in q]])
        road_ids.add(ident)
    k = kind(t)
    if not k or (e.tag,ident) in existing: continue
    # Avoid duplicate amenities already represented by earlier extracts.
    if any(a.get('osm_id')==ident for a in city['amenities']): continue
    ring = pts[:-1] if len(pts)>1 and pts[0]==pts[-1] else pts
    p = [round(sum(v[i] for v in ring)/len(ring),2) for i in (0,1)]
    size = {'hospital':(24,18),'school':(30,20),'cafe':(11,8),'club':(14,10),'pub':(12,9)}.get(k,(9,7))
    w,d = size
    # Road-aligned frontage, with the doorway facing the closest segment.
    best = None
    for r in city['roads']:
        if r['width']<4: continue
        for u,v in zip(r['p'],r['p'][1:]):
            dx,dz=v[0]-u[0],v[1]-u[1]; length=dx*dx+dz*dz
            if not length: continue
            f=max(0,min(1,((p[0]-u[0])*dx+(p[1]-u[1])*dz)/length))
            q=[u[0]+f*dx,u[1]+f*dz]; dist=math.dist(p,q)
            if best is None or dist<best[0]: best=(dist,q,dx,dz,r['width'])
    if best is None: continue
    dist,q,dx,dz,rw=best
    angle=-math.atan2(dz,dx)
    nx,nz=p[0]-q[0],p[1]-q[1]
    length=math.hypot(nx,nz)
    if length<.01: nx,nz=-dz,dx; length=math.hypot(nx,nz)
    offset=max(length,rw/2+d/2+3)
    p=[round(q[0]+nx/length*offset,2),round(q[1]+nz/length*offset,2)]
    front=1 if math.sin(angle)*(q[0]-p[0])+math.cos(angle)*(q[1]-p[1])>0 else -1
    a=dict(name=t.get('name',t.get('brand','')),hindi=t.get('name:hi',''),kind=k,p=p,a=round(angle,4),w=w,d=d,front=front,osm_id=ident,osm_type=e.tag,tags=t,source='osm',area=AREA)
    if k=='cafe': a['design']='reference_cafe'
    city['amenities'].append(a); added.append(a)
    city['buildings']=[b for b in city['buildings'] if b.get('kind') or b.get('service') or math.dist((b['x'],b['z']),p)>math.hypot(b['w'],b['d'])/2+math.hypot(w,d)/2+1]
# Explicitly approximate placement: official branch address, not surveyed coordinates.
cafe_id=-91001
city['amenities']=[a for a in city['amenities'] if a.get('osm_id')!=cafe_id]
p=[round((75.7838-75.8085)*99100*.65,2),round(-(26.9660-26.9267)*111320*.65,2)]
cafe=dict(name='Crazy Coffee',hindi='क्रेज़ी कॉफ़ी',kind='cafe',p=p,a=0,w=12,d=9,front=1,osm_id=cafe_id,source='authored',area='VDN',design='reference_cafe',location_accuracy='Approximate Central Spine placement; branch address verified, coordinates not surveyed.',source_url='https://crazycoffeeindia.com/pages/jaipur',reference='User supplied exterior and interior screenshots, 2026-11-06')
city['amenities'].append(cafe)
# Remove colliding generic infill under the authored cafe only.
city['buildings']=[b for b in city['buildings'] if b.get('kind') or b.get('service') or math.dist((b['x'],b['z']),p)>math.hypot(b['w'],b['d'])/2+math.hypot(12,9)/2+1]
for name,hi,point,k in [('VKI South','विश्वकर्मा औद्योगिक क्षेत्र',[-2350,-4750],'colony'),('Crazy Coffee · VDN','क्रेज़ी कॉफ़ी · विद्याधर नगर', [p[0]+9,p[1]+7],'market')]:
    city['pois']=[a for a in city['pois'] if a['name']!=name]
    city['pois'].append(dict(name=name,hindi=hi,p=point,kind=k))
for a in city['amenities']:
    if a.get('area') == AREA and a.get('source') == 'osm':
        city['buildings']=[b for b in city['buildings'] if b.get('kind') or b.get('service') or math.dist((b['x'],b['z']),a['p'])>math.hypot(b['w'],b['d'])/2+math.hypot(a['w'],a['d'])/2+1]
city['meta']['vdn_import' if AREA == 'VDN' else 'vki_import'] = dict(url=URL,retrieved=str(datetime.date.today()),bbox=BBOX,coverage=AREA + '; missing OSM businesses are not fabricated.',placement='OSM amenity points shifted away from road centerlines for playable footprints; building dimensions artistic.')
city_path.write_text(json.dumps(city,separators=(',',':'),ensure_ascii=False))
print('Imported',len(added),'amenities;', {k:sum(a['kind']==k for a in added) for k in sorted({a['kind'] for a in added})})
print('Total roads',len(city['roads']))
