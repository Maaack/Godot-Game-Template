class_name AppSettings
extends Node
## Interface to read/write general application settings through [Config].

const INPUT_SECTION = &'InputSettings'
const AUDIO_SECTION = &'AudioSettings'
const VIDEO_SECTION = &'VideoSettings'
const GAME_SECTION = &'GameSettings'
const APPLICATION_SECTION = &'ApplicationSettings'
const CUSTOM_SECTION = &'CustomSettings'

const FULLSCREEN_ENABLED = &'FullscreenEnabled'
const SCREEN_RESOLUTION = &'ScreenResolution'
const MUTE_SETTING = &'Mute'
const MASTER_BUS_INDEX = 0
const SYSTEM_BUS_NAME_PREFIX = "_"

# Input
static var default_action_events : Dictionary
static var initial_bus_volumes : Array

static func get_config_input_events(action_name : String, default = null) -> Array:
	return Config.get_config(INPUT_SECTION, action_name, default)

static func set_config_input_events(action_name : String, inputs : Array) -> void:
	Config.set_config(INPUT_SECTION, action_name, inputs)

static func _clear_config_input_events():
	Config.erase_section(INPUT_SECTION)

static func remove_action_input_event(action_name : String, input_event : InputEvent):
	InputMap.action_erase_event(action_name, input_event)
	var action_events : Array[InputEvent] = InputMap.action_get_events(action_name)
	var config_events : Array = get_config_input_events(action_name, action_events)
	config_events.erase(input_event)
	set_config_input_events(action_name, config_events)

static func set_input_from_config(action_name : String):
	var action_events : Array[InputEvent] = InputMap.action_get_events(action_name)
	var config_events = get_config_input_events(action_name, action_events)
	if config_events == action_events:
		return
	if config_events.is_empty():
		Config.erase_section_key(INPUT_SECTION, action_name)
		return
	InputMap.action_erase_events(action_name)
	for config_event in config_events:
		if config_event not in action_events:
			InputMap.action_add_event(action_name, config_event)

static func _get_action_names() -> Array[StringName]:
	return InputMap.get_actions()

static func _get_custom_action_names() -> Array[StringName]:
	var callable_filter := func(action_name): return not (action_name.begins_with("ui_") or action_name.begins_with("spatial_editor"))
	var action_list := _get_action_names()
	return action_list.filter(callable_filter)

static func get_action_names(built_in_actions : bool = false) -> Array[StringName]:
	if built_in_actions:
		return _get_action_names()
	else:
		return _get_custom_action_names()

static func reset_to_default_inputs() -> void:
	_clear_config_input_events()
	for action_name in default_action_events:
		InputMap.action_erase_events(action_name)
		var input_events = default_action_events[action_name]
		for input_event in input_events:
			InputMap.action_add_event(action_name, input_event)

static func set_default_inputs() -> void:
	var action_list : Array[StringName] = _get_action_names()
	for action_name in action_list:
		default_action_events[action_name] = InputMap.action_get_events(action_name)

static func set_inputs_from_config() -> void:
	var action_list : Array[StringName] = _get_action_names()
	for action_name in action_list:
		set_input_from_config(action_name)

# Audio

static func get_bus_volume(bus_index : int) -> float:
	var initial_linear = 1.0
	if initial_bus_volumes.size() > bus_index:
		initial_linear = initial_bus_volumes[bus_index]
	var linear = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	linear /= initial_linear
	return linear

static func set_bus_volume(bus_index : int, linear : float) -> void:
	var initial_linear = 1.0
	if initial_bus_volumes.size() > bus_index:
		initial_linear = initial_bus_volumes[bus_index]
	linear *= initial_linear
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear))

static func is_muted() -> bool:
	return AudioServer.is_bus_mute(MASTER_BUS_INDEX)

static func set_mute(mute_flag : bool) -> void:
	AudioServer.set_bus_mute(MASTER_BUS_INDEX, mute_flag)

static func get_audio_bus_name(bus_iter : int) -> String:
	return AudioServer.get_bus_name(bus_iter)

static func set_audio_from_config():
	for bus_iter in AudioServer.bus_count:
		var bus_name : String = get_audio_bus_name(bus_iter)
		var bus_volume : float = get_bus_volume(bus_iter)
		initial_bus_volumes.append(bus_volume)
		bus_volume = Config.get_config(AUDIO_SECTION, bus_name, bus_volume)
		if is_nan(bus_volume):
			bus_volume = 1.0
			Config.set_config(AUDIO_SECTION, bus_name, bus_volume)
		set_bus_volume(bus_iter, bus_volume)
	var mute_audio_flag : bool = is_muted()
	mute_audio_flag = Config.get_config(AUDIO_SECTION, MUTE_SETTING, mute_audio_flag)
	set_mute(mute_audio_flag)

# Video

static func set_fullscreen_enabled(value : bool, window : Window) -> void:
	window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (value) else Window.MODE_WINDOWED

static func set_resolution(value : Vector2i, window : Window) -> void:
	if value.x == 0 or value.y == 0:
		return
	window.size = value

static func is_fullscreen(window : Window) -> bool:
	return (window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (window.mode == Window.MODE_FULLSCREEN)

static func get_resolution(window : Window) -> Vector2i:
	var current_resolution : Vector2i = window.size
	current_resolution = Config.get_config(VIDEO_SECTION, SCREEN_RESOLUTION, current_resolution)
	return current_resolution

static func set_video_from_config(window : Window) -> void:
	var fullscreen_enabled : bool = is_fullscreen(window)
	fullscreen_enabled = Config.get_config(VIDEO_SECTION, FULLSCREEN_ENABLED, fullscreen_enabled)
	set_fullscreen_enabled(fullscreen_enabled, window)
	if not (fullscreen_enabled or OS.has_feature("web")):
		var current_resolution : Vector2i = get_resolution(window)
		set_resolution(current_resolution, window)
		
# All

static func set_from_config() -> void:
	set_default_inputs()
	set_inputs_from_config()
	set_audio_from_config()

static func set_from_config_and_window(window : Window) -> void:
	set_from_config()
	set_video_from_config(window)
