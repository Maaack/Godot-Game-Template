extends Area2D

@onready var velocity := $VelocityComponent

func _ready() -> void:
	print('hey hey hey')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += velocity.velocity * delta
