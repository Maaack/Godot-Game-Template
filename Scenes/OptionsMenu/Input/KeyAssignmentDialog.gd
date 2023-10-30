extends ConfirmationDialog

var last_input_event : InputEvent

func _record_input_event(event : InputEvent):
	var input_event_text : String = InputEventHelper.get_text(event)
	if input_event_text.is_empty():
		return
	last_input_event = event
	dialog_text = input_event_text
	get_ok_button().disabled = false

func _is_recordable_input(event : InputEvent):
	return event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or (event is InputEventJoypadMotion and abs(event.axis_value) > 0.5)

func _unhandled_input(event):
	if not visible:
		return
	if _is_recordable_input(event):
		_record_input_event(event)

func _is_button_released(event : InputEvent) -> bool:
	return (event is InputEventMouseButton or event is InputEventJoypadButton) and event.is_released()

func _is_possible_button_trigger(event : InputEvent) -> bool:
	return (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventJoypadButton and event.button_index == JOY_BUTTON_A)

func _input(event):
	if not visible:
		return
	if _is_button_released(event):
		if _is_possible_button_trigger(event):
			await(get_tree().create_timer(0.05).timeout)
		_record_input_event(event)
