extends Node
class_name KnockbackComponent

@export_group("Dependencies")
@export var body: CharacterBody2D

func knockback(source: DamageComponent, ...args: Array) -> void:
	var dir: Vector2 = source.damage_from_node2d.transform.origin.direction_to(body.position)
	body.velocity = dir * source.impulse
