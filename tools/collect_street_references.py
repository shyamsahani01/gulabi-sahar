"""Repeatable reference-only downloads; no Google access bypass or invented captures."""
import hashlib, json, io
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import requests
from PIL import Image, ImageOps, ImageDraw
ROOT=Path(__file__).resolve().parents[1]/'designs/16-vki-vdn-streets'
SOURCES=[
 ('01-vki-workshop-lane','street-gates.jpg','https://dyimg2.realestateindia.com/prop_images/3727007/1362940_4.jpg','https://www.realestateindia.com/property-detail/warehouse-godown-for-rent-in-vishwakarma-industrial-area-jaipur-7850-sq-ft-1-25-lac-1362940.htm','VKI listing: boundary gate, road edge and workshop frontage'),
 ('01-vki-workshop-lane','warehouse-frame.jpg','https://dyimg2.realestateindia.com/prop_images/127348/1109394_4.jpg','https://www.realestateindia.com/property-detail/warehouse-godown-for-rent-in-vishwakarma-industrial-area-jaipur-35000-sq-ft-5-60-lac-1109394.htm','VKI listing: steel roof frame and open loading bays'),
 ('01-vki-workshop-lane','loading-bays.jpeg','https://dyimg2.realestateindia.com/prop_images/3739227/1345554_7.jpeg','https://www.realestateindia.com/property-detail/warehouse-godown-for-rent-in-vishwakarma-industrial-area-jaipur-55000-sq-ft-9-94-lac-1345554.htm','VKI listing: roller shutters and forecourt'),
 ('02-vdn-central-spine','commercial-facade.jpeg','https://lscdn.azureedge.net/biz-live/img/11478175-11478175-5e4552e0.jpeg','https://branches.muthootfinance.com/gold-loan-agency-in-vidyadhar-nagar-jaipur-11478175/home','VDN branch photo: stacked signs, jali balconies, shop shutters'),
 ('02-vdn-central-spine','enclave-b11.jpg','https://img.staticmb.com/mbphoto/property/cropped_images/2026/Apr/12/Photo_h600_w900/2026/Apr/12/83684217_3_20260411_140648_600_900.jpg','https://www.magicbricks.com/vidyadhar-enclave-photo-videos-vidhyadhar-nagar-jaipur-pdpid-4d4235323937373739','Vidyadhar Enclave B-11: pink/white facade, balconies, parking'),
 ('03-vdn-sikar-commercial','sun-n-moon.jpg','https://dyimg1.realestateindia.com/proj_images/project62328/projGal-1-770x400.jpg','https://www.realestateindia.com/projects/sun-n-moon-in-vidyadhar-nagar-jaipur-pjid-62328/','Sun N Moon: arcade rhythm and upper-floor shade'),
 ('04-vdn-cafe-frontage','cafe-terrace.jpg','https://b.zmtcdn.com/data/reviews_photos/270/974b00ddd5367f35ed6bb7366d3ab270_1654275341.jpg','https://www.zomato.com/jaipur/foreigners-cafe-vidhyadhar-nagar/reviews','VDN cafe listing: turf patio, pots, mixed seating'),
 ('04-vdn-cafe-frontage','window-seating.png','https://b.zmtcdn.com/data/pictures/6/19486156/cb41778c22ffe489025800b322f23fb8.png','https://www.zomato.com/jaipur/brown-sugar-vidhyadhar-nagar','VDN cafe: window counter and pendants'),
]
def fetch(spec):
 lane,name,url,page,note=spec
 item=dict(file=f'references/{lane}/{name}',image_url=url,source_page=page,note=note,retrieved='2026-11-13',usage='Local visual study only. Copyright retained by source; excluded from game export. Exact street/geolocation not verified from listing photos.')
 try:
  response=requests.get(url,timeout=30);response.raise_for_status()
  im=Image.open(io.BytesIO(response.content));im.verify()
  dest=ROOT/item['file'];dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(response.content)
  item.update(status='saved',sha256=hashlib.sha256(response.content).hexdigest())
 except Exception as exc: item.update(status='unavailable',error=str(exc))
 return item
if __name__=='__main__':
 ROOT.mkdir(parents=True,exist_ok=True)
 with ThreadPoolExecutor(max_workers=4) as pool: items=list(pool.map(fetch,SOURCES))
 old=json.loads((ROOT.parents[0]/'02-jaipur-lane/references/sources.json').read_text())
 panos=[]
 for source in old:
  if any(x in source['file'] for x in ['sikar_road','vdn_central','vdn_sector']):
   panos.append(dict(source, status='not_downloaded', reason='Google thumbnail endpoint returned HTTP 403 on 2026-11-13; saved link only. Historical pano location metadata from existing project; not reverified.', requested_headings=[0,45,90,135,180,225,270,315]))
 (ROOT/'sources.json').write_text(json.dumps({'images':items,'streetview_links':panos},indent=2,ensure_ascii=False))
 valid=[i for i in items if i['status']=='saved']
 board=Image.new('RGB',(1200,((len(valid)+2)//3)*300),(16,25,34));draw=ImageDraw.Draw(board)
 for k,item in enumerate(valid):
  im=Image.open(ROOT/item['file']).convert('RGB');im.thumbnail((388,258))
  x=(k%3)*400;y=(k//3)*300
  board.paste(im,(x+(400-im.width)//2,y))
  draw.text((x+8,y+267),Path(item['file']).parent.name,fill='white')
  draw.text((x+8,y+283),Path(item['file']).name,fill='white')
 board.save(ROOT/'reference-contact-sheet.jpg')
 print(json.dumps({i['file']:i['status'] for i in items},indent=2))
