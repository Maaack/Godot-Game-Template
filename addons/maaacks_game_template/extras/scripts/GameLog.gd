class_name GameLog
extends Node
## Logs total count of games started through [Config].

const GAME_LOG_SECTION = "GameLog"
const TOTAL_GAMES_STARTED = "TotalGamesStarted"

static func game_started() -> void:
	var total_games_started = Config.get_config(GAME_LOG_SECTION, TOTAL_GAMES_STARTED, 0)
	total_games_started += 1
	Config.set_config(GAME_LOG_SECTION, TOTAL_GAMES_STARTED, total_games_started)
