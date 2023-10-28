extends Node
class_name AppSettings

const INPUT_SECTION = 'InputSettings'
const AUDIO_SECTION = 'AudioSettings'
const VIDEO_SECTION = 'VideoSettings'

const FULLSCREEN_ENABLED = 'FullscreenEnabled'
const MASTER_AUDIO_BUS = 'Master'
const VOICE_AUDIO_BUS = 'Voice'
const SFX_AUDIO_BUS = 'SFX'
const MUSIC_AUDIO_BUS = 'Music'
const MUTE_SETTING = 'Mute'
const MASTER_BUS_INDEX = 0

const INPUT_MAP_2D : Dictionary = {
	"move_up" : "Up",
	"move_down" : "Down",
	"move_left" : "Left",
	"move_right" : "Right",
	"dash" : "Dash",
	"interact" : "Interact",
}

const INPUT_MAP_3D : Dictionary = {
	"move_forward" : "Forward",
	"move_backward" : "Backward",
	"move_left" : "Left",
	"move_right" : "Right",
	"run" : "Run",
	"jump" : "Jump",
	"interact" : "Interact",
}
const INPUT_MAP = INPUT_MAP_2D
# Input

static func get_action_scancode(action_name : String, default = null) -> int:
	return Config.get_config(INPUT_SECTION, action_name, default)

static func set_action_scancode(action_name : String, keycode : int) -> void:
	Config.set_config(INPUT_SECTION, action_name, keycode)

static func get_input_actions() -> Array:
	return Config.get_section_keys(INPUT_SECTION)

static func get_input_event_scancode(action_event : InputEventKey) -> int:
	if action_event.keycode != 0:
		return action_event.get_keycode_with_modifiers()
	else:
		return action_event.get_physical_keycode_with_modifiers()

static func reset_input_config() -> void:
	for action_name in INPUT_MAP.keys():
		var action_events : Array = InputMap.action_get_events(action_name)
		if action_events.size() == 0:
			continue
		var action_event : InputEventWithModifiers = action_events[0]
		if action_event is InputEventKey:
			set_action_scancode(action_name, get_input_event_scancode(action_event))

static func set_input_from_config(action_name : String) -> void:
	var keycode = get_action_scancode(action_name)
	var event = InputEventKey.new()
	event.keycode = keycode
	for old_event in InputMap.action_get_events(action_name):
		if old_event is InputEventKey:
			InputMap.action_erase_event(action_name, old_event)
	InputMap.action_add_event(action_name, event)

static func set_inputs_from_config() -> void:
	for action_name in get_input_actions():
		set_input_from_config(action_name)

static func init_input_config() -> void:
	if not Config.has_section(INPUT_SECTION):
		# reset_input_config()
		return
	set_inputs_from_config()

# Audio

static func get_bus_volume(bus_name : String) -> float:
	var bus_index : int = AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return 0.0
	var volume_db : float = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)

static func set_bus_volume(bus_name : String, volume_db : float) -> void:
	var bus_index : int = AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	Config.set_config(AUDIO_SECTION, bus_name, volume_db)

static func set_bus_volume_from_linear(bus_name : String, linear : float) -> void:
	set_bus_volume(bus_name, linear_to_db(linear))

static func is_muted() -> bool:
	return AudioServer.is_bus_mute(MASTER_BUS_INDEX)

static func set_mute(mute_flag : bool) -> void:
	AudioServer.set_bus_mute(MASTER_BUS_INDEX, mute_flag)
	Config.set_config(AUDIO_SECTION, MUTE_SETTING, mute_flag)

static func set_audio_from_config():
	for bus_iter in AudioServer.bus_count:
		var bus_name : String = AudioServer.get_bus_name(bus_iter)
		var bus_volume_db : float = AudioServer.get_bus_volume_db(bus_iter)
		bus_volume_db = Config.get_config(AUDIO_SECTION, bus_name, bus_volume_db)
		AudioServer.set_bus_volume_db(bus_iter, bus_volume_db)
	var mute_audio_flag : bool = is_muted()
	mute_audio_flag = Config.get_config(AUDIO_SECTION, MUTE_SETTING, mute_audio_flag)
	set_mute(mute_audio_flag)

static func init_audio_config() -> void:
	set_audio_from_config()

# Video

static func set_fullscreen_enabled(value : bool, window : Window) -> void:
	window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (value) else Window.MODE_WINDOWED
	Config.set_config(VIDEO_SECTION, FULLSCREEN_ENABLED, value)

static func reset_video_config(window : Window) -> void:
	Config.set_config(VIDEO_SECTION, FULLSCREEN_ENABLED, ((window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (window.mode == Window.MODE_FULLSCREEN)))

static func is_fullscreen(window : Window) -> bool:
	return (window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (window.mode == Window.MODE_FULLSCREEN)

static func set_video_from_config(window : Window) -> void:
	var fullscreen_enabled : bool = (window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (window.mode == Window.MODE_FULLSCREEN)
	fullscreen_enabled = Config.get_config(VIDEO_SECTION, FULLSCREEN_ENABLED, fullscreen_enabled)
	window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (fullscreen_enabled) else Window.MODE_WINDOWED

static func init_video_config(window : Window) -> void:
	if not Config.has_section(VIDEO_SECTION):
		# reset_video_config()
		return
	set_video_from_config(window)

# All

static func initialize_from_config(window : Window) -> void:
	init_input_config()
	init_audio_config()
	init_video_config(window)
