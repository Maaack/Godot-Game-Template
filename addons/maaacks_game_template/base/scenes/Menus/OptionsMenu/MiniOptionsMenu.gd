extends Control

@onready var mute_button = $MuteControl/MuteButton
@onready var fullscreen_button = $FullscreenControl/FullscreenButton

@export var audio_control_scene : PackedScene
@export var hide_busses : Array[String]

func _add_audio_control(bus_name, bus_value):
	if audio_control_scene == null or bus_name in hide_busses:
		return
	var audio_control = audio_control_scene.instantiate()
	audio_control.bus_name = bus_name
	audio_control.bus_value = bus_value
	%AudioControlContainer.call_deferred("add_child", audio_control)
	audio_control.connect("bus_value_changed", AppSettings.set_bus_volume_from_linear)

func _add_audio_bus_controls():
	for bus_iter in AudioServer.bus_count:
		var bus_name : String = AudioServer.get_bus_name(bus_iter)
		var linear : float = AppSettings.get_bus_volume_to_linear(bus_name)
		_add_audio_control(bus_name, linear)

func _update_ui():
	_add_audio_bus_controls()
	mute_button.button_pressed = AppSettings.is_muted()
	fullscreen_button.button_pressed = AppSettings.is_fullscreen(get_window())

func _sync_with_config() -> void:
	_update_ui()

func _ready():
	_sync_with_config()

func _on_mute_button_toggled(button_pressed):
	AppSettings.set_mute(button_pressed)

func _on_fullscreen_button_toggled(button_pressed):
	AppSettings.set_fullscreen_enabled(button_pressed, get_window())
