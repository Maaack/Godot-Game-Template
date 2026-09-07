extends Node3D

@export var base_mouse_sensitivity : float = 0.001
@export var base_joypad_sensitivity : float = 1.250
@export_node_path("CharacterBody3D") var character_body_node_path : NodePath = ^".."
@onready var character_body : CharacterBody3D = get_node_or_null(character_body_node_path)

var _rotation_rate : float = 0.0

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_sensitivity = PlayerConfig.get_config(AppSettings.INPUT_SECTION, &"MouseSensitivity", 1.0)
		mouse_sensitivity *= base_mouse_sensitivity
		character_body.rotation.y -= event.relative.x * mouse_sensitivity
	if event is InputEventJoypadMotion:
		if event.axis == JoyAxis.JOY_AXIS_RIGHT_X:
			var joypad_sensitivity = PlayerConfig.get_config(AppSettings.INPUT_SECTION, &"JoypadSensitivity", 1.0)
			joypad_sensitivity *= base_joypad_sensitivity
			_rotation_rate = event.axis_value * joypad_sensitivity

func _process(delta):
	character_body.rotation.y -= _rotation_rate * delta
