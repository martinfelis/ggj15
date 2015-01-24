extern number noise_amp;
extern number screen_center_x;
extern number screen_center_y;

extern Image noise_texture;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec2 screen_center = vec2 (screen_center_x, screen_center_y);
	vec4 noise;

	noise = Texel (noise_texture, texture_coords + screen_center);
//	noise = Texel (noise_texture, screen_coords); 
	noise = normalize (noise * 2.0 - vec4 (1.0, 1.0, 1.0, 1.0));
	noise *= noise_amp;

	vec4 c = Texel(texture, texture_coords + noise.xy);
	return vec4 (c.r, c.g, c.b, c.a);
}
