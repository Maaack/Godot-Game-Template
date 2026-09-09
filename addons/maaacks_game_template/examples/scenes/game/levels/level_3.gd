extends "level.gd"

func _on_lose_area_3d_body_entered(_body: Node3D) -> void:
	level_lost.emit()

func _on_win_area_3d_body_entered(_body: Node3D) -> void:
	level_won.emit(next_level_path)
