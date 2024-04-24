extends Node

@export_file("*.tscn") var _loading_screen : String

func _ready():
	AppLog.app_opened()
	AppSettings.set_from_config_and_window(get_window())
	SceneLoader.set_loading_screen(_loading_screen)
