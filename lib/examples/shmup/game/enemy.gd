extends Node2D

@onready var velocity_component := $VelocityComponent

func _physics_process(delta: float) -> void:
	position += velocity_component.velocity * delta

func _on_health_component_health_die() -> void:
	print("oh the humanity")
	queue_free()
