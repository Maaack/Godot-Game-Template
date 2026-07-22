extends Node2D

@onready var velocity := $VelocityComponent

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += velocity.velocity * delta


func _on_hitbox_component_hitbox_hit() -> void:
	print("hit!")
	queue_free()
