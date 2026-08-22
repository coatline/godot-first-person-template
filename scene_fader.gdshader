shader_type canvas_item;

uniform vec4 fade_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec2 center = vec2(0.5, 0.5);
uniform float radius = 0.0;
uniform float slide = 0.0;
uniform float wipe = 0.0;
uniform bool wipe_reverse = false;

void fragment() {
	float cover = fade_color.a;

	// Circle (iris) wipe: radius 0 = open, 1 = fully covered.
	float max_dist = length(max(center, vec2(1.0) - center));
	float circle_cover = (1.0 - smoothstep(radius * max_dist - 0.003, radius * max_dist + 0.003, distance(UV, center))) * step(0.0001, radius);
	cover = max(cover, circle_cover);

	// Barn door slide: 0 = open, 1 = closed. The two doors sweep from the
	// edges and meet in the center (inverted curtain).
	float barn_edge = (1.0 - slide) * 0.5;
	float curtain = smoothstep(barn_edge - 0.002, barn_edge + 0.002, abs(UV.x - 0.5)) * step(0.0001, slide);
	cover = max(cover, curtain);

	// Horizontal wipe: a solid wall sweeps left to right. covered where UV.x < wipe,
	// 0 = open, 1.02 = fully covered (slight overshoot avoids edge slivers).
	// wipe_reverse flips coverage so the wall keeps moving right on fade-in
	// (darkness retreats rightward instead of sweeping back left).
	float wipe_edge = smoothstep(wipe - 0.002, wipe + 0.002, UV.x);
	float wipe_cover = mix(1.0 - wipe_edge, wipe_edge, float(wipe_reverse));
	cover = max(cover, wipe_cover);

	COLOR = vec4(fade_color.rgb, cover);
}