from pathlib import Path
import json,html
ROOT=Path(__file__).resolve().parents[1]/'designs/17-sector-2-central-spine'
def build():
 m=json.loads((ROOT/'captures.json').read_text())
 images=m['images']
 cinema=ROOT/'cinema-area/captures.json'
 if cinema.exists():images+=json.loads(cinema.read_text())['images']
 cards=''.join('<a class="card" href="'+html.escape(x['file'])+'" target="_blank"><img loading="eager" src="'+html.escape(x['file'])+'"><span>'+html.escape(x.get('site','Sector 2')+' / '+Path(x['file']).stem)+'</span></a>' for x in images)
 page='''<!doctype html><meta charset="utf-8"><title>Gulabi Sahar — street photo references</title><style>body{background:#16222a;color:#edf2f4;font:14px system-ui;margin:16px}h1{font-size:22px;margin:4px 0}p{margin:6px 0 14px}main{display:grid;grid-template-columns:repeat(4,1fr);gap:10px}.card{display:block;color:inherit;text-decoration:none;background:#253640;border-radius:5px;overflow:hidden}.card img{display:block;width:100%;aspect-ratio:16/9;object-fit:contain;background:#0b151c}.card span{display:block;padding:5px 8px;font-size:12px}</style><h1>Central Spine / Sector 2 — Google Maps reference photographs</h1><p>Actual Maps page captures, © Google and attributed contributors. Click any image for full resolution. Reference study only; not game textures.</p><main>'''+cards+'''</main><script>const p=new URLSearchParams(location.search).get('page');if(p!==null)document.querySelectorAll('.card').forEach((e,i)=>{if(Math.floor(i/16)!==Number(p))e.remove()})</script>'''
 (ROOT/'reference-gallery.html').write_text(page)
 print(len(images),'gallery photographs')
if __name__=='__main__':build()
