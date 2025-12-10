
@tool extends EditorPlugin

const AUTOLOAD_NAME := "PSXScreenEffects"
const AUTOLOAD_PATH := "res://addons/psx_visuals/ScreenDitherAutoload.gd"

func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)

func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
