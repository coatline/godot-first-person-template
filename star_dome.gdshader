shader_type spatial;
render_mode unshaded, depth_draw_never, cull_front, blend_mix;

uniform float night_factor : hint_range(0.0, 1.0) = 0.0;
uniform float star_density : hint_range(0.0, 1.0) = 0.6;
uniform float star_size : hint_range(0.01, 1.0) = 0.5;
uniform vec3 star_color : source_color = vec3(1.0);

varying vec3 star_dir;

float hash31(vec3 p) {
	p = fract(p * 0.1031);
	p += dot(p, p.zyx + 31.32);
	return fract((p.x + p.y) * p.z);
}

void vertex() {
	// Directions in WORLD space so the star field stays fixed to the sky
	// (VERTEX alone would be view space in fragment() and rotate with the camera).
	star_dir = normalize((MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz);
}

void fragment() {
	vec3 dir = normalize(star_dir);

	float horizon_fade = smoothstep(0.0, 0.12, dir.y);
	if (horizon_fade <= 0.001) {
		discard;
	}
	if (night_factor <= 0.0) {
		discard;
	}

	vec3 cell = floor(dir * 256.0);
	vec3 fract_part = fract(dir * 256.0);
	float h = hash31(cell);
	if (h <= 1.0 - star_density * 0.025) {
		discard;
	}

	float dist_to_center = distance(fract_part, vec3(0.5));
	float size = 0.2 + star_size * 0.4 * hash31(cell + 17.1);
	float star = smoothstep(size, size * 0.3, dist_to_center);
	if (star <= 0.0) {
		discard;
	}

	float twinkle = 0.85 + 0.15 * sin(TIME * 1.8 + h * 97.0);
	float tint = hash31(cell + 7.3);
	vec3 col = mix(vec3(0.85, 0.9, 1.0), star_color, tint);
	ALBEDO = col * star * twinkle * horizon_fade * night_factor;
	ALPHA = clamp(star, 0.0, 1.0) * twinkle * horizon_fade * night_factor;
}