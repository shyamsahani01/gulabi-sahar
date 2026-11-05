"""Measure only the supplied approved image locally; no personal image upload."""
import mediapipe as mp,json,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[1]
options=mp.tasks.vision.FaceLandmarkerOptions(base_options=mp.tasks.BaseOptions(model_asset_path='/home/shyam/MyWork/Tools/FaceReference/face_landmarker.task'),num_faces=4)
with mp.tasks.vision.FaceLandmarker.create_from_options(options) as detector:
 result=detector.detect(mp.Image.create_from_file(str(ROOT/'designs/01-character/shyam-concept-03c.png')))
faces=result.face_landmarks
face=max(faces,key=lambda f:(max(p.x for p in f)-min(p.x for p in f))*(max(p.y for p in f)-min(p.y for p in f)))
data={'source':'designs/01-character/shyam-concept-03c.png','landmarks':[[p.x,p.y,p.z] for p in face]}
(ROOT/'tools/source/approved_face_landmarks.json').write_text(json.dumps(data))
print('Faces found',len(faces),'landmarks',len(face))
for i in [1,4,10,33,61,133,152,234,263,291,362,454]:print(i,data['landmarks'][i])
