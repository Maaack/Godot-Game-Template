extends Node
class_name VelocityComponent


@export var desired_velocity: Vector2 = Vector2.ZERO 
@export var acceleration: Vector2 = Vector2.ZERO

func add_velocity(vel: Vector2) -> void:
	desired_velocity += vel

func apply_desired_velocity(current: Vector2, delta: float) -> Vector2:
	return Vector2(
		move_toward(current.x, desired_velocity.x, acceleration.x * delta),
		move_toward(current.y, desired_velocity.y, acceleration.y * delta),
	)
