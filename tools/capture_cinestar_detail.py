"""Supplemental normal-browser Street View screenshots; reference use only."""
from pathlib import Path
import hashlib
import json
import re
from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'designs/21-cinestar-model-study'
BASE = ('https://www.google.com/maps/@26.9646459,75.7815701,487a,{fov}y,{heading}h,{tilt}t/'
        'data=!3m7!1e1!3m5!1st5UWA6t52VJ4QqZTjiXPjg!2e0!6s'
        'https:%2F%2Fstreetviewpixels-pa.clients6.google.com%2Fv1%2Fthumbnail%3F'
        'cb_client%3Dmaps_sv.tactile%26w%3D900%26h%3D600%26pitch%3D{pitch}'
        '%26panoid%3Dt5UWA6t52VJ4QqZTjiXPjg%26yaw%3D{heading}!7i16384!8i8192')

def main():
    ref = OUT / 'references'
    ref.mkdir(parents=True, exist_ok=True)
    manifest = {'capture_date': '2026-11-18', 'method': 'Headed Chrome page screenshots, 1920x1080',
                'scope': 'Four directions from the user-supplied panorama; not four distinct positions or a full survey.', 'images': []}
    with sync_playwright() as p:
        browser = p.chromium.launch(executable_path='/opt/google/chrome/chrome', headless=False,
                                    args=['--no-sandbox', '--ozone-platform=x11'])
        page = browser.new_page(viewport={'width': 1920, 'height': 1080})
        for name, heading, fov, tilt in [('corner', 300, 90, 102), ('gallery', 330, 75, 104),
                                         ('facade', 280, 65, 110), ('forecourt', 20, 85, 90)]:
            url = BASE.format(heading=heading, fov=fov, tilt=tilt, pitch=90-tilt)
            page.goto(url, wait_until='domcontentloaded', timeout=60000)
            page.wait_for_timeout(7000)
            body = page.locator('body').inner_text()
            if 'Image capture:' not in body or 'No Street View imagery' in body:
                raise RuntimeError('Street View not verified: ' + name)
            page.mouse.move(1800, 20)
            dest = ref / (name + '.png')
            page.screenshot(path=str(dest))
            manifest['images'].append({'file': str(dest.relative_to(OUT)), 'source_url': url,
                'resolved_url': page.url, 'panorama_id': re.search(r'!1s([^!]+)', page.url).group(1),
                'sha256': hashlib.sha256(dest.read_bytes()).hexdigest(),
                'visible_attribution': body[body.find('Image capture:'):].strip(),
                'review_status': 'awaiting_visual_review'})
            (OUT / 'captures.json').write_text(json.dumps(manifest, indent=2) + '\n')
            print('CAPTURE', name, flush=True)
        browser.close()

if __name__ == '__main__':
    main()
