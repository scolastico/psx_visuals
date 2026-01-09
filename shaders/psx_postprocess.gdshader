shader_type canvas_item;

#include "uid://bbm41nyy2th3f"

global uniform int psx_bit_depth;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

void fragment() {
	COLOR = vec4(dither(texture(SCREEN_TEXTURE, UV), FRAGCOORD.xy, psx_bit_depth).rgb, 1.0);
}
