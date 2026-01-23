class_name Psx

const GLOBAL_VAR_AFFINE_STRENGTH := &"psx_affine_strength"
const GLOBAL_VAR_BIT_DEPTH := &"psx_bit_depth"
const GLOBAL_VAR_FOG_COLOR := &"psx_fog_color"
const GLOBAL_VAR_FOG_FAR := &"psx_fog_far"
const GLOBAL_VAR_FOG_NEAR := &"psx_fog_near"
const GLOBAL_VAR_SNAP_DISTANCE := &"psx_snap_distance"

const SETTING_GLOBAL_VAR_AFFINE_STRENGTH := "shader_globals/" + GLOBAL_VAR_AFFINE_STRENGTH
const SETTING_GLOBAL_VAR_BIT_DEPTH := "shader_globals/" + GLOBAL_VAR_BIT_DEPTH
const SETTING_GLOBAL_VAR_FOG_COLOR := "shader_globals/" + GLOBAL_VAR_FOG_COLOR
const SETTING_GLOBAL_VAR_FOG_FAR := "shader_globals/" + GLOBAL_VAR_FOG_FAR
const SETTING_GLOBAL_VAR_FOG_NEAR := "shader_globals/" + GLOBAL_VAR_FOG_NEAR
const SETTING_GLOBAL_VAR_SNAP_DISTANCE := "shader_globals/" + GLOBAL_VAR_SNAP_DISTANCE

static var _affine_strength : float
static var affine_strength : float :
	get: return _affine_strength
	set(value):
		_affine_strength = value
		RenderingServer.global_shader_parameter_set(GLOBAL_VAR_AFFINE_STRENGTH, value)

static var _bit_depth : int
static var bit_depth : int :
	get: return _bit_depth
	set(value):
		_bit_depth = value
		RenderingServer.global_shader_parameter_set(GLOBAL_VAR_BIT_DEPTH, value)

static var _fog_color : Color
static var fog_color : Color :
	get: return _fog_color
	set(value):
		_fog_color = value
		RenderingServer.global_shader_parameter_set(GLOBAL_VAR_FOG_COLOR, value)

static var _fog_far : float
static var fog_far : float :
	get: return _fog_far
	set(value):
		_fog_far = value
		RenderingServer.global_shader_parameter_set(GLOBAL_VAR_FOG_FAR, value)

static var _fog_near : float
static var fog_near : float :
	get: return _fog_near
	set(value):
		_fog_near = value
		RenderingServer.global_shader_parameter_set(GLOBAL_VAR_FOG_NEAR, value)

static var _snap_distance : float
static var snap_distance : float :
	get: return _snap_distance
	set(value):
		_snap_distance = value
		RenderingServer.global_shader_parameter_set(GLOBAL_VAR_SNAP_DISTANCE, value)

static func _static_init() -> void:
	# Ensure settings exist before trying to access them to avoid dictionary errors
	if not ProjectSettings.has_setting(SETTING_GLOBAL_VAR_AFFINE_STRENGTH): touch_shader_globals()

	_affine_strength = ProjectSettings.get_setting(SETTING_GLOBAL_VAR_AFFINE_STRENGTH)[&"value"]
	_bit_depth = ProjectSettings.get_setting(SETTING_GLOBAL_VAR_BIT_DEPTH)[&"value"]
	_fog_color = ProjectSettings.get_setting(SETTING_GLOBAL_VAR_FOG_COLOR)[&"value"]
	_fog_far = ProjectSettings.get_setting(SETTING_GLOBAL_VAR_FOG_FAR)[&"value"]
	_fog_near = ProjectSettings.get_setting(SETTING_GLOBAL_VAR_FOG_NEAR)[&"value"]
	_snap_distance = ProjectSettings.get_setting(SETTING_GLOBAL_VAR_SNAP_DISTANCE)[&"value"]

static func touch_shader_globals() -> void:
	var any_setting_changed := false

	if not ProjectSettings.has_setting(SETTING_GLOBAL_VAR_AFFINE_STRENGTH):
		ProjectSettings.set_setting(SETTING_GLOBAL_VAR_AFFINE_STRENGTH, {
			"type": "float",
			"value": 1.0
		})
		any_setting_changed = true
	if not ProjectSettings.has_setting(SETTING_GLOBAL_VAR_BIT_DEPTH):
		ProjectSettings.set_setting(SETTING_GLOBAL_VAR_BIT_DEPTH, {
			"type": "int",
			"value": 5
		})
		any_setting_changed = true
	if not ProjectSettings.has_setting(SETTING_GLOBAL_VAR_FOG_COLOR):
		ProjectSettings.set_setting(SETTING_GLOBAL_VAR_FOG_COLOR, {
			"type": "color",
			"value": Color(0.5, 0.5, 0.5, 0.0)
		})
		any_setting_changed = true
	if not ProjectSettings.has_setting(SETTING_GLOBAL_VAR_FOG_FAR):
		ProjectSettings.set_setting(SETTING_GLOBAL_VAR_FOG_FAR, {
			"type": "float",
			"value": 20.0
		})
		any_setting_changed = true
	if not ProjectSettings.has_setting(SETTING_GLOBAL_VAR_FOG_NEAR):
		ProjectSettings.set_setting(SETTING_GLOBAL_VAR_FOG_NEAR, {
			"type": "float",
			"value": 10.0
		})
		any_setting_changed = true
	if not ProjectSettings.has_setting(SETTING_GLOBAL_VAR_SNAP_DISTANCE):
		ProjectSettings.set_setting(SETTING_GLOBAL_VAR_SNAP_DISTANCE, {
			"type": "float",
			"value": 0.025
		})
		any_setting_changed = true

	if any_setting_changed:
		ProjectSettings.save()

static func remove_shader_globals() -> void:
	var settings_to_remove = [
		SETTING_GLOBAL_VAR_AFFINE_STRENGTH,
		SETTING_GLOBAL_VAR_BIT_DEPTH,
		SETTING_GLOBAL_VAR_FOG_COLOR,
		SETTING_GLOBAL_VAR_FOG_FAR,
		SETTING_GLOBAL_VAR_FOG_NEAR,
		SETTING_GLOBAL_VAR_SNAP_DISTANCE
	]

	var changed = false
	for setting in settings_to_remove:
		if ProjectSettings.has_setting(setting):
			ProjectSettings.clear(setting)
			changed = true

	if changed:
		ProjectSettings.save()
		print("PSX Visuals: Shader globals successfully removed.")
