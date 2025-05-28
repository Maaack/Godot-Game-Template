@tool
extends ListOptionControl

func _set_input_device() -> void:
	var current_setting : Variant = _get_setting(default_value)
	if current_setting is bool:
		current_setting = &"Default"
	AudioServer.input_device = _get_setting(default_value)

func _add_microphone_audio_stream() -> void:
	var instance := AudioStreamPlayer.new()
	instance.stream = AudioStreamMicrophone.new()
	instance.autoplay = true
	add_child.call_deferred(instance)
	instance.ready.connect(_set_input_device)

func _ready() -> void:
	if ProjectSettings.get_setting("audio/driver/enable_input", false):
		if AudioServer.input_device.is_empty():
			_add_microphone_audio_stream()
		else:
			_set_input_device()
		if not Engine.is_editor_hint():
			option_values = AudioServer.get_input_device_list()
	else:
		hide()
	super._ready()

func _on_setting_changed(value : Variant) -> void:
	if value >= option_values.size(): return
	AudioServer.input_device = option_values[value]
	super._on_setting_changed(value)

func _value_title_map(value : Variant) -> String:
	if value is String:
		return value
	else:
		return super._value_title_map(value)
