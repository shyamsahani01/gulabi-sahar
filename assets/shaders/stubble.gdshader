shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
// Light beard drawn as a thin overlay on the skinned face. Positions are converted into the
// head bone's frame each frame (origin at the head joint, +Z the face, +Y up).
uniform mat4 head_inverse;
uniform vec4 hair_color : source_color = vec4(0.07, 0.05, 0.04, 1.0);
uniform float density = 0.55;
varying vec3 hp;
float hash(vec2 v) {
	return fract(sin(dot(v, vec2(12.9898, 78.233))) * 43758.5453);
}
void vertex() {
	hp = (head_inverse * MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX += NORMAL * 0.0012;
}
void fragment() {
	float x = abs(hp.x);
	float y = hp.y;
	float z = hp.z;
	// Jaw and chin below the mouth, wrapping around the sides toward the ears.
	float chin = smoothstep(-0.115, -0.095, y) * (1.0 - smoothstep(-0.036, -0.026, y)) * smoothstep(0.0, 0.03, z);
	float jaw = smoothstep(-0.115, -0.09, y) * (1.0 - smoothstep(-0.03, -0.012, y)) * smoothstep(0.042, 0.058, x) * smoothstep(-0.02, 0.01, z);
	float moustache = 0.7 * smoothstep(-0.018, -0.013, y) * (1.0 - smoothstep(-0.002, 0.004, y)) * (1.0 - smoothstep(0.026, 0.032, x)) * smoothstep(0.06, 0.08, z);
	float sideburn = smoothstep(-0.03, -0.01, y) * (1.0 - smoothstep(0.04, 0.055, y)) * smoothstep(0.066, 0.074, x) * (1.0 - smoothstep(0.0, 0.025, z));
	float mask = clamp(chin + jaw + moustache + sideburn, 0.0, 1.0);
	// Keep the lips clear and fade at the neck.
	mask *= 1.0 - (1.0 - smoothstep(0.028, 0.034, x)) * smoothstep(-0.036, -0.03, y) * (1.0 - smoothstep(-0.012, -0.006, y));
	float grain = 0.55 + 0.45 * step(0.42, hash(floor(hp.xy * 1400.0) + floor(hp.z * 700.0)));
	ALBEDO = hair_color.rgb;
	ALPHA = mask * density * grain;
	ROUGHNESS = 0.9;
	SPECULAR = 0.1;
}
