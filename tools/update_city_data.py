"""Fetch OSM neighborhoods and rebuild the distributable, ODbL game map.
Usage: python tools/update_city_data.py [--refresh]
Requires shapely; originals are cached outside the repository in /tmp/osm-*.json.
World geometry is compressed to 65%; heights and infill buildings are artistic.
"""
import json, math, pathlib, random, sys, urllib.request, xml.etree.ElementTree as ET
from shapely.geometry import LineString, Polygon, Point, box
from shapely.strtree import STRtree
from shapely import union_all
ROOT=pathlib.Path(__file__).resolve().parents[1]
AREAS={'ridge':(75.795,26.956,75.85,26.985),'shastri':(75.77,26.936,75.808,26.952),'chandpole':(75.787,26.917,75.818,26.944),'vdn':(75.765,26.945,75.805,26.982),'nahargarh':(75.807,26.933,75.837,26.965)}
SCALE=.65
ORIGIN=(26.9267,75.8085)
def xy(g):return [round((g['lon']-ORIGIN[1])*99100*SCALE,2),round(-(g['lat']-ORIGIN[0])*111320*SCALE,2)]
all_ways={}
for name,bbox in AREAS.items():
 cache=pathlib.Path('/tmp/osm-'+name+'.json')
 if '--refresh' in sys.argv or not cache.exists():
  url='https://api.openstreetmap.org/api/0.6/map?bbox='+','.join(map(str,bbox))
  data=ET.fromstring(urllib.request.urlopen(url,timeout=90).read());nodes={n.attrib['id']:{'lat':float(n.attrib['lat']),'lon':float(n.attrib['lon'])} for n in data.findall('node')};ways=[]
  for w in data.findall('way'):
   tags={t.attrib['k']:t.attrib['v'] for t in w.findall('tag')}
   if any(t in tags for t in ['highway','building','leisure']):ways.append({'id':int(w.attrib['id']),'tags':tags,'geometry':[nodes[n.attrib['ref']] for n in w.findall('nd') if n.attrib['ref'] in nodes]})
  cache.write_text(json.dumps({'elements':ways}))
 all_ways.update({e['id']:e for e in json.loads(cache.read_text())['elements']})
roads=[];road_shapes=[];parks=[];buildings=[];bounds=box(-2900,-4200,2100,750)
widths={'trunk':18,'primary':15,'secondary':12,'tertiary':10,'residential':6,'living_street':5,'unclassified':7,'pedestrian':5,'service':4,'footway':2.5,'path':2.5,'steps':2.5,'track':3}
for e in all_ways.values():
 t=e['tags'];pts=[xy(g) for g in e['geometry']]
 if len(pts)<2:continue
 kind=t.get('highway','').replace('_link','')
 if kind in widths:
  line=LineString(pts).simplify(1.0)
  if not line.intersects(bounds) or line.length<3:continue
  pts=[[round(x,2),round(y,2)] for x,y in line.coords]
  w=widths[kind]
  roads.append({'id':e['id'],'name':t.get('name',''),'kind':kind,'width':w,'p':pts})
  road_shapes.append(line.buffer(w/2+1.0))
 elif 'leisure' in t and t['leisure'] in ['park','garden','playground'] and len(pts)>3:
  poly=Polygon(pts).buffer(0)
  if poly.area>50 and poly.area<100000:parks.append({'name':t.get('name','Neighborhood park'),'p':pts})
# A clearly tagged fictional connector joins the fort access road to the city
# within the playable boundary; the real motor route leaves the imported area.
connector={'id':-80001,'name':'Fort access connector (game)','source':'authored','kind':'tertiary','width':8,'p':[[516,-879],[500,-896],[486,-886]]}
roads.append(connector)
road_shapes.append(LineString(connector['p']).buffer(5))
road_index=STRtree(road_shapes)
park_shapes=[Polygon(p['p']).buffer(0) for p in parks]
park_index=STRtree(park_shapes)
rng=random.Random(261105)
# Road-aware oriented footprints. OSM geometry is retained separately in the manifest.
def clear(poly):
 return bounds.contains(poly) and not any(road_shapes[int(i)].intersects(poly) for i in road_index.query(poly)) and not any(park_shapes[int(i)].intersects(poly) for i in park_index.query(poly))
