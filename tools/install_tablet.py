import subprocess,pathlib,json,zipfile,hashlib,time,sys,shutil,os
root=pathlib.Path(__file__).resolve().parents[1]
version='0.9.14';tag='v0914'
preview='--preview' in sys.argv
# Historical package ID retained for in-place updates; launcher name is Gulabi Sahar.
package='com.itgurujan.gulabisahar.preview'
suffix='-preview' if preview else ''
if preview:tag+='-preview'
sdk=pathlib.Path(os.environ.get('ANDROID_HOME','/home/shyam/Android/sdk'));apk=root/f'builds/GulabiSahar-{version}{suffix}-debug.apk'
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
 old=subprocess.run([str(x) for x in base+['shell','run-as','com.itgurujan.gulabisahar','cat','files/city_progress.json']],capture_output=True)
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
# Keep the tablet awake until the staged loader hands over; always restore timeout.
screen_timeout=run(base+['shell','settings','get','system','screen_off_timeout'])
previews=root/'builds/previews'
previews.mkdir(parents=True,exist_ok=True)
def screenshot(name):
 with (previews/name).open('wb') as f:
  subprocess.run([str(x) for x in base+['exec-out','screencap','-p']],stdout=f,check=True)
try:
 run(base+['shell','settings','put','system','screen_off_timeout','600000'])
 run(base+['shell','input','keyevent','KEYCODE_WAKEUP'])
 subprocess.run([str(x) for x in base+['shell','wm','dismiss-keyguard']],capture_output=True)
 record['launch']=run(base+['shell','am','start','-W','-n',package+'/com.godot.game.GodotAppLauncher'])
 record['package']=run(base+['shell','dumpsys','package',package])
 record['package']='\n'.join(x.strip() for x in record['package'].splitlines() if 'versionName=' in x or 'versionCode=' in x)
 began=time.monotonic()
 record['ready']=False
 time.sleep(2)
 screenshot(f'tablet-{tag}-loading.png')
 while time.monotonic()-began<120:
  pid=subprocess.run([str(x) for x in base+['shell','pidof',package]],capture_output=True,text=True).stdout.strip()
  record['pid']=pid or 'NOT RUNNING'
  if not pid:break
  logs=run(base+['logcat','--pid',pid,'-d','-s','godot:V','Godot:V','*:S'])
  startup=[line for line in logs.splitlines() if 'STARTUP_LOADING ' in line]
  if startup:
   record['startup']=json.loads(startup[-1].split('STARTUP_LOADING ',1)[1])
   record['ready']=True
   break
  time.sleep(2)
 record['observed_wait_seconds']=round(time.monotonic()-began,2)
 record['foreground']='\n'.join(x.strip() for x in run(base+['shell','dumpsys','activity','activities']).splitlines() if 'ResumedActivity' in x)
 record['keyguard']='secure keyguard showing' if 'isKeyguardShowing=true' in run(base+['shell','dumpsys','window']) else 'unlocked'
 if record['ready']:time.sleep(3)
 screenshot(f'tablet-{tag}-installed.png')
finally:
 run(base+['shell','settings','put','system','screen_off_timeout',screen_timeout])
 (root/f'builds/tablet-install-{tag}.json').write_text(json.dumps(record,indent=2))
print(json.dumps(record,indent=2),flush=True)
if not record.get('ready',False):raise RuntimeError('Installed, but gameplay startup was not confirmed; inspect device/logs')
