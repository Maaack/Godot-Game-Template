class_name GameLog
extends Node

const GAME_LOG_SECTION = "GameLog"
const TOTAL_GAMES_STARTED = "TotalGamesStarted"
const MAX_LEVEL_REACHED = "MaxLevelReached"

static func game_started() -> void:
	var total_games_started = Config.get_config(GAME_LOG_SECTION, TOTAL_GAMES_STARTED, 0)
	total_games_started += 1
	Config.set_config(GAME_LOG_SECTION, TOTAL_GAMES_STARTED, total_games_started)

static func level_reached(level_number : int) -> void:
	var max_level_reached = Config.get_config(GAME_LOG_SECTION, MAX_LEVEL_REACHED, 0)
	max_level_reached = max(level_number, max_level_reached)
	Config.set_config(GAME_LOG_SECTION, TOTAL_GAMES_STARTED, max_level_reached)

static func reset_game_data() -> void:
	Config.set_config(GAME_LOG_SECTION, MAX_LEVEL_REACHED, 0)
