shader_type spatial;
uniform vec4 base_color : source_color = vec4(0.7, 0.52, 0.37, 1.0);
uniform float surface_kind = 0.0;
varying vec3 world_position;
varying vec3 world_normal;
float hash(vec2 p) {return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p) {
 vec2 i=floor(p);vec2 f=fract(p);f=f*f*(3.0-2.0*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}
void vertex(){world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;world_normal=MODEL_NORMAL_MATRIX*NORMAL;}
void fragment(){
 vec3 n=abs(normalize(world_normal));
 vec2 p=n.y>0.65 ? world_position.xz : (n.x>n.z ? world_position.zy : world_position.xy);
 vec2 tile_size=surface_kind>1.5 ? vec2(0.7,0.7) : vec2(1.15,0.55);
 vec2 grid=p/tile_size;
 vec2 cell=floor(grid);
 vec2 edge=min(fract(grid),1.0-fract(grid));
 float aa=max(fwidth(grid.x),fwidth(grid.y));
 float seam=1.0-smoothstep(0.006,0.010+aa,min(edge.x,edge.y));
 float grain=noise(p*24.0)*0.035+noise(p*4.5)*0.06;
 float variation=hash(cell)*0.11;
 vec3 c=base_color.rgb*(0.90+variation+grain);
 if(surface_kind<0.5){
  c=mix(c,c*0.65,seam*0.6);
  float drip=noise(vec2(p.x*9.0,p.y*.35))*noise(p*.7);
  c*=1.0-drip*.12;
 }else if(surface_kind<1.5){
  // Broad, irregular pale-panel staining, separate from fine stone grain.
  float stain=smoothstep(.42,.76,noise(vec2(p.x*1.7,p.y*.55))+noise(p*3.0)*.17);
  c=mix(c,vec3(.27,.30,.25),stain*.43);
 }else{
  c=mix(c,c*.55,seam*.55);
  c*=.94+noise(p*.2)*.12;
 }
 ALBEDO=c;
 ROUGHNESS=clamp(.79+noise(p*3.0)*.16,.0,1.0);
 SPECULAR=.22;
}
