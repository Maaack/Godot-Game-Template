extends Control

const FULLSCREEN_ENABLED = 'FullscreenEnabled'
const VIDEO_SECTION = 'VideoSettings'

onready var fullscreen_button = $VBoxContainer/FullscreenControl/FullscreenButton

func _update_ui():
	fullscreen_button.pressed = OS.window_fullscreen

func _set_init_config_if_empty() -> void:
	if Config.has_section(VIDEO_SECTION):
		return
	Config.set_config(VIDEO_SECTION, FULLSCREEN_ENABLED, OS.window_fullscreen)

func _set_fullscreen_enabled_from_config() -> void:
	var fullscreen_enabled : bool = OS.window_fullscreen
	fullscreen_enabled = Config.get_config(VIDEO_SECTION, FULLSCREEN_ENABLED, fullscreen_enabled)
	OS.window_fullscreen = fullscreen_enabled

func _set_fullscreen_enabled(value : bool) -> void:
	OS.window_fullscreen = value
	Config.set_config(VIDEO_SECTION, FULLSCREEN_ENABLED, value)

func _sync_with_config() -> void:
	_set_init_config_if_empty()
	_set_fullscreen_enabled_from_config()
	_update_ui()

func _ready():
	_sync_with_config()

func _on_FullscreenButton_toggled(button_pressed):
	_set_fullscreen_enabled(button_pressed)

