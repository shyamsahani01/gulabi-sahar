shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
// Shoe: upper colour with a darker sole on the downward-facing surfaces and a toe cap band.
uniform vec4 upper_color : source_color = vec4(0.95, 0.94, 0.92, 1.0);
uniform vec4 sole_color : source_color = vec4(0.8, 0.79, 0.77, 1.0);
uniform vec4 accent_color : source_color = vec4(0.12, 0.12, 0.13, 1.0);
uniform float accent = 1.0;
varying float down;
varying float side;
void vertex() {
	vec3 n = normalize(mat3(MODEL_MATRIX) * NORMAL);
	down = n.y;
	side = abs(n.x);
}
void fragment() {
	float sole = smoothstep(-0.35, -0.75, down);
	float band = accent * smoothstep(0.55, 0.85, side) * (1.0 - smoothstep(-0.2, 0.3, down));
	vec3 albedo = mix(upper_color.rgb, accent_color.rgb, band);
	albedo = mix(albedo, sole_color.rgb, sole);
	ALBEDO = albedo;
	ROUGHNESS = mix(0.7, 0.9, sole);
	SPECULAR = 0.3;
}
