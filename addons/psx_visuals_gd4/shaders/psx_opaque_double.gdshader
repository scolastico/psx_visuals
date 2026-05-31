shader_type spatial;
render_mode blend_mix, vertex_lighting, ensure_correct_normals, diffuse_lambert, specular_occlusion_disabled, specular_disabled, shadows_disabled, fog_disabled, cull_disabled;

#include "res://addons/psx_visuals_gd4/shaders/psx.gdshaderinc"

// If enabled, this approximates the correct normals for backfaces, as if the mesh is double-sided.
uniform bool flip_backface_normals = true;

uniform float alpha_scissor_threshold: hint_range(0.0, 1.0, 0.01) = 0.5;

void vertex() {
	vec3 v_col;
	float v_depth;
	float v_fog;
	vec2 v_affine;
	
	// Capture local position before snapping for triplanar
	frag_local_pos = VERTEX;
	
	psx_compute_vertex(VERTEX, COLOR.rgb, UV, v_col, v_depth, v_fog, v_affine);
	
	VERTEX_COLOR = v_col;
	VERTEX_DEPTH = v_depth;
	fog_strength = v_fog;
	affine_uv_scaled = v_affine;
	
	// Compute world-space position
	frag_world_pos = (INV_VIEW_MATRIX * (MODELVIEW_MATRIX * vec4(frag_local_pos, 1.0))).xyz;

	if (flip_backface_normals) {
		psx_compute_backface_normal(VERTEX, NORMAL);
	}
	
	// Compute normals after backface correction
	frag_world_normal = (INV_VIEW_MATRIX * (MODELVIEW_MATRIX * vec4(NORMAL, 0.0))).xyz;
	frag_local_normal = NORMAL;
}

void fragment() {
	psx_compute_fragment(UV, frag_world_pos, frag_world_normal, frag_local_pos, frag_local_normal, ALBEDO, ALPHA, EMISSION);

	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	SPECULAR = 0.0;
	ROUGHNESS = 0.0;
	METALLIC = 0.0;
	AO = 1.0;
}
