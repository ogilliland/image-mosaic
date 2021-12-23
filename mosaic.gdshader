shader_type canvas_item;

uniform float pixel_size;

void fragment() {
	vec2 uv = SCREEN_UV;
	uv -= mod(uv, pixel_size * SCREEN_PIXEL_SIZE);
	COLOR = texture(SCREEN_TEXTURE, uv);
}