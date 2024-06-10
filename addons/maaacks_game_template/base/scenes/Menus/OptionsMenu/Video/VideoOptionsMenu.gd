class_name VideoOptionsMenu
extends Control

func _preselect_resolution(window : Window):
	%ResolutionControl.value = window.size

func _update_resolution_options_enabled(window : Window):
	if OS.has_feature("web"):
		%ResolutionControl.editable = false
		%ResolutionControl.tooltip_text = "Disabled for web"
	elif AppSettings.is_fullscreen(window):
		%ResolutionControl.editable = false
		%ResolutionControl.tooltip_text = "Disabled for fullscreen"
	else:
		%ResolutionControl.editable = true
		%ResolutionControl.tooltip_text = "Select a screen size"

func _update_ui(window : Window):
	%FullscreenControl.value = AppSettings.is_fullscreen(window)
	_preselect_resolution(window)
	_update_resolution_options_enabled(window)

func _ready():
	var window : Window = get_window()
	_update_ui(window)
	window.connect("size_changed", _preselect_resolution.bind(window))

func _on_fullscreen_control_setting_changed(value):
	var window : Window = get_window()
	AppSettings.set_fullscreen_enabled(value, window)
	_update_resolution_options_enabled(window)

func _on_resolution_control_setting_changed(value):
	AppSettings.set_resolution(value, get_window())
