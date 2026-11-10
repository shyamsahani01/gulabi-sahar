#!/usr/bin/env python3
"""Reproducible VKI/VDN crop of the archived OSM-derived city (no network).
Coordinates retain the source's 0.65 geographic scale; runtime applies 0.88.
Clip lines at the boundary, never join disconnected pieces across the crop.
"""
import copy
import json
import math
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOUNDS = (-2850.0, -5100.0, -900.0, -2350.0)

def inside(p, margin=0):
    x0,z0,x1,z1=BOUNDS
    return x0+margin<=p[0]<=x1-margin and z0+margin<=p[1]<=z1-margin

def segment(a,b):
    x0,z0,x1,z1=BOUNDS
    dx,dz=b[0]-a[0],b[1]-a[1]
    lo,hi=0.,1.
    for p,q in [(-dx,a[0]-x0),(dx,x1-a[0]),(-dz,a[1]-z0),(dz,z1-a[1])]:
        if abs(p)<1e-10:
            if q<0: return None
        elif p<0: lo=max(lo,q/p)
        else: hi=min(hi,q/p)
    if lo>=hi: return None
    return [[round(a[0]+t*dx,3),round(a[1]+t*dz,3)] for t in (lo,hi)]

def lines(points):
    result,current=[],[]
    for a,b in zip(points,points[1:]):
        clipped=segment(a,b)
        if clipped:
            p,q=clipped
            if current and current[-1]!=p:
                result.append(current); current=[]
            if not current: current=[p]
            current.append(q)
        elif current:
            result.append(current); current=[]
    if current: result.append(current)
    return result

def footprint(b):
    c,s=abs(math.cos(b['a'])),abs(math.sin(b['a']))
    ex,ez=(c*b['w']+s*b['d'])/2+3,(s*b['w']+c*b['d'])/2+3
    return inside((b['x']-ex,b['z']-ez)) and inside((b['x']+ex,b['z']+ez))

def add_infill(out):
    """Deterministic artistic roadside parcels; SAT keeps roads/parks unobstructed."""
    grid={}
    def polygon(x,z,w,d,a,pad=0):
        c,s=math.cos(a),math.sin(a)
        return [(x+c*px+s*pz,z-s*px+c*pz) for px,pz in [(-w/2-pad,-d/2-pad),(w/2+pad,-d/2-pad),(w/2+pad,d/2+pad),(-w/2-pad,d/2+pad)]]
    def cells(poly):
        return [(x,z) for x in range(math.floor(min(p[0] for p in poly)/64),math.floor(max(p[0] for p in poly)/64)+1) for z in range(math.floor(min(p[1] for p in poly)/64),math.floor(max(p[1] for p in poly)/64)+1)]
    def insert(poly):
        for cell in cells(poly): grid.setdefault(cell,[]).append(poly)
    def overlaps(a,b):
        for poly in (a,b):
            for p,q in zip(poly,poly[1:]+poly[:1]):
                axis=(q[1]-p[1],p[0]-q[0])
                pa=[v[0]*axis[0]+v[1]*axis[1] for v in a]
                pb=[v[0]*axis[0]+v[1]*axis[1] for v in b]
                if max(pa)<min(pb) or max(pb)<min(pa): return False
        return True
    for b in out['buildings']: insert(polygon(b['x'],b['z'],b['w'],b['d'],b['a'],2))
    for a in out['amenities']: insert(polygon(*a['p'],a['w'],a['d'],a['a'],3))
    for p in out['parks']:
        x0,z0=min(q[0] for q in p['p']),min(q[1] for q in p['p'])
        x1,z1=max(q[0] for q in p['p']),max(q[1] for q in p['p'])
        insert(polygon((x0+x1)/2,(z0+z1)/2,x1-x0,z1-z0,0,2))
    for road in out['roads']:
        for a,b in zip(road['p'],road['p'][1:]):
            dx,dz=b[0]-a[0],b[1]-a[1]
            insert(polygon((a[0]+b[0])/2,(a[1]+b[1])/2,math.hypot(dx,dz),road['width'],math.atan2(-dz,dx),2))
    rng=random.Random(101126)
    count=0
    for road in out['roads']:
        if road['kind'] not in ('residential','unclassified','tertiary','secondary','primary','service'): continue
        for a,b in zip(road['p'],road['p'][1:]):
            dx,dz=b[0]-a[0],b[1]-a[1]
            length=math.hypot(dx,dz)
            if length<20: continue
            angle=math.atan2(-dz,dx)
            for distance in range(14,int(length)-8,25):
                t=distance/length
                industrial=a[1]+t*dz< -3650
                width=rng.uniform(16,25) if industrial else rng.uniform(12,19)
                depth=rng.uniform(18,30) if industrial else rng.uniform(12,18)
                for side in (-1,1):
                    offset=road['width']/2+depth/2+4.2
                    x=a[0]+t*dx-side*dz/length*offset
                    z=a[1]+t*dz+side*dx/length*offset
                    poly=polygon(x,z,width,depth,angle,1.5)
                    if not all(inside(q,3) for q in poly): continue
                    tested=set()
                    blocked=False
                    for cell in cells(poly):
                        for other in grid.get(cell,[]):
                            if id(other) in tested: continue
                            tested.add(id(other))
                            if overlaps(poly,other): blocked=True; break
                        if blocked: break
                    if blocked: continue
                    out['buildings'].append(dict(x=round(x,2),z=round(z,2),w=round(width,2),d=round(depth,2),a=round(angle,4),h=rng.choice([5,6,7,8] if industrial else [6,9,12]),source='infill',osm_id=0,provenance='compact-artistic-infill'))
                    insert(poly)
                    count+=1
    print('Added artistic roadside buildings:',count)

