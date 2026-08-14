## This node sets up the application and should be one of the first things run.
## It can either be included in the Project's main scene, or set as an autoload.
extends Node

func _ready() -> void:
	AppSettings.set_from_config_and_window(get_window())
