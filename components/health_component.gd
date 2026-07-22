extends Node
class_name HealthComponent

@export_group("Health Parameters")
@export var health: int = 0
@export var max_health: int = 5

@export_group("Options")
## Whether to emit 'health_hurt' and 'health_death' simlutaneously when calling `hurt` causes death, or to only call `health_death`
@export var signal_hurt_and_death: bool = false
## Whether to allow healing past the set max_health
@export var allow_overheal: bool = false

signal health_hurt
signal health_heal
signal health_die
signal health_set

func hurt(total: int) -> void:
	var taken = total
	if health < total:
		taken = health
	health -= taken
	
	var dying := health <= 0
	
	if dying:
		if signal_hurt_and_death:
			health_hurt.emit(total, taken, health)
		die()
		return
	
	health_hurt.emit(total, taken, health)

func heal(val: int) -> void:
	if health >= max_health and !allow_overheal:
		return
	
	var health_delta = max_health-health
	if val > health_delta and !allow_overheal:
		val = health_delta
	
	health += val
	
	health_heal.emit(val, health)

func set_health(val: int) -> void:
	if val > max_health and !allow_overheal:
		val = max_health
	
	health = val
	health_set.emit(val)
	
	if health <= 0:
		die()

func die() -> void:
	health_die.emit()
