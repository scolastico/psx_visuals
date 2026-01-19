@tool extends EditorPlugin

const AUTOLOAD_NAME := "PsxVisualsGd4"
const AUTOLOAD_PATH := "res://addons/psx_visuals/scripts/Autoload.gd"

func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	
	# Initialize globals immediately so errors don't pop up on first run
	Psx.touch_shader_globals()

func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
