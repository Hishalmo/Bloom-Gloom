shader_type canvas_item;

// End-portal style starfield laid OVER the tile art.
// The tile's own colours are kept; stars are blended on top with a screen blend.

const int LAYERS = 5;

uniform float opacity : hint_range(0.0, 1.0) = 0.6;         // strength of the overlay (0 = tiles untouched)
uniform float cell_size : hint_range(2.0, 32.0) = 7.0;      // star grid size in pixels (nearest layer)
uniform float star_chance : hint_range(0.0, 1.0) = 0.22;    // fraction of grid cells that hold a star
uniform float star_size : hint_range(0.05, 0.5) = 0.18;     // star radius, as a fraction of a cell
uniform float brightness : hint_range(0.0, 3.0) = 1.4;
uniform float twinkle : hint_range(0.0, 1.0) = 0.6;
uniform float twinkle_speed : hint_range(0.0, 10.0) = 2.5;
uniform float drift_speed : hint_range(0.0, 60.0) = 6.0;    // slow swirl, pixels per second
uniform float parallax : hint_range(0.0, 1.0) = 0.85;      // 0 = all layers locked to the screen, 1 = full depth spread
uniform vec3 color_near : source_color = vec3(0.1, 1.0, 0.8);
uniform vec3 color_far : source_color = vec3(0.55, 0.3, 1.0);

varying vec2 world_pos;

void vertex() {
	// Where this vertex is in the world, so the pattern runs across tiles instead of repeating per tile
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void fragment() {
	// The tile's own colour, before we touch anything
	vec3 tile_rgb = COLOR.rgb;

	vec2 screen_px = SCREEN_UV / SCREEN_PIXEL_SIZE;
	vec3 stars = vec3(0.0);

	for (int i = 0; i < LAYERS; i++) {
		// t: 0 = nearest layer, 1 = deepest layer
		float t = float(i) / float(LAYERS - 1);

		// depth 1 = stuck to the block, 0 = stuck to the screen. Different values per layer give parallax.
		float depth = 1.0 - t * parallax;
		vec2 p = mix(screen_px, world_pos, depth);

		// Slow drift, faster for deeper layers
		p += vec2(0.4, 1.0) * TIME * drift_speed * (0.3 + t);

		// Deeper layers get a finer star grid
		float cell = cell_size * mix(1.0, 0.55, t);
		vec2 g = p / cell;
		vec2 id = floor(g);
		vec2 f = fract(g);

		float h = hash21(id + float(i) * 17.0);
		vec2 star_pos = vec2(hash21(id + 3.1), hash21(id + 7.7)) * 0.6 + 0.2;

		// Hard-edged dot so it stays crisp like pixel art
		float has_star = step(1.0 - star_chance, h);
		float dot_mask = step(distance(f, star_pos), star_size * (0.6 + h * 0.6));

		float tw = 0.5 + 0.5 * sin(TIME * twinkle_speed * (0.5 + h) + h * 6.2831);
		float star = has_star * dot_mask * mix(1.0, tw, twinkle);

		// Deeper layers are dimmer
		stars += mix(color_near, color_far, t) * star * mix(1.0, 0.45, t);
	}

	stars = min(stars * brightness, vec3(1.0)) * opacity;

	// Screen blend: light is added on top of the tile art and never goes past white.
	// Where there is no star, the tile stays exactly as it was.
	vec3 result = 1.0 - (1.0 - tile_rgb) * (1.0 - stars);

	// Keep the tile's own alpha so block shapes don't change
	COLOR = vec4(result, COLOR.a);
}
