extends Control

onready var master_slider = $VBoxContainer/MasterControl/MasterHSlider
onready var sfx_slider = $VBoxContainer/SFXControl/SFXHSlider
onready var voice_slider = $VBoxContainer/VoiceControl/VoiceHSlider
onready var music_slider = $VBoxContainer/MusicControl/MusicHSlider
onready var mute_button = $VBoxContainer/MuteControl/MuteButton

var play_audio_streams : bool = false

func _play_next_audio_stream(_stream_parent : Node) -> void:
	pass

func _play_next_vocal_audio_stream() -> void:
	_play_next_audio_stream($VocalAudioStreamPlayers)

func _play_next_sfx_audio_stream() -> void:
	_play_next_audio_stream($SFXAudioStreamPlayers)

func _update_ui():
	master_slider.value = AppSettings.get_bus_volume(AppSettings.MASTER_AUDIO_BUS)
	sfx_slider.value = AppSettings.get_bus_volume(AppSettings.SFX_AUDIO_BUS)
	voice_slider.value = AppSettings.get_bus_volume(AppSettings.VOICE_AUDIO_BUS)
	music_slider.value = AppSettings.get_bus_volume(AppSettings.MUSIC_AUDIO_BUS)
	mute_button.pressed = AppSettings.is_muted()

func _ready():
	AppSettings.init_audio_config()
	_update_ui()

func _on_MasterHSlider_value_changed(value):
	AppSettings.set_bus_volume(AppSettings.MASTER_AUDIO_BUS, value)

func _on_SFXHSlider_value_changed(value):
	AppSettings.set_bus_volume(AppSettings.SFX_AUDIO_BUS, value)
	_play_next_sfx_audio_stream()

func _on_VoiceHSlider_value_changed(value):
	AppSettings.set_bus_volume(AppSettings.VOICE_AUDIO_BUS, value)
	_play_next_vocal_audio_stream()

func _on_MusicHSlider_value_changed(value):
	AppSettings.set_bus_volume(AppSettings.MUSIC_AUDIO_BUS, value)

func _on_MuteButton_toggled(button_pressed):
	AppSettings.set_mute(button_pressed)

func _unhandled_key_input(event):
	if event.is_action_released('ui_mute'):
		mute_button.pressed = !(mute_button.pressed)
