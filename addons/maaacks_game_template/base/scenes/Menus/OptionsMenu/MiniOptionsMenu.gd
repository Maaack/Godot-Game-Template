class_name MiniOptionsMenu
extends Control

@onready var mute_control = %MuteControl
@onready var fullscreen_control = %FullscreenControl

@export var audio_control_scene : PackedScene
@export var hide_busses : Array[String]

func _on_bus_changed(bus_value : float, bus_name : String):
	AppSettings.set_bus_volume_from_linear(bus_name, bus_value)

func _add_audio_control(bus_name, bus_value):
	if audio_control_scene == null or bus_name in hide_busses or bus_name.begins_with(AppSettings.SYSTEM_BUS_NAME_PREFIX):
		return
	var audio_control = audio_control_scene.instantiate()
	%AudioControlContainer.call_deferred("add_child", audio_control)
	if audio_control is OptionControl:
		audio_control.option_section = OptionControl.OptionSections.AUDIO
		audio_control.option_name = bus_name
		audio_control.value = bus_value
		audio_control.connect("setting_changed", _on_bus_changed.bind(bus_name))

func _add_audio_bus_controls():
	for bus_iter in AudioServer.bus_count:
		var bus_name : String = AudioServer.get_bus_name(bus_iter)
		var linear : float = AppSettings.get_bus_volume_to_linear(bus_name)
		_add_audio_control(bus_name, linear)

func _update_ui():
	_add_audio_bus_controls()
	mute_control.value = AppSettings.is_muted()
	fullscreen_control.value = AppSettings.is_fullscreen(get_window())

func _sync_with_config() -> void:
	_update_ui()

func _ready():
	_sync_with_config()

func _on_mute_control_setting_changed(value):
	AppSettings.set_mute(value)

func _on_fullscreen_control_setting_changed(value):
	AppSettings.set_fullscreen_enabled(value, get_window())
