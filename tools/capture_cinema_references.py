"""Reference-only Maps page captures of Cinestar and Funstar / Times Square Mall."""
from pathlib import Path
import hashlib,json,re,math
from playwright.sync_api import sync_playwright
from capture_sector2_refs import ROOT
from capture_sector2_nearby import reframe
OUT=ROOT/'cinema-area'

def main():
 probes=json.loads((OUT/'panorama-probes.json').read_text())
 sites=[{'name':'cinestar','base':probes[0]['panorama_url'],'lat':26.9649688,'lon':75.7814471,'front':35},
        {'name':'funstar','base':(OUT/'funstar-photo-url.txt').read_text(),'lat':26.9605303,'lon':75.7786635,'front':240}]
 destmanifest=OUT/'captures.json'
 manifest=json.loads(destmanifest.read_text()) if destmanifest.exists() else {'capture_date':'2026-11-15','method':'Headed Google Chrome, direct page screenshots, 1920x1080','scope':'Cinestar Multiplex and Funstar / Times Square Mall area. Observed exterior only; interiors not inferred.','sites':sites,'images':[]}
 with sync_playwright() as p:
  browser=p.chromium.launch(executable_path='/opt/google/chrome/chrome',headless=False,args=['--no-sandbox','--ozone-platform=x11'])
  page=browser.new_page(viewport={'width':1920,'height':1080})
  def capture(name,url,site,kind):
   dest=OUT/site/(name+'.png');dest.parent.mkdir(exist_ok=True)
   if any(i['file']==str(dest.relative_to(ROOT)) for i in manifest['images']):return
   page.goto(url,wait_until='domcontentloaded',timeout=60000);page.wait_for_timeout(5500)
   body=page.locator('body').inner_text()
   if 'Image capture:' not in body or 'No Street View imagery' in body:
    page.wait_for_timeout(5000);body=page.locator('body').inner_text()
   if 'Image capture:' not in body or 'No Street View imagery' in body:raise RuntimeError('Imagery missing '+name)
   page.mouse.move(1800,20);page.screenshot(path=str(dest))
   match=re.search(r'/@(-?[\d.]+),(-?[\d.]+)',page.url)
   manifest['images'].append({'file':str(dest.relative_to(ROOT)),'site':site,'kind':kind,'source_url':url,'resolved_url':page.url,'panorama_id':re.search(r'!1s([^!]+)',page.url).group(1),'camera_coordinates':[float(v) for v in match.groups()] if match else None,'sha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'visible_attribution':body[body.find('Image capture:'):].strip(),'review_status':'awaiting_visual_review'})
   destmanifest.write_text(json.dumps(manifest,indent=2)+'\n')
   print('CAPTURE',site,name,flush=True)
  for site in sites:
   name=site['name'];base=site['base'];front=site['front']
   for h in range(0,360,30):capture(f'wide-{h:03d}',reframe(base,h),name,'360-degree directional view')
   for h in [front-25,front,front+25]:
    capture(f'entrance-{h:03d}',reframe(base,h,50,90),name,'Closer facade and entrance')
    capture(f'upper-{h:03d}',reframe(base,h,60,112),name,'Upper facade, roof and signage')
   for station,heading in [('approach-east',90),('approach-west',270)]:
    page.goto(reframe(base,heading),wait_until='domcontentloaded');page.wait_for_timeout(6500)
    original_id=re.search(r'!1s([^!]+)',page.url).group(1)
    for step in range(2):
     page.mouse.dblclick(1000,680,delay=120);page.wait_for_timeout(4500)
    url=page.url
    if re.search(r'!1s([^!]+)',url).group(1)==original_id:
     print('SKIP unchanged approach',name,station,flush=True);continue
    match=re.search(r'/@(-?[\d.]+),(-?[\d.]+)',url)
    lat,lon=map(float,match.groups())
    bearing=round(math.degrees(math.atan2((site['lon']-lon)*math.cos(math.radians(lat)),site['lat']-lat)))%360
    for delta in range(-45,315,45):
     h=(bearing+delta)%360
     capture(f'{station}-{h:03d}',reframe(url,h),name,'Alternate actual Street View position; view toward place or approach road')
  browser.close()
 print('DONE',len(manifest['images']),'cinema-area photographs',flush=True)
if __name__=='__main__':main()
