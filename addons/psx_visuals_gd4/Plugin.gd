@tool
extends EditorPlugin

# Constants for the Autoload singletons used by the plugin
const AUTOLOAD_NAME := "PsxVisualsGd4AutoLoad"
const AUTOAPPLY_NAME := "PsxVisualsGd4AutoApply"

# Reference to the custom context menu (Right-click in Scene Tree)
var context_menu_plugin: EditorContextMenuPlugin

# Called when the plugin is loaded into the editor
func _enter_tree() -> void:
	# Initialize and register the custom context menu plugin
	context_menu_plugin = PSXContextMenu.new()
	context_menu_plugin.plugin_ref = self
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, context_menu_plugin)

# Called when the plugin is removed or disabled
func _exit_tree() -> void:
	# Unregister the context menu to prevent memory leaks or ghost menu items
	if context_menu_plugin:
		remove_context_menu_plugin(context_menu_plugin)
		context_menu_plugin = null

	# Force-close any leftover plugin dialog windows in the editor UI
	for child in EditorInterface.get_base_control().get_children():
		if child is Window and child.has_meta("psx_plugin_dialog"):
			child.queue_free()

# Triggered when the user manually enables the plugin in Project Settings
func _enable_plugin() -> void:
	# Add the required singletons to the project's Autoload list
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/psx_visuals_gd4/scripts/AutoLoad.gd")
	add_autoload_singleton(AUTOAPPLY_NAME, "res://addons/psx_visuals_gd4/scripts/AutoApply.gd")

	# If the core PSX script exists, trigger initialization of shader globals
	if FileAccess.file_exists("res://addons/psx_visuals_gd4/scripts/Psx.gd"):
		var script = load("res://addons/psx_visuals_gd4/scripts/Psx.gd")
		if script and script.has_method("touch_shader_globals"):
			script.call("touch_shader_globals")

	# Show the initial configuration popup
	_show_install_dialog()

# Triggered when the user disables the plugin
func _disable_plugin() -> void:
	# Remove the singletons from the project
	remove_autoload_singleton(AUTOLOAD_NAME)
	remove_autoload_singleton(AUTOAPPLY_NAME)

	# Create a cleanup UI to ask the user if they want to wipe plugin data from the project
	var cleanup_dialog = ConfirmationDialog.new()
	cleanup_dialog.title = "Cleanup PSX Visuals"
	cleanup_dialog.get_ok_button().text = "Execute Cleanup"
	cleanup_dialog.get_cancel_button().text = "Cancel"

	var vbox = VBoxContainer.new()
	var lbl = Label.new()
	lbl.text = "The plugin has been disabled. Select cleanup actions:"
	vbox.add_child(lbl)
	vbox.add_child(HSeparator.new())

	# Option 1: Remove global shader variables from Project Settings
	var check_globals = CheckBox.new()
	check_globals.text = "Remove Shader Globals (Project Settings)"
	check_globals.button_pressed = false
	vbox.add_child(check_globals)

	var desc_globals = Label.new()
	desc_globals.text = "Removes global shader variables added by this plugin."
	desc_globals.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	desc_globals.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_globals.custom_minimum_size.x = 350
	vbox.add_child(desc_globals)

	vbox.add_child(HSeparator.new())

	# Option 2: Deep scan all .tscn files to remove 'psx_' metadata
	var check_meta = CheckBox.new()
	check_meta.text = "Remove Node Metadata (Scans all scenes)"
	check_meta.button_pressed = false
	vbox.add_child(check_meta)

	var desc_meta = Label.new()
	desc_meta.text = "WARNING: Scans every .tscn/.scn file in the project and removes 'psx_*' metadata. This may take a moment."
	desc_meta.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	desc_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_meta.custom_minimum_size.x = 350
	vbox.add_child(desc_meta)

	cleanup_dialog.add_child(vbox)

	# Handle the cleanup execution when "OK" is pressed
	cleanup_dialog.confirmed.connect(func():
		if check_globals.button_pressed:
			var script = load("res://addons/psx_visuals_gd4/scripts/Psx.gd")
			if script and script.has_method("remove_shader_globals"):
				script.call("remove_shader_globals")
				print("[PSX Visuals] Shader globals removed.")

		if check_meta.button_pressed:
			_perform_metadata_cleanup()

		cleanup_dialog.queue_free()
	)
	cleanup_dialog.canceled.connect(func(): cleanup_dialog.queue_free())

	EditorInterface.get_base_control().add_child(cleanup_dialog)
	cleanup_dialog.reset_size()
	cleanup_dialog.popup_centered()

