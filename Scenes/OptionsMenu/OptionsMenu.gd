extends Control

signal return_button_pressed

const MASTER_AUDIO_BUS = 'Master'
const VOICE_AUDIO_BUS = 'Voice'
const SFX_AUDIO_BUS = 'SFX'
const MUSIC_AUDIO_BUS = 'Music'
const MUTE_SETTING = 'Mute'
const FULLSCREEN_ENABLED = 'FullscreenEnabled'
const AUDIO_SECTION = 'AudioSettings'
const VIDEO_SECTION = 'VideoSettings'

onready var master_slider = $MasterControl/MasterHSlider
onready var sfx_slider = $SFXControl/SFXHSlider
onready var voice_slider = $VoiceControl/VoiceHSlider
onready var music_slider = $MusicControl/MusicHSlider
onready var mute_button = $MuteControl/MuteButton
onready var fullscreen_button = $FullscreenControl/FullscreenButton

var play_audio_streams : bool = false

func _get_bus_volume_2_linear(bus_name : String) -> float:
	var bus_index : int = AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return 0.0
	var volume_db : float = AudioServer.get_bus_volume_db(bus_index)
	return db2linear(volume_db)

func _set_bus_linear_2_volume(bus_name : String, linear : float) -> void:
	var bus_index : int = AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	var volume_db : float = linear2db(linear)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	Config.set_config(AUDIO_SECTION, bus_name, linear)

func _is_muted() -> bool:
	var bus_index : int = AudioServer.get_bus_index(MASTER_AUDIO_BUS)
	return AudioServer.is_bus_mute(bus_index)

func _set_mute(mute_flag : bool) -> void:
	var bus_index : int = AudioServer.get_bus_index(MASTER_AUDIO_BUS)
	AudioServer.set_bus_mute(bus_index, mute_flag)
	Config.set_config(AUDIO_SECTION, MUTE_SETTING, mute_flag)

func _play_next_audio_stream(_stream_parent : Node) -> void:
	pass

func _play_next_vocal_audio_stream() -> void:
	_play_next_audio_stream($VocalAudioStreamPlayers)

func _play_next_sfx_audio_stream() -> void:
	_play_next_audio_stream($SFXAudioStreamPlayers)

func _update_ui():
	master_slider.value = _get_bus_volume_2_linear(MASTER_AUDIO_BUS)
	sfx_slider.value = _get_bus_volume_2_linear(SFX_AUDIO_BUS)
	voice_slider.value = _get_bus_volume_2_linear(VOICE_AUDIO_BUS)
	music_slider.value = _get_bus_volume_2_linear(MUSIC_AUDIO_BUS)
	mute_button.pressed = _is_muted()
	fullscreen_button.pressed = OS.window_fullscreen

func _set_init_config_if_empty() -> void:
	if not Config.has_section(VIDEO_SECTION):
		Config.set_config(VIDEO_SECTION, FULLSCREEN_ENABLED, OS.window_fullscreen)
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
	var fullscreen_enabled : bool = OS.window_fullscreen
	fullscreen_enabled = Config.get_config(VIDEO_SECTION, FULLSCREEN_ENABLED, fullscreen_enabled)
	OS.window_fullscreen = fullscreen_enabled

func _set_fullscreen_enabled(value : bool) -> void:
	OS.window_fullscreen = value
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
	_set_bus_linear_2_volume(MASTER_AUDIO_BUS, master_audio_value)
	_set_bus_linear_2_volume(SFX_AUDIO_BUS, sfx_audio_value)
	_set_bus_linear_2_volume(VOICE_AUDIO_BUS, voice_audio_value)
	_set_bus_linear_2_volume(MUSIC_AUDIO_BUS, music_audio_value)
	_set_mute(mute_audio_flag)

func _sync_with_config() -> void:
	_set_init_config_if_empty()
	_set_fullscreen_enabled_from_config()
	_set_audio_buses_from_config()
	_update_ui()

func _ready():
	_sync_with_config()

func _on_ReturnButton_pressed():
	emit_signal("return_button_pressed")

func _on_MasterHSlider_value_changed(value):
	_set_bus_linear_2_volume(MASTER_AUDIO_BUS, value)

func _on_SFXHSlider_value_changed(value):
	_set_bus_linear_2_volume(SFX_AUDIO_BUS, value)
	_play_next_sfx_audio_stream()

func _on_VoiceHSlider_value_changed(value):
	_set_bus_linear_2_volume(VOICE_AUDIO_BUS, value)
	_play_next_vocal_audio_stream()

func _on_MusicHSlider_value_changed(value):
	_set_bus_linear_2_volume(MUSIC_AUDIO_BUS, value)

func _on_MuteButton_toggled(button_pressed):
	_set_mute(button_pressed)

func _on_FullscreenButton_toggled(button_pressed):
	_set_fullscreen_enabled(button_pressed)

func _on_ResetGameControl_reset_confirmed():
	GameLog.reset_game_data()

func _unhandled_key_input(event):
	if event.is_action_released('ui_mute'):
		mute_button.pressed = !(mute_button.pressed)
