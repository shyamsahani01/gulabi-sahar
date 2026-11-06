import subprocess,pathlib,json,zipfile,hashlib,time,sys,shutil,os
root=pathlib.Path(__file__).resolve().parents[1]
version='0.9.2';tag='v092'
preview='--preview' in sys.argv
package='com.itgurujan.gulabisahar'+('.preview' if preview else '')
suffix='-preview' if preview else ''
if preview:tag+='-preview'
sdk=pathlib.Path(os.environ.get('ANDROID_HOME','/home/shyam/Android/Sdk'));apk=root/f'builds/GulabiSahar-{version}{suffix}-debug.apk'
def run(args):
 p=subprocess.run([str(a) for a in args],capture_output=True,text=True)
 if p.returncode:raise RuntimeError(p.stdout+p.stderr)
 return p.stdout.strip()
validation={'apk':str(apk),'sha256':hashlib.sha256(apk.read_bytes()).hexdigest(),'bytes':apk.stat().st_size}
validation['signature']=run([sdk/'build-tools/36.0.0/apksigner','verify','--verbose',apk])
validation['alignment']=run([sdk/'build-tools/36.0.0/zipalign','-c','-P','16','-v','4',apk]).splitlines()[-1]
with zipfile.ZipFile(apk) as z:
 validation['archive_error']=z.testzip()
 validation['documentation_or_source_bundled']=[n for n in z.namelist() if n.endswith(('.pdf','.blend')) or '/designs/' in n or '/tools/' in n]
assert validation['archive_error'] is None and not validation['documentation_or_source_bundled']
(root/f'builds/validation-{tag}.json').write_text(json.dumps(validation,indent=2))
adb=sdk/'platform-tools/adb'
if not adb.exists():adb=shutil.which('adb')
for target in [a for a in sys.argv[1:] if a!='--preview']:
 print('CONNECT',target,subprocess.run([str(adb),'connect',target],capture_output=True,text=True).stdout.strip(),flush=True)
devices=run([adb,'devices','-l']);print(devices,flush=True)
lines=[x for x in devices.splitlines() if 'device product:' in x and 'model:2509BRP2DI' in x]
if not lines:raise RuntimeError('Expected tablet is not connected')
transport=lines[0].split('transport_id:')[1].strip()
base=[adb,'-t',transport]
record={'version':version,'package_id':package,'transport':transport,'model':run(base+['shell','getprop','ro.product.model'])}
probe=subprocess.run([str(x) for x in base+['shell','pm','path',package]],capture_output=True,text=True)
fresh_preview=preview and not probe.stdout.strip()
try:
 record['install']=run(base+['install','--no-incremental','-r',apk])
except RuntimeError as exc:
 record['install_error']=str(exc)
 (root/f'builds/tablet-install-{tag}.json').write_text(json.dumps(record,indent=2))
 raise
if fresh_preview:
 old=subprocess.run([str(x) for x in base+['exec-out','run-as','com.itgurujan.gulabisahar','cat','files/city_progress.json']],capture_output=True)
 if old.returncode==0:
  assert isinstance(json.loads(old.stdout),dict), 'Existing save is not a JSON object'
  (root/'builds/tablet-progress-backup.json').write_bytes(old.stdout)
  run(base+['shell','run-as',package,'mkdir','-p','files'])
  copied=subprocess.run([str(x) for x in base+['shell','run-as',package,'tee','files/city_progress.json']],input=old.stdout,capture_output=True)
  if copied.returncode:raise RuntimeError('Preview installed, but save copy failed')
  record['save_migration']='Copied existing city_progress.json; original retained'
 else:
  record['save_migration']='Existing save was not readable; original retained'

print('INSTALL',record['install'],flush=True)
record['launch']=run(base+['shell','am','start','-W','-n',package+'/com.godot.game.GodotAppLauncher'])
record['package']=run(base+['shell','dumpsys','package',package])
record['package']='\n'.join(x.strip() for x in record['package'].splitlines() if 'versionName=' in x or 'versionCode=' in x)
time.sleep(8)
record['foreground']='\n'.join(x.strip() for x in run(base+['shell','dumpsys','activity','activities']).splitlines() if 'ResumedActivity' in x)
record['pid']=run(base+['shell','pidof',package])
(root/f'builds/tablet-install-{tag}.json').write_text(json.dumps(record,indent=2))
(root/'builds/previews').mkdir(parents=True,exist_ok=True)
with (root/f'builds/previews/tablet-{tag}-installed.png').open('wb') as f:subprocess.run([str(x) for x in base+['exec-out','screencap','-p']],stdout=f,check=True)
print(json.dumps(record,indent=2),flush=True)
