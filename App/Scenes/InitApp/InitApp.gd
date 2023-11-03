extends Node

@export_file("*.tscn") var next_scene : String

func _ready():
	AppLog.app_opened()
	AppSettings.set_from_config_and_window(get_window())
	SceneLoader.load_scene(next_scene)
