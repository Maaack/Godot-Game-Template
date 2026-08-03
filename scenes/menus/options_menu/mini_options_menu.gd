extends Control

## Scene for adjusting the volume of the audio busses.
@export var audio_control_scene : PackedScene
## Optional names of audio busses that should be ignored.
@export var hide_busses : Array[String]

@onready var fullscreen_control = %FullscreenControl
@onready var resolution_control = %ResolutionControl

func _on_bus_changed(bus_value : float, bus_iter : int) -> void:
	AppSettings.set_bus_volume(bus_iter, bus_value)

func _add_audio_control(bus_name : String, bus_value : float, bus_iter : int) -> void:
	if audio_control_scene == null or bus_name in hide_busses or bus_name.begins_with(AppSettings.SYSTEM_BUS_NAME_PREFIX):
		return
	var audio_control = audio_control_scene.instantiate()
	%AudioControlContainer.call_deferred("add_child", audio_control)
	if audio_control is OptionControl:
		audio_control.option_section = OptionControl.OptionSections.AUDIO
		audio_control.option_name = bus_name
		audio_control.value = bus_value
		audio_control.connect("setting_changed", _on_bus_changed.bind(bus_iter))

func _add_audio_bus_controls() -> void:
	for bus_iter in AudioServer.bus_count:
		var bus_name : String = AppSettings.get_audio_bus_name(bus_iter)
		var linear : float = AppSettings.get_bus_volume(bus_iter)
		_add_audio_control(bus_name, linear, bus_iter)

func _preselect_resolution(window : Window) -> void:
	resolution_control.value = window.size

func _update_resolution_options_enabled(window : Window) -> void:
	if OS.has_feature("web"):
		resolution_control.editable = false
		resolution_control.tooltip_text = "Disabled for web"
	elif AppSettings.is_fullscreen(window):
		resolution_control.editable = false
		resolution_control.tooltip_text = "Disabled for fullscreen"
	else:
		resolution_control.editable = true
		resolution_control.tooltip_text = "Select a screen size"

func _update_ui(window:Window) -> void:
	_add_audio_bus_controls()
	fullscreen_control.value = AppSettings.is_fullscreen(get_window())
	_preselect_resolution(window)

func _ready() -> void:
	var window : Window = get_window()
	_update_ui(window)
	window.connect("size_changed", _preselect_resolution.bind(window))

func _on_mute_control_setting_changed(value : bool) -> void:
	AppSettings.set_mute(value)

func _on_fullscreen_control_setting_changed(value : bool) -> void:
	var window := get_window()
	AppSettings.set_fullscreen_enabled(value, window)
	_update_resolution_options_enabled(window)

func _on_resolution_control_setting_changed(value) -> void:
	AppSettings.set_resolution(value, get_window(), false)
