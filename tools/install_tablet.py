import subprocess,pathlib,json,zipfile,hashlib,time,sys,shutil
root=pathlib.Path(__file__).resolve().parents[1]
version='0.6.0';tag='v06'
sdk=pathlib.Path('/home/shyam/Android/Sdk');apk=root/f'builds/GulabiSahar-{version}-debug.apk'
def run(args):
 p=subprocess.run([str(a) for a in args],capture_output=True,text=True)
 if p.returncode:raise RuntimeError(p.stdout+p.stderr)
 return p.stdout.strip()
validation={'apk':str(apk),'sha256':hashlib.sha256(apk.read_bytes()).hexdigest(),'bytes':apk.stat().st_size}
validation['signature']=run([sdk/'build-tools/35.0.0/apksigner','verify','--verbose',apk])
validation['alignment']=run([sdk/'build-tools/35.0.0/zipalign','-c','-P','16','-v','4',apk]).splitlines()[-1]
with zipfile.ZipFile(apk) as z:
 validation['archive_error']=z.testzip()
 validation['documentation_or_source_bundled']=[n for n in z.namelist() if n.endswith(('.pdf','.blend')) or '/designs/' in n or '/tools/' in n]
assert validation['archive_error'] is None and not validation['documentation_or_source_bundled']
(root/f'builds/validation-{tag}.json').write_text(json.dumps(validation,indent=2))
adb=sdk/'platform-tools/adb'
if not adb.exists():adb=shutil.which('adb')
for target in sys.argv[1:]:
 print('CONNECT',target,subprocess.run([str(adb),'connect',target],capture_output=True,text=True).stdout.strip(),flush=True)
devices=run([adb,'devices','-l']);print(devices,flush=True)
lines=[x for x in devices.splitlines() if 'device product:' in x and 'model:2509BRP2DI' in x]
if not lines:raise RuntimeError('Expected tablet is not connected')
transport=lines[0].split('transport_id:')[1].strip()
base=[adb,'-t',transport]
record={'version':version,'transport':transport,'model':run(base+['shell','getprop','ro.product.model'])}
try:
 record['install']=run(base+['install','--no-incremental','-r',apk])
except RuntimeError as error:
 if 'INSTALL_FAILED_UPDATE_INCOMPATIBLE' not in str(error):raise
 # A build signed on another machine is installed: replace it (local app data is lost).
 record['uninstall']=run(base+['uninstall','com.itgurujan.gulabisahar'])
 record['install']=run(base+['install','--no-incremental','-r',apk])
print('INSTALL',record['install'],flush=True)
record['launch']=run(base+['shell','am','start','-W','-n','com.itgurujan.gulabisahar/com.godot.game.GodotAppLauncher'])
record['package']=run(base+['shell','dumpsys','package','com.itgurujan.gulabisahar'])
record['package']='\n'.join(x.strip() for x in record['package'].splitlines() if 'versionName=' in x or 'versionCode=' in x)
time.sleep(8)
record['foreground']='\n'.join(x.strip() for x in run(base+['shell','dumpsys','activity','activities']).splitlines() if 'ResumedActivity' in x)
record['pid']=run(base+['shell','pidof','com.itgurujan.gulabisahar'])
(root/f'builds/tablet-install-{tag}.json').write_text(json.dumps(record,indent=2))
(root/'builds/previews').mkdir(parents=True,exist_ok=True)
with (root/f'builds/previews/tablet-{tag}-installed.png').open('wb') as f:subprocess.run([str(x) for x in base+['exec-out','screencap','-p']],stdout=f,check=True)
print(json.dumps(record,indent=2),flush=True)
