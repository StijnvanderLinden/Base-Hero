shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_opaque, shadows_disabled;

uniform vec4 line_color : source_color = vec4(1.0, 0.86, 0.24, 0.48);
uniform vec4 fill_color : source_color = vec4(1.0, 0.82, 0.18, 0.015);
uniform float cells_per_side = 18.0;
uniform float line_width = 0.028;
uniform float glow_width = 0.11;
uniform float pulse_speed = 1.8;
uniform float pulse_strength = 0.06;

void fragment() {
	vec2 grid_uv = UV * max(cells_per_side, 1.0) + vec2(0.5);
	vec2 edge_distance = min(fract(grid_uv), 1.0 - fract(grid_uv));
	float nearest_edge = min(edge_distance.x, edge_distance.y);
	float line_mask = 1.0 - smoothstep(0.0, line_width, nearest_edge);
	float glow_mask = 1.0 - smoothstep(line_width, glow_width, nearest_edge);
	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_strength;
	float alpha = fill_color.a + glow_mask * 0.08 + line_mask * line_color.a * pulse;
	vec3 line_rgb = line_color.rgb * (line_mask * 0.72 + glow_mask * 0.18) * pulse;
	ALBEDO = fill_color.rgb * fill_color.a + line_rgb;
	EMISSION = line_rgb;
	ALPHA = clamp(alpha, 0.0, 1.0);
}