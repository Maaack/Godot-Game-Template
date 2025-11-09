extends Sprite2D

@onready var bullet = $"../Greenbullet"
@onready var fish = $"../Enemy-maomaochong-0"

@export var speed:float = 400

func _ready() -> void:
	print("bullet", bullet)
	print("fish", fish)



func _physics_process(delta: float) -> void:
	if not is_instance_valid(bullet):
		return
	if not is_instance_valid(fish):
		return
	bullet.global_position += Vector2(speed * delta, 0)
	if (bullet.global_position.distance_to(fish.global_position) < 20):
			fish.queue_free()
			bullet.queue_free()
