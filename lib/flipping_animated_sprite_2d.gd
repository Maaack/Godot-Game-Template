extends AnimatedSprite2D
class_name FlippingAnimatedSprite2D

@export var track_horizontal: bool = true
@export var track_vertical: bool = false
@export var horizontal_flip: bool = false
@export var vertical_flip: bool = false


func process_vector2(dir: Vector2) -> void:
	if track_horizontal and dir.x > 0:
		flip_h = false
	elif track_horizontal and dir.x < 0:
		flip_h = true
	
	if horizontal_flip:
		flip_h = !flip_h
