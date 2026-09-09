@tool
class_name MaaacksMusicController
extends RefCounted

const PLUGIN_NAME = "Maaack's Music Controller"
const PROJECT_SETTINGS_PATH = "maaacks_music_controller/"

static func get_plugin_name() -> String:
	return PLUGIN_NAME

static func get_settings_path() -> String:
	return PROJECT_SETTINGS_PATH
