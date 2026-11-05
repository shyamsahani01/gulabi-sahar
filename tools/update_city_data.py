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
all_ways={};all_places={}
for name,bbox in AREAS.items():
 cache=pathlib.Path('/tmp/osm-'+name+'.json')
 if '--refresh' in sys.argv or not cache.exists():
  url='https://api.openstreetmap.org/api/0.6/map?bbox='+','.join(map(str,bbox))
  data=ET.fromstring(urllib.request.urlopen(url,timeout=90).read());nodes={n.attrib['id']:{'lat':float(n.attrib['lat']),'lon':float(n.attrib['lon'])} for n in data.findall('node')};ways=[];places=[]
  # Real amenities (police, hospitals, showrooms, thekas, fuel, schools...) are kept as point features.
  for n in data.findall('node'):
   tags={t.attrib['k']:t.attrib['v'] for t in n.findall('tag')}
   if any(t in tags for t in ['amenity','shop','healthcare','tourism','office']):places.append({'id':int(n.attrib['id']),'tags':tags,'geometry':[nodes[n.attrib['id']]]})
  for w in data.findall('way'):
   tags={t.attrib['k']:t.attrib['v'] for t in w.findall('tag')}
   geometry=[nodes[n.attrib['ref']] for n in w.findall('nd') if n.attrib['ref'] in nodes]
   if any(t in tags for t in ['highway','building','leisure']):ways.append({'id':int(w.attrib['id']),'tags':tags,'geometry':geometry})
   if (any(t in tags for t in ['amenity','shop','healthcare','tourism','office']) or any(k in tags.get('name','').lower() for k in ['police','hospital','showroom','thana'])) and geometry:places.append({'id':int(w.attrib['id']),'tags':tags,'geometry':geometry})
  cache.write_text(json.dumps({'elements':ways,'places':places}))
 cached=json.loads(cache.read_text())
 if 'places' not in cached:
  print('cache',cache,'has no places; rerun with --refresh');sys.exit(1)
 all_ways.update({e['id']:e for e in cached['elements']})
 all_places.update({e['id']:e for e in cached['places']})
