shader_type spatial;
render_mode specular_schlick_ggx;
uniform sampler2D grain : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 dark_color : source_color = vec4(0.28,0.10,0.035,1.0);
uniform vec4 light_color : source_color = vec4(0.62,0.33,0.13,1.0);
varying vec3 world_position;
void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
}
void fragment() {
    float g = texture(grain,world_position.xz*vec2(.17,.48)).r;
    ALBEDO = mix(dark_color.rgb,light_color.rgb,smoothstep(.06,.38,g));
    ROUGHNESS = .48;
    EMISSION = ALBEDO * .055;
}
