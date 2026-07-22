extends Area2D
class_name HitboxComponent

@export_group("Dependencies")
@export var damage_component: DamageComponent

signal hitbox_hit

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		area.health_component.hurt(damage_component.damage)
		hitbox_hit.emit()
