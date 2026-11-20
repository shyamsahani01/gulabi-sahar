shader_type spatial;
render_mode diffuse_burley;
uniform vec4 surface_color : source_color = vec4(.40,.39,.35,1.0);
uniform bool paving = false;
varying vec3 place;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p);vec2 f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){place=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 vec2 p=place.xz;
 float mottling=noise(p*.7)*.07+noise(p*3.0)*.035;
 vec3 color=surface_color.rgb*(.94+mottling);
 if(paving){
  vec2 grid=vec2(p.x/.32+mod(floor(p.y/.18),2.0)*.5,p.y/.18);
  vec2 edge=min(fract(grid),1.0-fract(grid));
  float joint=1.0-smoothstep(.018,.035,min(edge.x,edge.y));
  float fade=1.0-smoothstep(.03,.15,max(fwidth(grid.x),fwidth(grid.y)));
  color*=1.0-joint*.22*fade;
  color*=.94+hash(floor(grid))*.1;
 }else{
  float grain=(noise(p*35.0)-.5)*.025;
  color+=grain*(1.0-smoothstep(.02,.09,length(fwidth(p))));
 }
 ALBEDO=color;ROUGHNESS=.96;SPECULAR=.12;
}
