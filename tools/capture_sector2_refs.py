"""Capture ordinary, visible Google Chrome Street View pages using Playwright.
Run with a headed Chrome display, for example:
  xvfb-run -a /tmp/gulabi-maps-browser/bin/python tools/capture_sector2_refs.py
Images are local design references, excluded from Android export.
"""
from pathlib import Path
import hashlib,json,re,time
from playwright.sync_api import sync_playwright
ROOT=Path(__file__).resolve().parents[1]/'designs/17-sector-2-central-spine'
REFS=ROOT/'references'
BASE=json.loads((ROOT/'sources.json').read_text())['source_url']

def view_url(heading,fov=75,tilt=90):
    url=re.sub(r'486a,75y,147\.55h,89\.06t',f'3a,{fov}y,{heading}h,{tilt}t',BASE)
    return url.replace('yaw%3D147.54501305384454',f'yaw%3D{heading}').replace('pitch%3D0.9398416899779249',f'pitch%3D{90-tilt}')

def main():
    REFS.mkdir(exist_ok=True)
    manifest=json.loads((ROOT/'captures.json').read_text())
    manifest['automated_method']='Headed Google Chrome; Playwright page screenshots at 1920x1080 on an isolated X display. No desktop or other application content.'
    plan=[(f'wide-{h:03d}',h,75,90) for h in range(0,360,30)]
    plan += [(f'lower-detail-{h:03d}',h,48,72) for h in [30,60,90,120,150,210,270,330]]
    plan += [(f'upper-wide-{h:03d}',h,60,108) for h in [0,90,180,270]]
    with sync_playwright() as p:
        browser=p.chromium.launch(executable_path='/opt/google/chrome/chrome',headless=False,args=['--no-sandbox','--ozone-platform=x11'])
        page=browser.new_page(viewport={'width':1920,'height':1080})
        for name,h,fov,tilt in plan:
            dest=REFS/(name+'.png')
            if dest.exists() and any(x['file']==f'references/{name}.png' for x in manifest['images']):continue
            url=view_url(h,fov,tilt)
            page.goto(url,wait_until='domcontentloaded',timeout=60000)
            page.wait_for_timeout(6500 if manifest['images'] else 12000)
            body=page.locator('body').inner_text()
            if 'No Street View imagery' in body or 'Image capture:' not in body:
                page.wait_for_timeout(8000);body=page.locator('body').inner_text()
            if 'No Street View imagery' in body or 'Image capture:' not in body:
                raise RuntimeError('Street View did not load: '+name+' '+body[:300])
            page.mouse.move(1800,20)
            page.screenshot(path=str(dest))
            manifest['images'].append({'file':str(dest.relative_to(ROOT)),'heading_degrees':h,'requested_fov':fov,'requested_tilt':tilt,'source_url':url,'resolved_url':page.url,'sha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'visible_attribution':body[body.find('Image capture:'):].strip(),'review_status':'awaiting_visual_review'})
            (ROOT/'captures.json').write_text(json.dumps(manifest,indent=2)+'\n')
            print('CAPTURE',name,dest.stat().st_size,flush=True)
        # Follow the actual Street View navigation on the road, keeping resolved
        # panorama URLs. These are distinct nearby viewpoints, not invented pins.
        page.goto(view_url(30),wait_until='domcontentloaded',timeout=60000)
        page.wait_for_timeout(7000)
        for step in range(1,4):
            previous=page.url
            page.keyboard.press('ArrowUp')
            page.wait_for_timeout(6000)
            if page.url==previous:
                print('NEIGHBOR NAVIGATION did not change URL; skipping',flush=True);break
            dest=REFS/f'road-forward-{step:02d}.png'
            page.screenshot(path=str(dest))
            body=page.locator('body').inner_text()
            manifest['images'].append({'file':str(dest.relative_to(ROOT)),'capture_kind':'Street View ArrowUp navigation; position must be verified from resolved URL','resolved_url':page.url,'sha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'visible_attribution':body[body.find('Image capture:'):].strip(),'review_status':'awaiting_visual_review'})
            (ROOT/'captures.json').write_text(json.dumps(manifest,indent=2)+'\n')
            print('CAPTURE',dest.name,flush=True)
        browser.close()
    cards=''.join(f'<figure><img src="{x["file"]}"><figcaption>{Path(x["file"]).stem}</figcaption></figure>' for x in manifest['images'])
    (ROOT/'reference-gallery.html').write_text('<!doctype html><meta charset="utf-8"><title>Sector 2 Street View references</title><style>body{background:#182129;color:white;font:16px sans-serif;margin:20px}main{display:grid;grid-template-columns:repeat(4,1fr);gap:12px}figure{margin:0}img{width:100%}figcaption{padding:5px}</style><h1>Sector 2 / Central Spine — actual Google Street View captures</h1><p>Imagery March 2026. Google attribution retained. Local visual study; excluded from game export.</p><main>'+cards+'</main>')
    print('DONE',len(manifest['images']),'images',flush=True)

if __name__=='__main__':main()
