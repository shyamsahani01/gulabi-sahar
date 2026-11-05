"""Original synthesized game effects; no third-party samples."""
import math,random,wave,struct,pathlib
out=pathlib.Path(__file__).resolve().parents[1]/'assets/audio';out.mkdir(exist_ok=True)
rng=random.Random(88);rate=22050
for name,duration in [('step',.12),('impact',.22),('dodge',.24),('engine',2.0)]:
 data=[];low=0
 for i in range(int(rate*duration)):
  t=i/rate;n=rng.uniform(-1,1);low=.82*low+.18*n
  if name=='step':v=(low*.7+math.sin(t*520)*.1)*math.exp(-t*35)
  elif name=='impact':v=(low*.9+math.sin(t*(600-1000*t))*.5)*math.exp(-t*23)
  elif name=='dodge':v=low*math.sin(math.pi*t/duration)*.3
  else:v=(math.sin(t*2*math.pi*48)*.12+math.sin(t*2*math.pi*96)*.04+low*.03)
  data.append(int(max(-1,min(1,v))*.8*32767))
 with wave.open(str(out/(name+'.wav')),'wb') as w:
  w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate);w.writeframes(struct.pack('<'+'h'*len(data),*data))
