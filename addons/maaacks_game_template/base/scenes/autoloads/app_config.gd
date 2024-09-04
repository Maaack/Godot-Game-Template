extends Node

func _ready():
	AppLog.app_opened()
	AppState.open()
	AppSettings.set_from_config_and_window(get_window())
