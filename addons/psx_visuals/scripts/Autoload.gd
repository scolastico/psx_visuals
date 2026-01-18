extends CanvasLayer

const POST_PROCESS_MATERIAL : ShaderMaterial = preload("uid://da2sluxj84btb")

func _init() -> void:
	layer = -128 

	var color_rect := ColorRect.new()
	color_rect.material = POST_PROCESS_MATERIAL
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Pass mouse events through so the overlay doesn't block inputs
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE 

	add_child(color_rect)
