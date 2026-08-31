extends "level.gd"

func _on_lose_area_3d_body_entered(body):
	level_lost.emit()

func _on_win_area_3d_body_entered(body):
	level_won.emit()
