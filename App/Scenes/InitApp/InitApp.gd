extends Node

@export_file("*.tscn") var next_scene : String
@export var use_loading_screen : bool = false

func _ready():
	AppLog.app_opened()
	AppSettings.set_from_config_and_window(get_window())
	if use_loading_screen:
		SceneLoader.load_scene(next_scene)
	else:
		get_tree().change_scene_to_file(next_scene)
