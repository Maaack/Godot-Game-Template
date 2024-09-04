class_name AppState
extends Node

const STARTING_GAME_STATE_PATH = "res://addons/maaacks_game_template/base/scripts/init_app_state.tres"
const SAVE_STATE_PATH = "user://app_state.res"
const NO_VERSION_NAME = "0.0.0"

static var current : AppStateData
static var current_version : String

static func _log_opened():
	if current is AppStateData:
		current.open_count += 1

static func _log_version():
	if current is AppStateData:
		current_version = ProjectSettings.get_setting("application/config/version", NO_VERSION_NAME)
		if not current.first_version_opened:
			current.first_version_opened = current_version
		current.last_version_opened = current_version

static func _open_state():
	if not current is AppStateData:
		if FileAccess.file_exists(SAVE_STATE_PATH):
			current = ResourceLoader.load(SAVE_STATE_PATH)
		elif FileAccess.file_exists(STARTING_GAME_STATE_PATH):
			current = ResourceLoader.load(STARTING_GAME_STATE_PATH)
		else:
			current = AppStateData.new()

static func open():
	_open_state()
	_log_opened()
	_log_version()

static func save():
	if current is AppStateData:
		ResourceSaver.save(current, SAVE_STATE_PATH)
