@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("AppConfig", "res://addons/maaacks_game_template/base/scenes/Autoloads/AppConfig.tscn")
	add_autoload_singleton("SceneLoader", "res://addons/maaacks_game_template/base/scenes/Autoloads/SceneLoader.tscn")
	add_autoload_singleton("ProjectMusicController", "res://addons/maaacks_game_template/base/scenes/Autoloads/ProjectMusicController.tscn")
	add_autoload_singleton("ProjectUISoundController", "res://addons/maaacks_game_template/base/scenes/Autoloads/ProjectUISoundController.tscn")

func _exit_tree():
	remove_autoload_singleton("AppConfig")
	remove_autoload_singleton("SceneLoader")
	remove_autoload_singleton("ProjectMusicController")
	remove_autoload_singleton("ProjectUISoundController")
