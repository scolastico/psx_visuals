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

// Triplanar mapping uniforms
uniform bool triplanar = false;
uniform float triplanar_sharpness: hint_range(0.01, 8.0, 0.01) = 1.0;
uniform bool world_triplanar = true;

varying vec3 VERTEX_COLOR;
varying float VERTEX_DEPTH;
varying float fog_strength;
varying vec2 affine_uv_scaled;

// Triplanar varyings
varying vec3 frag_world_pos;
varying vec3 frag_local_pos;
varying vec3 frag_world_normal;
varying vec3 frag_local_normal;

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

// Triplanar texture sampling helper
vec4 triplanar_sample(sampler2D tex, vec3 position, vec3 normal, vec2 uv_scale) {
	vec3 blending = abs(normal);
	blending = max(blending, 0.00001);
	blending = normalize(blending);
	float total = blending.x + blending.y + blending.z;
	blending /= total;

	if (triplanar_sharpness != 1.0) {
		blending = pow(blending, vec3(triplanar_sharpness));
		total = blending.x + blending.y + blending.z;
		blending /= total;
	}

	vec4 x_sample = texture(tex, position.yz * uv_scale);
	vec4 y_sample = texture(tex, position.xz * uv_scale);
	vec4 z_sample = texture(tex, position.xy * uv_scale);

	return x_sample * blending.x + y_sample * blending.y + z_sample * blending.z;
}

void psx_compute_fragment(vec2 uv_in, vec3 world_pos, vec3 world_normal_in, vec3 local_pos, vec3 local_normal_in, inout vec3 albedo_out, inout float alpha_out, inout vec3 emission_out) {
	vec2 scaled_uv = uv_in * albedo_scale;
	vec2 affine_uv = affine_uv_scaled / VERTEX_DEPTH;
	// FIX: Use scaled_uv instead of uv_in so albedo_scale is applied
	vec2 uv = mix(scaled_uv, affine_uv, psx_affine_strength);

	vec3 fog_rgb = mix(vec3(0), psx_fog_color.rgb, fog_strength);

	vec4 albedo_color;
	vec4 emission_color;

	if (triplanar) {
		vec3 tp_pos = world_triplanar ? world_pos : local_pos;
		vec3 tp_normal = world_triplanar ? normalize(world_normal_in) : normalize(local_normal_in);

		albedo_color = triplanar_sample(albedo, tp_pos, tp_normal, albedo_scale);
		albedo_color *= albedo_tint;
		emission_color = triplanar_sample(emission, tp_pos, tp_normal, albedo_scale);
		emission_color *= vec4(emission_tint, 1.0);
	} else {
		albedo_color = texture(albedo, uv) * albedo_tint;
		emission_color = texture(emission, uv) * vec4(emission_tint, 1.0);
	}

	if (use_vertex_colors_in_albedo) albedo_color *= vec4(VERTEX_COLOR, 1.0);

	albedo_out = albedo_color.rgb * (1.0 - fog_strength) + fog_rgb;
	alpha_out = albedo_color.a;
	emission_out = emission_color.rgb + fog_rgb;
}
