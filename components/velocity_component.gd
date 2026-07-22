extends Node
class_name VelocityComponent


@export var velocity: Vector2 = Vector2.ZERO 

func set_velocity(vel: Vector2) -> void:
	velocity = vel
	
func add_velocity(vel: Vector2) -> void:
	velocity.x += vel.x
	velocity.y += vel.y
