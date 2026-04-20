extends Node

# Preload the material variants
var mat_opaque = preload("res://addons/psx_visuals_gd4/materials/mat_psx_opaque.tres")
var mat_transparent = preload("res://addons/psx_visuals_gd4/materials/mat_psx_transparent.tres")
var mat_opaque_double = preload("res://addons/psx_visuals_gd4/materials/mat_psx_opaque_double.tres")
var mat_transparent_double = preload("res://addons/psx_visuals_gd4/materials/mat_psx_transparent_double.tres")

func _enter_tree():
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node):
	if node is GeometryInstance3D:
		if node is Label3D:
			return

		if node is GPUParticles3D:
			return

		if node is CPUParticles3D:
			return

		# Check if this node specifically is disabled
		if node.has_meta("psx_disable") and node.get_meta("psx_disable") == true:
			return

		# Check if any parent has "psx_disable_children"
		if _is_inside_disabled_branch(node):
			return

		# Defer the call slightly to ensure the mesh and materials are fully loaded
		_apply_ps1_shader.call_deferred(node)

# Helper function to crawl up the tree and check for child-disabling flags
func _is_inside_disabled_branch(node: Node) -> bool:
	var parent = node.get_parent()
	while parent:
		if parent.has_meta("psx_disable_children") and parent.get_meta("psx_disable_children") == true:
			return true
		parent = parent.get_parent()
	return false

# Helper function to determine which PSX material variant to use based on metadata
func _get_target_material(node: Node) -> Resource:
	var mat_type = "opaque" # Default fallback

	# Priority 1: Check node's own metadata
	if node.has_meta("psx_material"):
		mat_type = node.get_meta("psx_material")
	else:
		# Priority 2: Check parents for psx_material_children
		var parent = node.get_parent()
		while parent:
			if parent.has_meta("psx_material_children"):
				mat_type = parent.get_meta("psx_material_children")
				break
			parent = parent.get_parent()

	# Match the string to the correct preloaded resource
	match mat_type:
		"transparent":
			return mat_transparent
		"opaque_double":
			return mat_opaque_double
		"transparent_double":
			return mat_transparent_double
		_:
			return mat_opaque

func _apply_ps1_shader(node: GeometryInstance3D):
	# Re-check metadata inside deferred call in case it was added during the same frame
	if node.has_meta("psx_disable") or _is_inside_disabled_branch(node):
		return

	var mesh = node.mesh
	if not mesh:
		return

	# Determine which base material to use for this specific node
	var base_material = _get_target_material(node)

	for i in range(mesh.get_surface_count()):
		var original_mat = node.get_active_material(i)

		# Skip if it's already a PSX shader from any of our variants
		if original_mat is ShaderMaterial and original_mat.shader == base_material.shader:
			continue

		# Duplicate the selected base material
		var new_mat = base_material.duplicate()

		if original_mat is StandardMaterial3D:
			# 1. Copy the Albedo Texture
			if original_mat.albedo_texture:
				new_mat.set_shader_parameter("albedo", original_mat.albedo_texture)

			# 2. Copy the Albedo scale
			new_mat.set_shader_parameter("albedo_scale", Vector2(original_mat.uv1_scale.x, original_mat.uv1_scale.y))

			# 3. Copy the Albedo Tint/Color
			new_mat.set_shader_parameter("albedo_tint", original_mat.albedo_color)

			# 4. Handle Emission
			if original_mat.emission_enabled:
				new_mat.set_shader_parameter("emission", original_mat.emission_texture)
				new_mat.set_shader_parameter("emission_tint", original_mat.emission)

		node.set_surface_override_material(i, new_mat)
