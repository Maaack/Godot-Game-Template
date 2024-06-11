class_name GameLevelLog
extends GameLog
## Extends [GameLog] to log current and max level reached through [Config]. 

const MAX_LEVEL_REACHED = "MaxLevelReached"
const CURRENT_LEVEL = "CurrentLevel"

static func level_reached(level_number : int) -> void:
	var max_level_reached = Config.get_config(GAME_LOG_SECTION, MAX_LEVEL_REACHED, 0)
	max_level_reached = max(level_number, max_level_reached)
	Config.set_config(GAME_LOG_SECTION, CURRENT_LEVEL, level_number)
	Config.set_config(GAME_LOG_SECTION, MAX_LEVEL_REACHED, max_level_reached)

static func get_max_level_reached() -> int:
	return Config.get_config(GAME_LOG_SECTION, MAX_LEVEL_REACHED, 0)

static func get_current_level() -> int:
	return Config.get_config(GAME_LOG_SECTION, CURRENT_LEVEL, 0)

static func set_current_level(level_number : int) -> void:
	Config.set_config(GAME_LOG_SECTION, CURRENT_LEVEL, level_number)

static func reset_game_data() -> void:
	Config.set_config(GAME_LOG_SECTION, CURRENT_LEVEL, 0)
	Config.set_config(GAME_LOG_SECTION, MAX_LEVEL_REACHED, 0)
