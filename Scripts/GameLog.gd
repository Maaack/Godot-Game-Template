extends Node

const GAME_LOG_SECTION = "GameLog"
const APP_OPENED = "AppOpened"
const TOTAL_RUN_TIME = "TotalRunTime"
const TOTAL_GAMES_STARTED = "TotalGamesStarted"
const FIRST_VERSION_PLAYED = "FirstVersionPlayed"
const LAST_VERSION_PLAYED = "LastVersionPlayed"
const UPDATE_COUNTER_RESET = 3.0
const UNKNOWN_VERSION = "unknown"

var app_opened : int = 0
var total_run_time : float = 0.0
var total_games_started : int = 0
var first_version_played : String = UNKNOWN_VERSION setget set_first_version_played
var last_version_played : String = UNKNOWN_VERSION setget set_last_version_played
var update_counter : float = 0.0

func _process(delta):
	total_run_time += delta
	update_counter += delta
	if update_counter > UPDATE_COUNTER_RESET:
		update_counter = 0.0
		Config.set_config(GAME_LOG_SECTION, TOTAL_RUN_TIME, total_run_time)

func _sync_with_config() -> void:
	app_opened = Config.get_config(GAME_LOG_SECTION, APP_OPENED, app_opened)
	total_run_time = Config.get_config(GAME_LOG_SECTION, TOTAL_RUN_TIME, total_run_time)
	total_games_started = Config.get_config(GAME_LOG_SECTION, TOTAL_GAMES_STARTED, total_games_started)
	first_version_played = Config.get_config(GAME_LOG_SECTION, FIRST_VERSION_PLAYED, first_version_played)
	last_version_played = Config.get_config(GAME_LOG_SECTION, LAST_VERSION_PLAYED, last_version_played)

func _init():
	_sync_with_config()

func _ready():
	app_opened += 1
	Config.set_config(GAME_LOG_SECTION, APP_OPENED, app_opened)

func set_first_version_played(value : String) -> void:
	if first_version_played != UNKNOWN_VERSION:
		return
	first_version_played = value
	Config.set_config(GAME_LOG_SECTION, FIRST_VERSION_PLAYED, first_version_played)

func set_last_version_played(value : String) -> void:
	last_version_played = value
	Config.set_config(GAME_LOG_SECTION, LAST_VERSION_PLAYED, last_version_played)

func set_version_played(version : String) -> void:
	self.first_version_played = version
	self.last_version_played = version

func game_played(version : String) -> void:
	set_version_played(version)
	total_games_started += 1
	Config.set_config(GAME_LOG_SECTION, TOTAL_GAMES_STARTED, total_games_started)
