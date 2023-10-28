extends Control

const MASTER_AUDIO_BUS = 'Master'
const VOICE_AUDIO_BUS = 'Voice'
const SFX_AUDIO_BUS = 'SFX'
const MUSIC_AUDIO_BUS = 'Music'
const MUTE_SETTING = 'Mute'
const FULLSCREEN_ENABLED = 'FullscreenEnabled'
const AUDIO_SECTION = 'AudioSettings'
const VIDEO_SECTION = 'VideoSettings'

@onready var mute_button = $MuteControl/MuteButton
@onready var fullscreen_button = $FullscreenControl/FullscreenButton

@export var audio_control_scene : PackedScene
@export var hide_busses : Array[String]

func _get_bus_volume_2_linear(bus_name : String) -> float:
	var bus_index : int = AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return 0.0
	var volume_db : float = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)

func _set_bus_volume(bus_name : String, volume_db : float) -> void:
	var bus_index : int = AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	AudioServer.set_bus_volume_db(bus_index, volume_db)

func _set_bus_from_linear(bus_name : String, linear : float) -> void:
	var volume_db : float = linear_to_db(linear)
	_set_bus_volume(bus_name, volume_db)
	Config.set_config(AUDIO_SECTION, bus_name, linear)

func _is_muted() -> bool:
	var bus_index : int = AudioServer.get_bus_index(MASTER_AUDIO_BUS)
	return AudioServer.is_bus_mute(bus_index)

func _set_mute(mute_flag : bool) -> void:
	var bus_index : int = AudioServer.get_bus_index(MASTER_AUDIO_BUS)
	AudioServer.set_bus_mute(bus_index, mute_flag)
	Config.set_config(AUDIO_SECTION, MUTE_SETTING, mute_flag)

func _add_audio_control(bus_name, bus_value):
	if audio_control_scene == null or bus_name in hide_busses:
		return
	var audio_control = audio_control_scene.instantiate()
	audio_control.bus_name = bus_name
	audio_control.bus_value = bus_value
	%AudioBusesContainer.call_deferred("add_child", audio_control)
	audio_control.connect("bus_value_changed", _set_bus_from_linear)

func _add_audio_bus_controls():
	var bus_count : int = AudioServer.bus_count
	for bus_iter in bus_count:
		var bus_name : String = AudioServer.get_bus_name(bus_iter)
		var bus_volume_db : float = AudioServer.get_bus_volume_db(bus_iter)
		_add_audio_control(bus_name, db_to_linear(bus_volume_db))

func _update_ui():
	_add_audio_bus_controls()
	mute_button.button_pressed = _is_muted()
	fullscreen_button.button_pressed = ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))

func _set_init_config_if_empty() -> void:
	if not Config.has_section(VIDEO_SECTION):
		Config.set_config(VIDEO_SECTION, FULLSCREEN_ENABLED, ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)))
	if not Config.has_section(AUDIO_SECTION):
		Config.set_config(AUDIO_SECTION, MASTER_AUDIO_BUS, _get_bus_volume_2_linear(MASTER_AUDIO_BUS))
		Config.set_config(AUDIO_SECTION, SFX_AUDIO_BUS, _get_bus_volume_2_linear(SFX_AUDIO_BUS))
		Config.set_config(AUDIO_SECTION, VOICE_AUDIO_BUS, _get_bus_volume_2_linear(VOICE_AUDIO_BUS))
		Config.set_config(AUDIO_SECTION, MUSIC_AUDIO_BUS, _get_bus_volume_2_linear(MUSIC_AUDIO_BUS))
		Config.set_config(AUDIO_SECTION, MUTE_SETTING, _is_muted())


func _set_init_config():
	Config.set_config(AUDIO_SECTION, MASTER_AUDIO_BUS, _get_bus_volume_2_linear(MASTER_AUDIO_BUS))
	Config.set_config(AUDIO_SECTION, SFX_AUDIO_BUS, _get_bus_volume_2_linear(SFX_AUDIO_BUS))
	Config.set_config(AUDIO_SECTION, VOICE_AUDIO_BUS, _get_bus_volume_2_linear(VOICE_AUDIO_BUS))
	Config.set_config(AUDIO_SECTION, MUSIC_AUDIO_BUS, _get_bus_volume_2_linear(MUSIC_AUDIO_BUS))
	Config.set_config(AUDIO_SECTION, MUTE_SETTING, _is_muted())

func _set_fullscreen_enabled_from_config() -> void:
	var fullscreen_enabled : bool = ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))
	fullscreen_enabled = Config.get_config(VIDEO_SECTION, FULLSCREEN_ENABLED, fullscreen_enabled)
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (fullscreen_enabled) else Window.MODE_WINDOWED

func _set_fullscreen_enabled(value : bool) -> void:
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (value) else Window.MODE_WINDOWED
	Config.set_config(VIDEO_SECTION, FULLSCREEN_ENABLED, value)

func _set_audio_buses_from_config():
	if not Config.has_section(AUDIO_SECTION):
		_set_init_config()
	var master_audio_value : float = _get_bus_volume_2_linear(MASTER_AUDIO_BUS)
	var sfx_audio_value : float = _get_bus_volume_2_linear(MASTER_AUDIO_BUS)
	var voice_audio_value : float = _get_bus_volume_2_linear(MASTER_AUDIO_BUS)
	var music_audio_value : float = _get_bus_volume_2_linear(MASTER_AUDIO_BUS)
	var mute_audio_flag : bool = _is_muted()
	master_audio_value = Config.get_config(AUDIO_SECTION, MASTER_AUDIO_BUS, master_audio_value)
	sfx_audio_value = Config.get_config(AUDIO_SECTION, SFX_AUDIO_BUS, sfx_audio_value)
	voice_audio_value = Config.get_config(AUDIO_SECTION, VOICE_AUDIO_BUS, voice_audio_value)
	music_audio_value = Config.get_config(AUDIO_SECTION, MUSIC_AUDIO_BUS, music_audio_value)
	mute_audio_flag = Config.get_config(AUDIO_SECTION, MUTE_SETTING, mute_audio_flag)
	_set_bus_from_linear(MASTER_AUDIO_BUS, master_audio_value)
	_set_bus_from_linear(SFX_AUDIO_BUS, sfx_audio_value)
	_set_bus_from_linear(VOICE_AUDIO_BUS, voice_audio_value)
	_set_bus_from_linear(MUSIC_AUDIO_BUS, music_audio_value)
	_set_mute(mute_audio_flag)

func _sync_with_config() -> void:
	_set_init_config_if_empty()
	_set_fullscreen_enabled_from_config()
	_set_audio_buses_from_config()
	_update_ui()

func _ready():
	_sync_with_config()

func _on_mute_button_toggled(button_pressed):
	_set_mute(button_pressed)

func _on_fullscreen_button_toggled(button_pressed):
	_set_fullscreen_enabled(button_pressed)

func _on_reset_game_control_reset_confirmed():
	GameLog.reset_game_data()
