extends Node

@export_group("Scenes")
@export_file("*.tscn") var main_menu_scene_path : String
@export_file("*.tscn") var game_scene_path : String
@export_file("*.tscn") var ending_scene_path : String

func _ready() -> void:
	GlobalState.open()
	AppSettings.set_from_config_and_window(get_window())
