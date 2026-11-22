shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// Ripple origin (0-1 screen coords) and how far the ripple has spread.
// radius 0 = no effect, radius ~2.5 = whole screen covered.
uniform vec2 center = vec2(0.5);
uniform float radius : hint_range(0.0, 3.0) = 0.0;
uniform float edge_softness : hint_range(0.0, 0.5) = 0.04;

// Wavefront look
uniform float ring_width : hint_range(0.0, 0.3) = 0.06;
uniform float distortion : hint_range(0.0, 0.05) = 0.012;
uniform float ring_glow : hint_range(0.0, 1.0) = 0.15;

// Greyscale look
uniform float strength : hint_range(0.0, 1.0) = 1.0;
uniform float black_point : hint_range(0.0, 0.9) = 0.25;
uniform float gamma : hint_range(1.0, 4.0) = 1.5;

// Colour that stays coloured
uniform vec3 spare_color : source_color = vec3(1.0, 0.0, 0.0);
uniform float tolerance : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	// Distance from the ripple centre, corrected so the circle is round on any screen shape
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 offset_from_center = (SCREEN_UV - center) * vec2(aspect, 1.0);
	float dist = length(offset_from_center);

	// 1.0 right at the wavefront, fading to 0.0 either side. Off while radius is 0.
	float ring = (1.0 - smoothstep(0.0, ring_width, abs(dist - radius))) * step(0.001, radius);

	// Push the picture outward at the wavefront so it looks like a water ripple
	vec2 dir = offset_from_center / max(dist, 0.0001);
	vec2 uv = SCREEN_UV + dir * vec2(1.0 / aspect, 1.0) * ring * distortion;
	vec3 orig_color = texture(screen_texture, uv).rgb;

	// 1.0 inside the circle, 0.0 outside, soft at the edge
	float inside = 1.0 - smoothstep(radius - edge_softness, radius, dist);

	// Greyscale with crushed blacks
	float grey = dot(orig_color, vec3(0.299, 0.587, 0.114));
	grey = clamp((grey - black_point) / (1.0 - black_point), 0.0, 1.0);
	grey = pow(grey, gamma);
	vec3 grey_color = mix(orig_color, vec3(grey), strength);

	// Spare colour keeps its original colour
	float diff = distance(orig_color, spare_color);
	float spare_mask = (tolerance > 0.0 && diff <= tolerance) ? 1.0 : 0.0;
	grey_color = mix(grey_color, orig_color, spare_mask);

	vec3 result = mix(orig_color, grey_color, inside);
	result += ring * ring_glow;

	COLOR = vec4(result, 1.0);
}
