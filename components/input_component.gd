extends Node
class_name InputComponent

var movement_vector := Vector2.ZERO

signal input_interact
signal input_attack
signal input_alt_attack

func get_movement_vector() -> Vector2:
	return Input.get_vector(
		"move_left","move_right","move_up","move_down",
	)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		input_interact.emit()
	if Input.is_action_just_pressed("attack"):
		input_attack.emit()
	if Input.is_action_just_pressed("alt_attack"):
		input_alt_attack.emit()
