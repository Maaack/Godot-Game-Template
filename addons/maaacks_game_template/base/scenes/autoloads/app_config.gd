extends Node

func _ready():
	AppLog.app_opened()
	AppSettings.set_from_config_and_window(get_window())
