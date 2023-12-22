extends Node

signal level_won
signal level_lost

func _on_lose_button_pressed():
	emit_signal("level_lost")

func _on_win_button_pressed():
	emit_signal("level_won")
