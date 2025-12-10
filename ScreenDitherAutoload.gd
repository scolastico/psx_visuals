extends CanvasLayer

const GLOBAL_VAR_AFFINE := &"psx_affine_strength"
const GLOBAL_VAR_BIT_DEPTH := &"psx_bit_depth"
const GLOBAL_VAR_SNAP := &"psx_snap_size"

func _init() -> void:
	if RenderingServer.global_shader_parameter_get(GLOBAL_VAR_AFFINE) == null:
		RenderingServer.global_shader_parameter_add(GLOBAL_VAR_AFFINE, RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 1.0)
	if RenderingServer.global_shader_parameter_get(GLOBAL_VAR_BIT_DEPTH) == null:
		RenderingServer.global_shader_parameter_add(GLOBAL_VAR_BIT_DEPTH, RenderingServer.GLOBAL_VAR_TYPE_INT, 5)
	if RenderingServer.global_shader_parameter_get(GLOBAL_VAR_SNAP) == null:
		RenderingServer.global_shader_parameter_add(GLOBAL_VAR_SNAP, RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 0.025)

	layer = RenderingServer.CANVAS_LAYER_MIN

	var material := ShaderMaterial.new()
	material.shader = preload("uid://f30u05sxx1vk")

	var color_rect := ColorRect.new()
	color_rect.material = material
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)

	add_child(color_rect)
