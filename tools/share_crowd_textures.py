"""Share existing character textures across generated GLBs; keep animation/mesh data intact."""
import json,struct
from pathlib import Path
TEXTURES={'young_lightskinned_male_diffuse3':'shyam_young_lightskinned_male_diffuse3.png','short01_diffuse':'shyam_short01_diffuse.png','brown_eye':'shyam_brown_eye.png','Image':'shyam_eyebrow003.png'}
def share(path):
 raw=path.read_bytes();size=struct.unpack_from('<I',raw,12)[0];doc=json.loads(raw[20:20+size]);binary=raw[28+size:];removed=set()
 if all('uri' in im for im in doc['images']):return
 for im in doc['images']:
  assert (path.parent.parent/TEXTURES[im['name']]).exists()
  removed.add(im['bufferView']);im.pop('bufferView');im.pop('mimeType',None);im['uri']='../'+TEXTURES[im['name']]
 mapping={};views=[];out=bytearray()
 for i,v in enumerate(doc['bufferViews']):
  if i in removed:continue
  mapping[i]=len(views);start=v.get('byteOffset',0);chunk=binary[start:start+v['byteLength']]
  out.extend(b'\0'*((-len(out))%4));v['byteOffset']=len(out);out.extend(chunk);views.append(v)
 for a in doc['accessors']:
  if 'bufferView' in a:a['bufferView']=mapping[a['bufferView']]
  if 'sparse' in a:
   for k in ['indices','values']:a['sparse'][k]['bufferView']=mapping[a['sparse'][k]['bufferView']]
 doc['bufferViews']=views;doc['buffers'][0]['byteLength']=len(out);out.extend(b'\0'*((-len(out))%4))
 text=json.dumps(doc,separators=(',',':')).encode();text+=b' '*((-len(text))%4)
 path.write_bytes(struct.pack('<III',0x46546c67,2,28+len(text)+len(out))+struct.pack('<II',len(text),0x4e4f534a)+text+struct.pack('<II',len(out),0x004e4942)+out)
if __name__=='__main__':
 for path in (Path(__file__).resolve().parents[1]/'assets/characters/crowd').glob('*.glb'):share(path)
