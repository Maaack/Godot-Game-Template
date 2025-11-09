extends Sprite2D

var bullet_scene = preload("res://scenes/game_scene/begin/bullet-green/greenbullet.tscn")
var shoot_timer: float = 0.0
var shoot_interval: float = 1.0  # 每秒发射一次

func _physics_process(delta: float) -> void:
	shoot_timer += delta
	
	# 每隔一定时间发射一颗子弹
	if shoot_timer >= shoot_interval:
		shoot_bullet()
		shoot_timer = 0.0

func shoot_bullet():
	var new_bullet = bullet_scene.instantiate()
	# 将子弹添加到父节点（Level1）而不是塔本身
	get_parent().add_child(new_bullet)
	# 设置子弹的初始位置为塔的位置
	new_bullet.global_position = global_position
