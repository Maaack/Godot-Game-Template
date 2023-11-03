extends Node

@export_file("*.tscn") var next_scene : String

func _ready():
	AppSettings.set_from_config_and_window(get_window())
	SceneLoader.load_scene(next_scene)
