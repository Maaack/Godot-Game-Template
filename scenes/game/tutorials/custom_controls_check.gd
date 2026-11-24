extends Control

@export var custom_actions : Array[StringName] = [
	&"move_left",
	&"move_right",
	&"move_forward",
	&"move_backward",
	&"jump"
]

@export var default_action_container : Control

func _has_custom_actions() -> bool:
	for custom_action in custom_actions:
		if not InputMap.has_action(custom_action):
			return false
	return true

func _ready():
	if _has_custom_actions():
		visible = true
		default_action_container.visible = false
	else:
		visible = false
		default_action_container.visible = true
