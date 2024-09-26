extends Node

signal level_won
signal level_lost

func _on_lose_button_pressed():
	level_lost.emit()

func _on_win_button_pressed():
	level_won.emit()
