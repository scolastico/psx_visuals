@tool extends EditorPlugin

const AUTOLOAD_NAME := "PsxVisualsGd4AutoLoad"
const AUTOAPPLY_NAME := "PsxVisualsGd4AutoApply"

func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/psx_visuals_gd4/scripts/AutoLoad.gd")
	add_autoload_singleton(AUTOAPPLY_NAME, "res://addons/psx_visuals_gd4/scripts/AutoApply.gd")

	# Initialize globals immediately so errors don't pop up on first run
	Psx.touch_shader_globals()

func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
	remove_autoload_singleton(AUTOAPPLY_NAME)
    
    var dialog = ConfirmationDialog.new()
    dialog.dialog_text = "Do you want to remove PSX Visuals shader globals from Project Settings?"
    dialog.get_ok_button().text = "Yes, Clean Up"
    dialog.get_cancel_button().text = "No, Keep Settings"
    
    dialog.confirmed.connect(func(): Psx.remove_shader_globals())
    EditorInterface.get_base_control().add_child(dialog)
    dialog.popup_centered()
