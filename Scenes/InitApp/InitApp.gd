extends Node

export(String, FILE, "*.tscn") var next_scene : String

func _ready():
	AppSettings.initialize_from_config()
	SceneLoader.load_scene(next_scene)