# Iterates through all project files to remove plugin-specific metadata from scenes
func _perform_metadata_cleanup() -> void:
	print("[PSX Visuals] Starting metadata cleanup...")
	var scene_files: PackedStringArray = []
	_scan_for_scenes("res://", scene_files)

	var modified_count = 0

	for path in scene_files:
		var packed_scene = load(path)
		if packed_scene is PackedScene:
			# Instantiate the scene in memory (including internal state) to edit it
			var root = packed_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
			if root:
				var dirty = _recursive_clean_node(root)
				if dirty:
					# If metadata was found and removed, pack the node back into a scene and save
					var new_packed = PackedScene.new()
					var result = new_packed.pack(root)
					if result == OK:
						ResourceSaver.save(new_packed, path)
						print("[PSX Visuals] Cleaned metadata in: " + path)
						modified_count += 1
					else:
						printerr("[PSX Visuals] Failed to pack scene: " + path)

				root.queue_free()

	print("[PSX Visuals] Cleanup complete. Modified " + str(modified_count) + " files.")

# Helper function to find all scene files recursively
func _scan_for_scenes(path: String, list: PackedStringArray) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				# Avoid hidden folders and the .godot folder
				if file_name != "." and file_name != ".." and file_name != ".godot":
					_scan_for_scenes(path + "/" + file_name, list)
			else:
				if file_name.ends_with(".tscn") or file_name.ends_with(".scn"):
					list.append(path + "/" + file_name)
			file_name = dir.get_next()

# Helper function that travels down a node tree to strip out PSX-specific metadata
func _recursive_clean_node(node: Node) -> bool:
	var changed = false
	var psx_keys = ["psx_disable", "psx_disable_children", "psx_material", "psx_material_children"]

	for key in psx_keys:
		if node.has_meta(key):
			node.remove_meta(key)
			changed = true

	for child in node.get_children():
		if _recursive_clean_node(child):
			changed = true

	return changed

# Shows the setup dialog when the plugin is first enabled
func _show_install_dialog() -> void:
	var dlg = ConfirmationDialog.new()
	dlg.set_meta("psx_plugin_dialog", true) # Marker for cleanup on _exit_tree
	dlg.title = "PSX Visuals Setup"
	dlg.get_ok_button().text = "Apply Settings"

	var vbox = VBoxContainer.new()
	var lbl = Label.new()
	lbl.text = "Plugin enabled successfully!\nSelect components:"
	vbox.add_child(lbl)
	vbox.add_child(HSeparator.new())

	# Option to enable/disable the Dithering Autoload
	var check_dither = CheckBox.new()
	check_dither.text = "Enable Dithering"
	check_dither.button_pressed = true
	vbox.add_child(check_dither)

	var desc_dither = Label.new()
	desc_dither.text = "Adds screen-space dithering."
	desc_dither.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(desc_dither)

	vbox.add_child(HSeparator.new())

	# Option to enable/disable the Auto-Apply Autoload
	var check_apply = CheckBox.new()
	check_apply.text = "Enable Auto-Apply"
	check_apply.button_pressed = true
	vbox.add_child(check_apply)

	var desc_apply = Label.new()
	desc_apply.text = "Automatically swaps materials on load."
	desc_apply.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(desc_apply)

	dlg.add_child(vbox)

	dlg.confirmed.connect(func():
		_set_autoload_state(AUTOLOAD_NAME, check_dither.button_pressed)
		_set_autoload_state(AUTOAPPLY_NAME, check_apply.button_pressed)
		dlg.queue_free()
	)
	dlg.canceled.connect(func(): dlg.queue_free())

	EditorInterface.get_base_control().add_child(dlg)
	dlg.reset_size()
	dlg.popup_centered()

# Safely toggles whether an Autoload is active by modifying the Project Settings string
func _set_autoload_state(name: String, is_enabled: bool) -> void:
	var path = ProjectSettings.get_setting("autoload/" + name)
	if path == null: return
	# Godot marks active Autoloads with a '*' prefix in ProjectSettings
	var clean_path = path.replace("*", "")
	ProjectSettings.set_setting("autoload/" + name, ("*" if is_enabled else "") + clean_path)
	ProjectSettings.save()