roads=[];road_shapes=[];parks=[];buildings=[];bounds=box(-2600,-3500,1600,650)
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
# Classify real amenities into the typed landmark buildings the game knows how to build.
name=lambda t:t.get('name','').lower()
KINDS=[('police',lambda t:t.get('amenity')=='police' or 'police station' in name(t) or 'thana' in name(t)),('showroom',lambda t:t.get('shop') in ['car','motorcycle'] or 'showroom' in name(t)),('hospital',lambda t:t.get('amenity') in ['hospital','clinic'] or t.get('healthcare') in ['hospital','clinic'] or 'hospital' in name(t)),('pharmacy',lambda t:t.get('amenity')=='pharmacy' or t.get('shop')=='chemist' or t.get('healthcare')=='pharmacy'),('showroom',lambda t:t.get('shop') in ['car','motorcycle']),('theka',lambda t:t.get('shop')=='alcohol'),('fuel',lambda t:t.get('amenity')=='fuel'),('bank',lambda t:t.get('amenity') in ['bank','atm']),('school',lambda t:t.get('amenity') in ['school','college','university']),('temple',lambda t:t.get('amenity')=='place_of_worship'),('restaurant',lambda t:t.get('amenity') in ['restaurant','cafe','fast_food']),('shop',lambda t:'shop' in t)]
SIZES={'police':(30,22),'hospital':(42,26),'pharmacy':(9,8),'showroom':(34,20),'theka':(7,5),'fuel':(28,18),'bank':(14,10),'school':(36,24),'temple':(16,16),'restaurant':(12,9),'shop':(8,7)}
LIMIT={'shop':60,'restaurant':40,'bank':30,'temple':30,'pharmacy':30,'school':25}
amenities=[];counts={}
for e in all_places.values():
 t=e['tags'];pts=[xy(g) for g in e['geometry']]
 kind=next((k for k,f in KINDS if f(t)),None)
 if not kind:continue
 if counts.get(kind,0)>=LIMIT.get(kind,999):continue
 cx=sum(p[0] for p in pts)/len(pts);cz=sum(p[1] for p in pts)/len(pts)
 if not bounds.contains(Point(cx,cz)):continue
 if any(a['kind']==kind and math.dist(a['p'],(cx,cz))<40 for a in amenities):continue
 if kind=='hospital' and t.get('amenity')=='clinic' and len(pts)==1:w,d=(16,12)
 else:w,d=SIZES[kind]
 # Face the nearest road.
 near=road_index.query(Point(cx,cz).buffer(60))
 angle=0.0;best=1e9;rx=cx;rz=cz
 for i in near:
  r=roads[int(i)];line=LineString(r['p']);dd=line.distance(Point(cx,cz))
  if dd<best:
   best=dd;q=line.interpolate(line.project(Point(cx,cz)));q2=line.interpolate(min(line.length,line.project(Point(cx,cz))+1));angle=-math.atan2(q2.y-q.y,q2.x-q.x);rx,rz=q.x,q.y
 if best>70:continue
 nx,nz=cx-rx,cz-rz;l=math.hypot(nx,nz)
 if l<1:nx,nz=math.sin(-angle),math.cos(-angle);l=1
 nx/=l;nz/=l;rw=roads[int(min(near,key=lambda i:LineString(roads[int(i)]['p']).distance(Point(cx,cz))))]['width'] if len(near) else 8
 placed=False
 # Dense old-city plots: shrink the footprint and slide it back from the road until it fits.
 for scale in [1.0,.85,.7,.55,.45]:
  for extra in [0,5,10,16]:
   ww,dd=w*scale,d*scale
   offset=rw/2+3+dd/2+extra;px,pz=rx+nx*offset,rz+nz*offset
   if add_building(px,pz,ww,dd,angle,{'police':9,'hospital':18,'pharmacy':6,'showroom':9,'theka':3.6,'fuel':6,'bank':9,'school':10,'temple':9,'restaurant':7,'shop':6}[kind],'amenity',e['id']):
    buildings[-1]['kind']=kind
    # Which local depth side (+/-z in the game's Basis(UP,a) frame) faces the road.
    ca,sa=math.cos(angle),math.sin(angle);front=1 if sa*(rx-px)+ca*(rz-pz)>0 else -1
    amenities.append({'name':t.get('name',''),'hindi':t.get('name:hi',''),'kind':kind,'p':[round(px,2),round(pz,2)],'a':round(angle,4),'w':round(ww,2),'d':round(dd,2),'front':front,'osm_id':e['id'],'tags':{k:t[k] for k in ['amenity','shop','brand','operator','healthcare','religion'] if k in t}})
    counts[kind]=counts.get(kind,0)+1;placed=True;break
  if placed:break
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
output={'amenities':amenities,'meta':{'source':'© OpenStreetMap contributors','license':'ODbL-1.0','url':'https://www.openstreetmap.org/copyright','retrieved':'2026-11-05','origin':ORIGIN,'scale':SCALE,'bounds':[-2600,-3500,1600,650],'note':'Road geometry from OSM; generated infill, building heights and terrain are artistic. Not a surveyed reconstruction.'},'roads':roads,'buildings':buildings,'parks':parks,'pois':pois}
# Node road intersections after simplification so turns are actually routable.
network=union_all([LineString(r['p']) for r in roads if r['width']>=5],grid_size=1.0)
output['navigation']=[[[round(x,1),round(z,1)] for x,z in line.coords] for line in network.geoms if line.length>0.5]
path=ROOT/'assets/data/jaipur_city.json' ;path.write_text(json.dumps(output,separators=(',',':')))
print('MAP',len(roads),'road ways,',len(buildings),'buildings,',len(parks),'parks,',len(amenities),'amenities',counts,path.stat().st_size,'bytes')
