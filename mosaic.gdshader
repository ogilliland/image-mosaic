shader_type canvas_item;

uniform vec4 clear_color : hint_color;
uniform vec2 border;
uniform float pixel_size;
uniform sampler2D pixel_texture : hint_albedo;

void fragment() {
	vec2 uv = SCREEN_UV - border * SCREEN_PIXEL_SIZE;
	vec2 uv_mod = mod(uv, pixel_size * SCREEN_PIXEL_SIZE);
	vec2 uv_mod_frac = uv_mod / (pixel_size * SCREEN_PIXEL_SIZE);
	
	// Get base color from pixellated image
	uv -= uv_mod;
	vec4 albedo = texture(SCREEN_TEXTURE, uv + 0.5 * pixel_size * SCREEN_PIXEL_SIZE);
	
	// Add a border of 0.1 * pixel_size around each mosaic tile
	uv_mod_frac = uv_mod_frac * 1.2;
	vec4 mosaic = texture(pixel_texture, uv_mod_frac);
	
	// Prevent ugly uv wrapping - maybe not necessary?
//	if(uv_mod_frac.x < 0.0 && uv_mod_frac.x > 1.0 && uv_mod_frac.y < 0.0 && uv_mod_frac.y > 1.0) {
//		mosaic = vec4(0, 0, 0, 0);
//	}
	
	// Apply mosaic texture to base color, and fill transparent gaps with clear color
	COLOR = albedo * mosaic + clear_color * (1.0 - mosaic.a);
	
	// Apply border to hide partial tiles
	if(SCREEN_UV.x < border.x * SCREEN_PIXEL_SIZE.x || SCREEN_UV.x > 1.0 - border.x * SCREEN_PIXEL_SIZE.x || SCREEN_UV.y < border.y * SCREEN_PIXEL_SIZE.y || SCREEN_UV.y > 1.0 - border.y * SCREEN_PIXEL_SIZE.y) {
		COLOR = clear_color;
	}
}