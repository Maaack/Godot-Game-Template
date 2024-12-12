class_name GlobalState
extends Node

const SAVE_STATE_PATH = "user://global_state.tres"
const NO_VERSION_NAME = "0.0.0"

static var current : GlobalStateData
static var current_version : String

static func _log_opened():
	if current is GlobalStateData:
		current.last_unix_time_opened = int(Time.get_unix_time_from_system())

static func _log_version():
	if current is GlobalStateData:
		current_version = ProjectSettings.get_setting("application/config/version", NO_VERSION_NAME)
		if current_version.is_empty():
			current_version = NO_VERSION_NAME
		if not current.first_version_opened:
			current.first_version_opened = current_version
		current.last_version_opened = current_version

static func _load_or_new(new_state : Resource = null):
	if current is GlobalStateData: return
	if FileAccess.file_exists(SAVE_STATE_PATH):
		current = ResourceLoader.load(SAVE_STATE_PATH)
		if not current:
			push_error("Failed to load save state from file")
		else: 
			return
	if new_state:
		current = new_state
	else:
		current = GlobalStateData.new()

static func open():
	_load_or_new()
	_log_opened()
	_log_version()
	save()

static func save():
	if current is GlobalStateData:
		var what_is_state = current
		ResourceSaver.save(current, SAVE_STATE_PATH)

static func has_state(state_key : String) -> bool:
	if current is not GlobalStateData: return false
	return current.has_state(state_key)

static func get_state(state_key : String, state_type_path : String):
	if current is not GlobalStateData: return
	return current.get_state(state_key, state_type_path)

static func reset():
	if current is not GlobalStateData: return
	current.states.clear()
	save()