occupied={}
def add_building(x,z,w,d,angle,height,source,osm_id=0):
 # Four corners; keep room for pavements and crossroads.
 ca,sa=math.cos(angle),math.sin(angle)
 poly=Polygon([(x+ca*a+sa*b,z-sa*a+ca*b) for a,b in [(-w/2,-d/2),(w/2,-d/2),(w/2,d/2),(-w/2,d/2)]])
 if not clear(poly):return False
 cells=[(a,b) for a in range(int(poly.bounds[0]//30),int(poly.bounds[2]//30)+1) for b in range(int(poly.bounds[1]//30),int(poly.bounds[3]//30)+1)]
 if any(p.intersects(poly) for c in cells for p in occupied.get(c,[])):return False
 for c in cells:occupied.setdefault(c,[]).append(poly.buffer(.5))
 buildings.append({'x':round(x,2),'z':round(z,2),'w':round(w,2),'d':round(d,2),'a':round(angle,4),'h':height,'source':source,'osm_id':osm_id})
 return True
for e in all_ways.values():
 if 'building' not in e['tags'] or len(e['geometry'])<4:continue
 poly=Polygon([xy(g) for g in e['geometry']]).buffer(0)
 if poly.area<14 or poly.area>5000:continue
 r=poly.minimum_rotated_rectangle;corners=list(r.exterior.coords)
 a,b,c=corners[:3];w=math.dist(a,b);d=math.dist(b,c)
 if min(w,d)<3:continue
 angle=-math.atan2(b[1]-a[1],b[0]-a[0]);x,z=r.centroid.coords[0]
 try:h=min(24,max(5,float(e['tags'].get('building:levels',rng.choice([2,2,3,4])))*3))
 except ValueError:h=8
 add_building(x,z,w*.92,d*.92,angle,h,'osm',e['id'])
# Add plausible street-facing shop/house plots where OSM footprints are missing.
for road in roads:
 if road['kind'] in ['path','footway','steps','track','service']:continue
 line=LineString(road['p'])
 for s in range(12,int(line.length)-8,30):
  point=line.interpolate(s);nextp=line.interpolate(min(line.length,s+1));dx=nextp.x-point.x;dz=nextp.y-point.y;l=math.hypot(dx,dz)
  if l<.01:continue
  dx/=l;dz/=l
  for side in [-1,1]:
   w=rng.uniform(7,12);d=rng.uniform(7,12);offset=road['width']/2+3+d/2
   x=point.x-dz*offset*side;z=point.y+dx*offset*side
   if x>450 and z<-600:continue # keep the hill slopes open
   add_building(x,z,w,d,-math.atan2(dz,dx),rng.choice([6,7,9,10,12,15]),'infill')
landmarks=[('Chandpole Gate','चाँदपोल गेट',26.9267,75.8085,'gate'),('Chandpole Bazaar','चाँदपोल बाज़ार',26.9257,75.8136,'bazaar'),('Vidhyadhar Nagar','विद्याधर नगर',26.9646,75.7830,'colony'),('Central Spine','सेंट्रल स्पाइन',26.9660,75.7838,'market'),('Sikar Road','सीकर रोड',26.95858,75.77137,'boulevard'),('Nahargarh Fort','नाहरगढ़ किला',26.9372,75.8155,'fort'),('Brahmpuri','ब्रह्मपुरी',26.9420,75.826,'village'),('Shastri Nagar','शास्त्री नगर',26.9422,75.797,'colony')]
pois=[{'name':n,'hindi':hi,'p':xy({'lat':lat,'lon':lon}),'kind':k} for n,hi,lat,lon,k in landmarks]
output={'meta':{'source':'© OpenStreetMap contributors','license':'ODbL-1.0','url':'https://www.openstreetmap.org/copyright','retrieved':'2026-11-05','origin':ORIGIN,'scale':SCALE,'bounds':[-2900,-4200,2100,750],'note':'Road geometry from OSM; generated infill, building heights and terrain are artistic. Not a surveyed reconstruction.'},'roads':roads,'buildings':buildings,'parks':parks,'pois':pois}
# Node road intersections after simplification so turns are actually routable.
network=union_all([LineString(r['p']) for r in roads if r['width']>=5],grid_size=1.0)
output['navigation']=[[[round(x,1),round(z,1)] for x,z in line.coords] for line in network.geoms if line.length>0.5]
path=ROOT/'assets/data/jaipur_city.json' ;path.write_text(json.dumps(output,separators=(',',':')))
print('MAP',len(roads),'road ways,',len(buildings),'buildings,',len(parks),'parks,',path.stat().st_size,'bytes')
