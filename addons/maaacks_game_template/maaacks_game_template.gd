@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("SceneLoader", "res://addons/maaacks_game_template/base/scripts/SceneLoader.gd")
	add_autoload_singleton("RuntimeLogger", "res://addons/maaacks_game_template/extras/scripts/RuntimeLogger.gd")
	add_autoload_singleton("ProjectLevelLoader", "res://addons/maaacks_game_template/extras/scenes/Autoloads/ProjectLevelLoader.tscn")
	add_autoload_singleton("ProjectMusicController", "res://addons/maaacks_game_template/extras/scenes/Autoloads/ProjectMusicController.tscn")
	add_autoload_singleton("ProjectUISoundController", "res://addons/maaacks_game_template/extras/scenes/Autoloads/ProjectUISoundController.tscn")

func _exit_tree():
	remove_autoload_singleton("SceneLoader")
	remove_autoload_singleton("RuntimeLogger")
	remove_autoload_singleton("ProjectLevelLoader")
	remove_autoload_singleton("ProjectMusicController")
	remove_autoload_singleton("ProjectUISoundController")
