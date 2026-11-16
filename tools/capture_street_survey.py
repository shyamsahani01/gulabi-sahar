"""Capture a verified Street View station plan, keeping originals local.

Usage: xvfb-run -a <playwright-python> tools/capture_street_survey.py <plan.json>
The plan contains capture_date, street_id, title, and stations with name/url.
Each station gets eight overlapping 75-degree views around the full horizon.
Review the photographs before setting review_status or modeling the street.
"""
import hashlib
import html
import json
import re
import sys
from pathlib import Path
from playwright.sync_api import sync_playwright


def reframe(url, heading, tilt=90, fov=75):
    url = re.sub(r'(/@-?[\d.]+,-?[\d.]+,)[^/]+/data=',
                 rf'\g<1>3a,{fov}y,{heading}h,{tilt}t/data=', url)
    url = re.sub(r'yaw%3D[-\d.]+', f'yaw%3D{heading}', url)
    return re.sub(r'pitch%3D[-\d.]+', f'pitch%3D{90-tilt}', url)


def gallery(root, manifest):
    cards = ''.join(
        '<a href="' + html.escape(x['file']) + '"><img src="' + html.escape(x['file'])
        + '"><span>' + html.escape(Path(x['file']).stem) + '</span></a>'
        for x in manifest['images'])
    page = '''<!doctype html><meta charset="utf-8"><title>Street survey</title>
<style>body{background:#16222a;color:#edf2f4;font:14px system-ui;margin:16px}
h1{font-size:22px}main{display:grid;grid-template-columns:repeat(4,1fr);gap:10px}
a{display:block;color:inherit;text-decoration:none;background:#253640}img{width:100%;display:block}span{display:block;padding:6px}</style>
<h1>''' + html.escape(manifest['title']) + '''</h1><p>Actual Google Maps page photographs; attribution retained. Local references, not exported game textures. Click for original.</p><main>''' + cards + '''</main>
<script>const p=new URLSearchParams(location.search).get('page');if(p!==null)document.querySelectorAll('main>a').forEach((e,i)=>{if(Math.floor(i/16)!==Number(p))e.remove()})</script>'''
    (root / 'reference-gallery.html').write_text(page)


def main():
    plan_file = Path(sys.argv[1]).resolve()
    plan = json.loads(plan_file.read_text())
    root = plan_file.parent
    refs = root / 'references'
    refs.mkdir(exist_ok=True)
    (refs / '.gdignore').touch()
    manifest_file = root / 'captures.json'
    manifest = json.loads(manifest_file.read_text()) if manifest_file.exists() else {
        'capture_date': plan['capture_date'], 'street_id': plan['street_id'],
        'title': plan['title'], 'method': 'Headed Google Chrome, direct 1920x1080 page screenshots',
        'images': []}
    with sync_playwright() as p:
        browser = p.chromium.launch(executable_path='/opt/google/chrome/chrome', headless=False,
                                    args=['--no-sandbox', '--ozone-platform=x11'])
        page = browser.new_page(viewport={'width': 1920, 'height': 1080})
        for station in plan['stations']:
            expected = re.search(r'!1s([^!]+)', station['url']).group(1)
            for heading in range(0, 360, 45):
                dest = refs / f'{station["name"]}-{heading:03d}.png'
                relative = str(dest.relative_to(root))
                existing = next((i for i in manifest['images'] if i['file'] == relative), None)
                if existing and dest.exists() and hashlib.sha256(dest.read_bytes()).hexdigest() == existing['sha256']:
                    continue
                url = reframe(station['url'], heading)
                page.goto(url, wait_until='domcontentloaded', timeout=60000)
                page.wait_for_timeout(6000)
                body = page.locator('body').inner_text()
                if 'Image capture:' not in body or 'No Street View imagery' in body:
                    page.wait_for_timeout(6000)
                    body = page.locator('body').inner_text()
                match = re.search(r'!1s([^!]+)', page.url)
                if 'Image capture:' not in body or 'No Street View imagery' in body or not match or match.group(1) != expected:
                    raise RuntimeError(f'Missing or wrong panorama: {relative}')
                coordinate = re.search(r'/@(-?[\d.]+),(-?[\d.]+)', page.url)
                page.mouse.move(1800, 20)
                page.screenshot(path=str(dest))
                item = {'file': relative, 'station': station['name'], 'heading_degrees': heading,
                        'panorama_id': expected, 'coordinates': list(map(float, coordinate.groups())),
                        'source_url': url, 'resolved_url': page.url,
                        'sha256': hashlib.sha256(dest.read_bytes()).hexdigest(),
                        'visible_attribution': body[body.index('Image capture:'):],
                        'review_status': 'awaiting_visual_review'}
                manifest['images'] = [i for i in manifest['images'] if i['file'] != relative] + [item]
                manifest_file.write_text(json.dumps(manifest, indent=2) + '\n')
                gallery(root, manifest)
                print('CAPTURE', relative, flush=True)
        browser.close()
    print('DONE', len(manifest['images']), 'photographs', flush=True)


if __name__ == '__main__':
    main()
