extends Control

@export var resolutions_array : Array[Vector2i] = [
	Vector2i(640, 360),
	Vector2i(960, 540),
	Vector2i(1024, 576),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2048, 1152),
	Vector2i(2560, 1440),
	Vector2i(3200, 1800),
	Vector2i(3840, 2160),
]

@onready var fullscreen_button = %FullscreenButton
@onready var resolution_options = %ResolutionOptions
@onready var user_resolutions_array : Array[Vector2i] = resolutions_array.duplicate()

func _preselect_resolution(window : Window):
	var current_resolution : Vector2i = window.size
	if not current_resolution in user_resolutions_array:
		user_resolutions_array.append(current_resolution)
		user_resolutions_array.sort()
	resolution_options.clear()
	for resolution in user_resolutions_array:
		var resolution_string : String = "%d x %d" % [resolution.x, resolution.y]
		resolution_options.add_item(resolution_string)
		if not resolution in resolutions_array:
			var last_index : int = resolution_options.item_count - 1
			resolution_options.set_item_disabled(last_index, true)
	var current_resolution_index : int = user_resolutions_array.find(current_resolution)
	resolution_options.select(current_resolution_index)

func _update_resolution_options_enabled(window : Window):
	if OS.has_feature("web"):
		resolution_options.disabled = true
		resolution_options.tooltip_text = "Disabled for web"
	elif AppSettings.is_fullscreen(window):
		resolution_options.disabled = true
		resolution_options.tooltip_text = "Disabled for fullscreen"
	else:
		resolution_options.disabled = false
		resolution_options.tooltip_text = "Select a screen size"

func _update_ui(window : Window):
	fullscreen_button.button_pressed = AppSettings.is_fullscreen(window)
	_preselect_resolution(window)
	_update_resolution_options_enabled(window)

func _ready():
	var window : Window = get_window()
	_update_ui(window)
	window.connect("size_changed", _preselect_resolution.bind(window))

func _on_fullscreen_button_toggled(toggled_on):
	var window : Window = get_window()
	AppSettings.set_fullscreen_enabled(toggled_on, window)
	_update_resolution_options_enabled(window)

func _on_resolution_options_item_selected(index):
	if index < 0 or index >= user_resolutions_array.size():
		return
	AppSettings.set_resolution(user_resolutions_array[index], get_window())
