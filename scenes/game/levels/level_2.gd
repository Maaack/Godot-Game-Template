extends "level.gd"

func _on_lose_area_2d_body_entered(node: Node2D) -> void:
	level_lost.emit()

func _on_win_area_2d_body_entered(node: Node2D) -> void:
	level_won.emit()
