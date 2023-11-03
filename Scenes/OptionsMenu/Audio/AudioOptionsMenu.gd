extends Control

@export var audio_control_scene : PackedScene
@export var hide_busses : Array[String]

@onready var mute_button = $VBoxContainer/MuteControl/MuteButton

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

func _ready():
	_update_ui()

func _on_MuteButton_toggled(button_pressed):
	AppSettings.set_mute(button_pressed)
