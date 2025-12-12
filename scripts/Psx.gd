
class_name Psx

const GLOBAL_VAR_AFFINE_STRENGTH := &"psx_affine_strength"
const GLOBAL_VAR_BIT_DEPTH := &"psx_bit_depth"
const GLOBAL_VAR_FOG_COLOR := &"psx_fog_color"
const GLOBAL_VAR_FOG_FAR := &"psx_fog_near"
const GLOBAL_VAR_FOG_NEAR := &"psx_fog_far"
const GLOBAL_VAR_SNAP_DISTANCE := &"psx_snap_size"

const SETTING_GLOBAL_VAR_AFFINE_STRENGTH := "shader_globals/" + GLOBAL_VAR_AFFINE_STRENGTH
const SETTING_GLOBAL_VAR_BIT_DEPTH := "shader_globals/" + GLOBAL_VAR_BIT_DEPTH
const SETTING_GLOBAL_VAR_FOG_COLOR := "shader_globals/" + GLOBAL_VAR_FOG_COLOR
const SETTING_GLOBAL_VAR_FOG_FAR := "shader_globals/" + GLOBAL_VAR_FOG_FAR
const SETTING_GLOBAL_VAR_FOG_NEAR := "shader_globals/" + GLOBAL_VAR_FOG_NEAR
const SETTING_GLOBAL_VAR_SNAP_DISTANCE := "shader_globals/" + GLOBAL_VAR_SNAP_DISTANCE

static func set_affine_strength(value: float) -> void:
	RenderingServer.global_shader_parameter_set(GLOBAL_VAR_AFFINE_STRENGTH, value)

static func set_bit_depth(value: int) -> void:
	RenderingServer.global_shader_parameter_set(GLOBAL_VAR_BIT_DEPTH, clampi(value, 1, 8))

static func set_fog_color(value: Color = Color.TRANSPARENT) -> void:
	RenderingServer.global_shader_parameter_set(GLOBAL_VAR_FOG_COLOR, value)

static func set_fog_far(value: float) -> void:
	RenderingServer.global_shader_parameter_set(GLOBAL_VAR_FOG_FAR, value)

static func set_fog_near(value: float) -> void:
	RenderingServer.global_shader_parameter_set(GLOBAL_VAR_FOG_NEAR, value)

static func set_snap_distance(value: float) -> void:
	RenderingServer.global_shader_parameter_set(GLOBAL_VAR_SNAP_DISTANCE, value)

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