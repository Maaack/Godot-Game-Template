extends Node

@export var next_scene : String # (String, FILE, "*.tscn")

func _ready():
	AppSettings.initialize_from_config(get_window())
	SceneLoader.load_scene(next_scene)
