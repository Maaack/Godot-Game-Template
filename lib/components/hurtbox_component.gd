extends Area2D
class_name HurtboxComponent

@export_group("Dependencies")
@export var health_component: HealthComponent

func hit(damage: DamageComponent) -> void:
	health_component.hurt(damage)