# Opens the specific configuration menu for a single Node in the Scene Tree
func _open_config_dialog(node: Node) -> void:
	if not is_instance_valid(node): return

	var dlg = ConfirmationDialog.new()
	dlg.set_meta("psx_plugin_dialog", true)
	dlg.title = "Configure PSX Node: " + node.name

	var vbox = VBoxContainer.new()

	# UI logic for picking Material types (Opaque vs Transparent vs Double-sided)
	var mat_hbox = HBoxContainer.new()
	var mat_label = Label.new()
	mat_label.text = "Material Type (Self):"
	mat_hbox.add_child(mat_label)

	var opt = OptionButton.new()
	opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opt.add_item("Default (Opaque)", 0)
	opt.add_item("Transparent", 1)
	opt.add_item("Opaque Double-Sided", 2)
	opt.add_item("Transparent Double-Sided", 3)
	opt.add_item("--- Inherit / Unset ---", 4)
	mat_hbox.add_child(opt)
	vbox.add_child(mat_hbox)

	# Same logic but applied to children of the current node
	var mat_child_hbox = HBoxContainer.new()
	var mat_child_label = Label.new()
	mat_child_label.text = "Material Type (Children):"
	mat_child_hbox.add_child(mat_child_label)

	var opt_child = OptionButton.new()
	opt_child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opt_child.add_item("Default (Opaque)", 0)
	opt_child.add_item("Transparent", 1)
	opt_child.add_item("Opaque Double-Sided", 2)
	opt_child.add_item("Transparent Double-Sided", 3)
	opt_child.add_item("--- Inherit / Unset ---", 4)
	mat_child_hbox.add_child(opt_child)
	vbox.add_child(mat_child_hbox)

	vbox.add_child(HSeparator.new())

	var chk_disable = CheckBox.new()
	chk_disable.text = "Disable PSX (This Node)"
	vbox.add_child(chk_disable)

	var chk_child = CheckBox.new()
	chk_child.text = "Disable PSX (Children)"
	vbox.add_child(chk_child)

	dlg.add_child(vbox)

	# Pre-load existing metadata into the UI if it exists
	chk_disable.button_pressed = node.get_meta("psx_disable") if node.has_meta("psx_disable") else false
	chk_child.button_pressed = node.get_meta("psx_disable_children") if node.has_meta("psx_disable_children") else false

	var keys = ["opaque", "transparent", "opaque_double", "transparent_double"]

	opt.select(4)
	if node.has_meta("psx_material"):
		var current_val = node.get_meta("psx_material")
		var idx = keys.find(current_val)
		if idx != -1: opt.select(idx)

	opt_child.select(4)
	if node.has_meta("psx_material_children"):
		var current_val = node.get_meta("psx_material_children")
		var idx = keys.find(current_val)
		if idx != -1: opt_child.select(idx)

	# Save the selected settings back into Node Metadata
	dlg.confirmed.connect(func():
		if not is_instance_valid(node):
			dlg.queue_free()
			return

		if chk_disable.button_pressed: node.set_meta("psx_disable", true)
		else: if node.has_meta("psx_disable"): node.remove_meta("psx_disable")

		if chk_child.button_pressed: node.set_meta("psx_disable_children", true)
		else: if node.has_meta("psx_disable_children"): node.remove_meta("psx_disable_children")

		if opt.get_selected_id() < 4:
			node.set_meta("psx_material", keys[opt.get_selected_id()])
		else:
			if node.has_meta("psx_material"): node.remove_meta("psx_material")

		if opt_child.get_selected_id() < 4:
			node.set_meta("psx_material_children", keys[opt_child.get_selected_id()])
		else:
			if node.has_meta("psx_material_children"): node.remove_meta("psx_material_children")

		print("[PSX Visuals] Updated metadata for " + node.name)
		dlg.queue_free()
	)

	dlg.canceled.connect(func(): dlg.queue_free())
	EditorInterface.get_base_control().add_child(dlg)
	dlg.reset_size()
	dlg.popup_centered()

# Inner class handling the right-click menu interaction in the Scene Tree
class PSXContextMenu extends EditorContextMenuPlugin:
	var plugin_ref: EditorPlugin

	func _popup_menu(paths: PackedStringArray) -> void:
		if not is_instance_valid(plugin_ref): return

		# Only show the menu if AutoApply is enabled
		var auto_apply_setting = ProjectSettings.get_setting("autoload/" + plugin_ref.AUTOAPPLY_NAME)
		if not auto_apply_setting or not str(auto_apply_setting).begins_with("*"):
			return

		# Ensure only one node is selected
		if paths.size() != 1: return

		var root = EditorInterface.get_edited_scene_root()
		if not root: return
		var node = root.get_node_or_null(paths[0])

		# Add the custom button to the right-click menu
		if node is Node:
			add_context_menu_item("PSX Visuals Settings", _open_menu)

	# Callback when the context menu item is clicked
	func _open_menu(_arg = null) -> void:
		if is_instance_valid(plugin_ref):
			var selection = EditorInterface.get_selection().get_selected_nodes()
			if selection.size() == 1:
				plugin_ref._open_config_dialog(selection[0])
