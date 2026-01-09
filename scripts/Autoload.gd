
extends CanvasLayer

const POST_PROCESS_MATERIAL : ShaderMaterial = preload("uid://da2sluxj84btb")

func _init() -> void:
	layer = RenderingServer.CANVAS_LAYER_MIN

	var color_rect := ColorRect.new()
	color_rect.material = POST_PROCESS_MATERIAL
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)

	add_child(color_rect)
