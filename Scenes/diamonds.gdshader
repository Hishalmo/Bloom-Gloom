// Original : Shader By Zacksly - https://zacksly.itch.io/
shader_type canvas_item;

uniform float AspectRatio = 1.5;
uniform float Diamonds = 10.0;
const float _min = -1.0;
const float _max = 1.0;
uniform float pixel_size = 0.08;

uniform float height = -1.0;
uniform float row_sharpness = 6.0; // higher = rows pop in one after another, lower = rows overlap more
uniform bool disable_pixel;

void fragment() {

	vec3 uv_grid = fract(vec3(UV, 0.0) * vec3(AspectRatio * Diamonds, Diamonds, 0.0));
	if(! disable_pixel)uv_grid = round(uv_grid / pixel_size) * pixel_size;
	float grid = abs(uv_grid.x - 0.5) + abs(uv_grid.y - 0.5);
	// which row of diamonds this pixel is in (0 = top row), so every diamond in a row grows together
	float row = floor(UV.y * Diamonds);
	float row_t = clamp(1.0 - row / max(Diamonds - 1.0, 1.0), 0.0, 1.0); // 1.0 = top row, 0.0 = bottom row
	vec3 raw_cam_image = vec3(row_t + height) * row_sharpness;
	vec3 grayscale;
	{
		float max1 = max(raw_cam_image.r, raw_cam_image.g);
		float max2 = max(max1, raw_cam_image.b);
		grayscale = vec3(max(max1, max2));
	}
	vec3 clamped;
	if( disable_pixel)
		clamped = clamp(grayscale, vec3(_min), vec3(_max));
	else
		clamped = round(clamp(grayscale, vec3(_min), vec3(_max))/0.1)*0.1;

	bool black_dot_grid = grid > dot(vec3(1.0) - clamped, vec3(0.333333));

	// black diamonds where the grid says so, fully transparent elsewhere
	COLOR = black_dot_grid ? vec4(0.0, 0.0, 0.0, 1.0) : vec4(0.0);
}