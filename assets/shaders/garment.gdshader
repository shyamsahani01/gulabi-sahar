shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
// Torso garment drawn over the existing tucked t-shirt mesh (skeleton space: +Z front, +Y up).
// style 0: plain tee  1: open leather jacket over a tee  2: hoodie  3: dark tee under a vest
uniform int style = 1;
uniform vec4 shell_color : source_color = vec4(0.1, 0.1, 0.11, 1.0);
uniform vec4 tee_color : source_color = vec4(0.92, 0.9, 0.86, 1.0);
uniform vec4 trim_color : source_color = vec4(0.75, 0.76, 0.78, 1.0);
varying vec3 p;
void vertex() {
	p = VERTEX;
}
void fragment() {
	vec3 albedo = shell_color.rgb;
	float rough = 0.88;
	float spec = 0.25;
	float front = step(0.0, p.z);
	if (style == 1) {
		// Open front: the tee shows in a strip that widens at the collar; chrome zip teeth on both edges.
		float half_w = 0.046 + max(0.0, p.y - 1.36) * 0.4;
		float inside = front * step(abs(p.x), half_w) * step(p.y, 1.41);
		float zip = front * step(half_w, abs(p.x)) * step(abs(p.x), half_w + 0.006) * step(p.y, 1.36);
		float seam = step(abs(p.x - 0.17), 0.004) + step(abs(p.x + 0.17), 0.004);
		albedo = mix(shell_color.rgb * (1.0 - 0.25 * seam), tee_color.rgb, inside);
		albedo = mix(albedo, trim_color.rgb, zip);
		rough = mix(0.36, 0.9, inside);
		spec = mix(0.55, 0.2, inside);
	} else if (style == 2) {
		// Hoodie: kangaroo pocket line, drawstrings and ribbed hem.
		float pocket = front * step(abs(p.x), 0.125) * (step(abs(p.y - 1.11), 0.003) + step(abs(abs(p.x) - 0.125), 0.003) * step(0.98, p.y) * step(p.y, 1.11));
		float strings = front * step(abs(abs(p.x) - 0.022), 0.0035) * step(1.27, p.y) * step(p.y, 1.41);
		float hem = step(p.y, 0.975);
		albedo = shell_color.rgb * (1.0 - 0.3 * clamp(pocket + strings, 0.0, 1.0)) * (1.0 - 0.08 * hem);
		rough = 0.95;
		spec = 0.15;
	} else if (style == 3) {
		albedo = shell_color.rgb;
		rough = 0.92;
	} else {
		albedo = tee_color.rgb;
	}
	ALBEDO = albedo;
	ROUGHNESS = rough;
	SPECULAR = spec;
}
