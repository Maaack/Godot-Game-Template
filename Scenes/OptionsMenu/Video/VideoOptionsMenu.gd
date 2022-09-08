extends Control

const FULLSCREEN_ENABLED = 'FullscreenEnabled'
const VIDEO_SECTION = 'VideoSettings'

onready var fullscreen_button = $VBoxContainer/FullscreenControl/FullscreenButton

func _update_ui():
	fullscreen_button.pressed = OS.window_fullscreen

func _ready():
	AppSettings.init_video_config()
	_update_ui()

func _on_FullscreenButton_toggled(button_pressed):
	AppSettings.set_fullscreen_enabled(button_pressed)

