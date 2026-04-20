const float PSX_DITHER_MATRIX[16] = float[](
    0.0,  8.0,  2.0, 10.0,
    12.0, 4.0, 14.0, 6.0,
    3.0, 11.0, 1.0,  9.0,
    15.0, 7.0, 13.0, 5.0
);

vec4 dither(vec4 color, vec2 uv, int depth) {
	ivec2 p = ivec2(floor(uv));
	int xi = int(p.x & 3);
	// mod 4
	int yi = int(p.y & 3); // mod 4
	int index = xi + yi * 4;
	float norm = PSX_DITHER_MATRIX[index] / 16.0;
	float bit_levels = float((1 << depth) - 1);
	return floor((color + norm / bit_levels) * bit_levels) / bit_levels;
}

vec3 snap(vec3 vertex, mat4 matrix, float scale) {
	if (scale == 0.0) return vertex;

	vec3 v = (matrix * vec4(vertex, 1.0)).xyz;
	v = round(v / scale) * scale;
	return (inverse(matrix) * vec4(v, 1.0)).xyz;
}

// --- PSX COMMON UNIFORMS & VARYINGS ---

global uniform int psx_bit_depth;
global uniform float psx_affine_strength;
global uniform vec4 psx_fog_color;
global uniform float psx_fog_far;
global uniform float psx_fog_near;
global uniform float psx_snap_distance;

uniform bool use_vertex_colors_in_albedo = true;
uniform bool use_global_fog = true;

uniform sampler2D albedo: hint_default_white, filter_nearest;
uniform vec4 albedo_tint: source_color = vec4(1);
uniform sampler2D emission: hint_default_black, filter_nearest;
uniform vec3 emission_tint: source_color = vec3(1);
uniform vec2 albedo_scale = vec2(1.0);

varying vec3 VERTEX_COLOR;
varying float VERTEX_DEPTH;
varying float fog_strength;
varying vec2 affine_uv_scaled;

// --- SPATIAL LOGIC HELPERS ---

void psx_compute_vertex(inout vec3 vertex, vec3 color, vec2 uv, out vec3 out_color, out float out_depth, out float out_fog, out vec2 out_affine_uv) {
	out_color = color;
	// GODOT 4 FIX: VERTEX is already in View Space.
	// We snap it directly without multiplying by MODELVIEW_MATRIX.
	vertex = round(vertex / psx_snap_distance) * psx_snap_distance;

	// GODOT 4 FIX: Calculate depth directly from View Space coordinates.
	// Since the camera is at (0,0,0) in View Space, length(VERTEX) is the distance.
	out_depth = length(vertex);
	out_affine_uv = uv * out_depth;

	out_fog = (use_global_fog && psx_fog_near != psx_fog_far) ?
		clamp(psx_fog_color.a * (out_depth - psx_fog_near) / (psx_fog_far - psx_fog_near), 0.0, 1.0) :
		0.0;
}

void psx_compute_backface_normal(vec3 vertex, inout vec3 normal) {
	// GODOT 4 FIX: Perform check in View Space
	// Vector from vertex to camera (0,0,0)
	vec3 view_dir = normalize(-vertex);
	bool back_facing = dot(normal, view_dir) < 0.0;
	if (back_facing) normal = -normal;
}

void psx_compute_fragment(vec2 uv_in, inout vec3 albedo_out, inout float alpha_out, inout vec3 emission_out) {
	vec2 scaled_uv = uv_in * albedo_scale;
	vec2 affine_uv = affine_uv_scaled / VERTEX_DEPTH;
	vec2 uv = mix(uv_in, affine_uv, psx_affine_strength);

	vec3 fog_rgb = mix(vec3(0), psx_fog_color.rgb, fog_strength);

	vec4 albedo_color = texture(albedo, uv) * albedo_tint;
	if (use_vertex_colors_in_albedo) albedo_color *= vec4(VERTEX_COLOR, 1.0);

	albedo_out = albedo_color.rgb * (1.0 - fog_strength) + fog_rgb;
	alpha_out = albedo_color.a;
	vec4 emission_color = texture(emission, uv) * vec4(emission_tint, 1.0);
	emission_out = emission_color.rgb + fog_rgb;
}
