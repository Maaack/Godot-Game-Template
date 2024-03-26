extends "res://addons/maaacks_game_template/base/scenes/Menus/OptionsMenu/OptionsMenu.gd"

func _on_reset_game_control_reset_confirmed():
	GameLevelLog.reset_game_data()
