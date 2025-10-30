extends "res://addons/maaacks_game_template/base/nodes/menus/options_menu/mini_options_menu.gd"

func _on_reset_game_control_reset_confirmed() -> void:
	GameStateExample.reset()
