shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
uniform vec4 cloth_color : source_color = vec4(0.9, 0.88, 0.82, 1.0);
uniform float weave_scale = 700.0;
uniform float denim = 0.0;
void fragment() {
	float warp = sin(UV.x * weave_scale * 6.28318);
	float weft = sin(UV.y * weave_scale * 6.28318);
	float twill = sin((UV.x + UV.y * 0.52) * weave_scale * 3.14159);
	float filter_width = max(fwidth(UV.x), fwidth(UV.y)) * weave_scale;
	float thread = mix(warp * weft, twill, denim) * (1.0 - smoothstep(0.2, 0.8, filter_width));
	ALBEDO = cloth_color.rgb * (0.94 + thread * 0.035);
	ROUGHNESS = 0.88 + 0.05 * thread;
	SPECULAR = 0.22;
	NORMAL_MAP = normalize(vec3(warp * 0.06, weft * 0.06, 1.0)) * 0.5 + 0.5;
}
