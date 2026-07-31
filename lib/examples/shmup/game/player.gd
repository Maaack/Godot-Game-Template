extends CharacterBody2D
class_name Player

@export_group("Dependencies")
@export var input: InputComponent

@export_group("Movement")
@export var movement_speed := 200


func _physics_process(delta: float) -> void:
	velocity = input.get_movement_vector() * movement_speed
	move_and_slide()