def build():
    source=json.loads((ROOT/'assets/data/jaipur_city.json').read_text())
    out=copy.deepcopy(source)
    out['roads']=[]
    for road in source['roads']:
        for line in lines(road['p']):
            out['roads'].append(dict(road,p=line))
    out['navigation']=[line for road in source['navigation'] for line in lines(road)]
    out['buildings']=[b for b in out['buildings'] if footprint(b)]
    out['amenities']=[a for a in out['amenities'] if footprint(dict(x=a['p'][0],z=a['p'][1],w=a['w'],d=a['d'],a=a['a']))]
    # Existing parks all lie inside this crop; omit partial polygons rather than
    # turn a boundary-crossing park into a self-intersecting polygon.
    out['parks']=[p for p in out['parks'] if all(inside(q) for q in p['p'])]
    add_infill(out)
    names=['Vidhyadhar Nagar','Central Spine','VKI South','Crazy Cafe · VDN']
    out['pois']=[next(p for p in out['pois'] if p['name']==name) for name in names]
    park=next(p for p in out['parks'] if p['name']=='Smriti Park')
    out['pois'].append(dict(name='Smriti Park',hindi='स्मृति पार्क',kind='park',p=park['p'][0]))
    # Keep enterable dining in the smaller world. Fictional names/provenance,
    # using three existing infill footprints, never moving a real restaurant.
    for design_style,(name,at) in enumerate([('Gulabi Thali · VDN',(-1650,-2780)),('Spine Garden Kitchen',(-1700,-3000)),('VKI Canteen',(-2350,-4630))]):
        candidates=[b for b in out['buildings'] if b.get('source')=='infill' and not b.get('kind') and b['w']>=9 and b['d']>=8]
        b=min(candidates,key=lambda b:(b['x']-at[0])**2+(b['z']-at[1])**2)
        b['kind']='restaurant'
        out['amenities'].append(dict(name=name,hindi='',kind='restaurant',p=[b['x'],b['z']],a=b['a'],w=b['w'],d=b['d'],front=1,source='authored',design_style=design_style,tags={'amenity':'restaurant'},osm_id=-92000-len(out['amenities'])))
    out['meta']['playable_bounds']=list(BOUNDS)
    out['meta']['edition']='vki-vdn-compact-v1'
    out['meta']['playable_note']='VKI South and Vidhyadhar Nagar only. Clipped original road geometry. Three fictional restaurants occupy existing infill plots; the archived Jaipur source is unchanged.'
    out['meta']['spawn_hint']=[-1591.05,-2843.67]
    target=ROOT/'assets/data/vki_vdn_city.json'
    target.write_text(json.dumps(out,ensure_ascii=False,separators=(',',':'))+'\n')
    print({k:len(out[k]) for k in ('roads','buildings','parks','pois','amenities','navigation')})
    print('Playable metres:',(BOUNDS[2]-BOUNDS[0])*.88,(BOUNDS[3]-BOUNDS[1])*.88)

if __name__=='__main__': build()
