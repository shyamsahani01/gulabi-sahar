"""Additional reference captures reached through normal Street View road navigation."""
import hashlib,json,re
from pathlib import Path
from playwright.sync_api import sync_playwright
from capture_sector2_refs import ROOT,REFS,view_url

def reframe(url,h,fov=75,tilt=90):
 url=re.sub(r',[\d.]+y,[\d.]+h,[\d.]+t',f',{fov}y,{h}h,{tilt}t',url)
 url=re.sub(r'yaw%3D[-\d.]+',f'yaw%3D{h}',url)
 return re.sub(r'pitch%3D[-\d.]+',f'pitch%3D{90-tilt}',url)

def main():
 m=json.loads((ROOT/'captures.json').read_text())
 with sync_playwright() as p:
  b=p.chromium.launch(executable_path='/opt/google/chrome/chrome',headless=False,args=['--no-sandbox','--ozone-platform=x11'])
  page=b.new_page(viewport={'width':1920,'height':1080})
  stations=[]
  for name,heading,steps in [('north-near',30,1),('north-far',30,4),('south-near',210,2)]:
   page.goto(view_url(heading),wait_until='domcontentloaded');page.wait_for_timeout(6500)
   for step in range(steps):
    previous=page.url
    page.mouse.dblclick(1000,680,delay=120);page.wait_for_timeout(4500)
    if page.url==previous:break
   pano=re.search(r'!1s([^!]+)',page.url).group(1)
   if pano=='svgpKyn-Fi_8G2MTKzTZbQ' or any(pano==s['pano'] for s in stations):
    print('SKIP unchanged/duplicate station',name,flush=True);continue
   stations.append({'name':name,'url':page.url,'pano':pano})
   print('STATION',name,page.url[:140],flush=True)
  (ROOT/'nearby-stations.json').write_text(json.dumps(stations,indent=2)+'\n')
  plan=[(f'{s["name"]}-{h:03d}',reframe(s['url'],h),h,s['pano']) for s in stations for h in range(0,360,45)]
  plan += [(f'shop-close-{h:03d}',view_url(h,55,112),h,'svgpKyn-Fi_8G2MTKzTZbQ') for h in [60,90,120,150]]
  for name,url,h,pano in plan:
   dest=REFS/(name+'.png')
   if dest.exists():continue
   page.goto(url,wait_until='domcontentloaded',timeout=60000);page.wait_for_timeout(5500)
   body=page.locator('body').inner_text()
   if 'Image capture:' not in body or 'No Street View imagery' in body:
    page.wait_for_timeout(6000);body=page.locator('body').inner_text()
   if 'Image capture:' not in body or 'No Street View imagery' in body:raise RuntimeError('Street View missing '+name)
   page.mouse.move(1800,20);page.screenshot(path=str(dest))
   m['images'].append({'file':str(dest.relative_to(ROOT)),'heading_degrees':h,'panorama_id':pano,'source_url':url,'resolved_url':page.url,'sha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'visible_attribution':body[body.find('Image capture:'):].strip(),'review_status':'awaiting_visual_review'})
   (ROOT/'captures.json').write_text(json.dumps(m,indent=2)+'\n')
   print('CAPTURE',name,flush=True)
  b.close()
 print('DONE',len(m['images']),'total images',flush=True)
if __name__=='__main__':main()
