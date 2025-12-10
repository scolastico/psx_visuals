shader_type spatial;
render_mode blend_mix, diffuse_lambert, specular_occlusion_disabled, specular_disabled, shadows_disabled, fog_disabled, cull_disabled;

#include "uid://bbm41nyy2th3f"

global uniform float psx_affine_strength;
global uniform float psx_snap_distance;
global uniform int psx_bit_depth;

uniform sampler2D albedo: hint_default_white, filter_nearest;
uniform vec4 albedo_tint: source_color = vec4(1);
uniform sampler2D emission: hint_default_black, filter_nearest;
uniform vec3 emission_tint: source_color = vec3(1);
uniform float alpha_scissor_threshold: hint_range(0.0, 1.0, 0.01) = 0.5;

varying float affine_distance;
varying vec2 affine_uv_scaled;

varying vec3 world_vertex;

void vertex() {
	VERTEX = snap(VERTEX, MODELVIEW_MATRIX, psx_snap_distance);
	world_vertex = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;

    affine_distance = length((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz);
    affine_uv_scaled = UV * affine_distance;
}

void fragment() {
	vec2 affine_uv = affine_uv_scaled / affine_distance;
	vec2 uv = mix(UV, affine_uv, psx_affine_strength);

	float bit_levels = float((1 << psx_bit_depth) - 1);
	float dither_value = dither(FRAGCOORD.xy);

	vec4 albedo_color = texture(albedo, uv) * albedo_tint;
	albedo_color = floor((albedo_color + dither_value / bit_levels) * bit_levels) / bit_levels;
	ALBEDO = albedo_color.rgb;

	ALPHA = albedo_color.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;

	vec3 emission_color = texture(emission, uv).rgb * emission_tint;
	emission_color = floor((emission_color + dither_value / bit_levels) * bit_levels) / bit_levels;
	EMISSION = emission_color;

	SPECULAR = 0.0;
	ROUGHNESS = 0.0;
	METALLIC = 0.0;
	AO = 1.0;
}

//void light() {
//
//}
