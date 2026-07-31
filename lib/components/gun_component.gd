extends UsableComponent
class_name GunComponent

@export_group("Parameters")
@export var fire_rate: float = 5 # RPS
@export var ammo: int = INF

@export_group("Dependencies")
@export var projectile_spawn_point: Node2D = null
@export var projectile: PackedScene = null

signal fired

var _fire_interval := 1 / fire_rate
var _can_fire = true

func use() -> void:
	if _can_fire:
		_can_fire = false
		fire()
		
		await get_tree().create_timer(_fire_interval).timeout
		_can_fire = true

func fire() -> void:
	fired.emit()
	var new_proj := projectile.instantiate()
	get_tree().current_scene.add_child(new_proj)
	
	new_proj.global_position = projectile_spawn_point.global_position
	new_proj.global_rotation = projectile_spawn_point.global_rotation
