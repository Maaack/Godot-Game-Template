class_name GameState
extends Resource

const STATE_NAME : String = "GameState"
const FILE_PATH = "res://scripts/game_state.gd"

static var level_state_key : String
@export var level_states : Dictionary = {}
@export var max_level_reached : int
@export var current_level : int
@export var total_games_started : int

static func get_current_level_state() -> LevelState:
	var game_state = get_game_state()
	if level_state_key.is_empty() : return
	if level_state_key in game_state.level_states:
		return game_state.level_states[level_state_key] 
	else:
		var new_level_state = LevelState.new()
		game_state.level_states[level_state_key] = new_level_state
		return new_level_state

static func get_game_state() -> GameState:
	return GlobalState.get_state(STATE_NAME, FILE_PATH)

static func get_current_level() -> int:
	var game_state = get_game_state()
	if game_state:
		return game_state.current_level
	return 0

static func level_reached(level_number):
	var game_state = get_game_state()
	if game_state:
		game_state.max_level_reached = max(level_number, game_state.max_level_reached)
		game_state.current_level = level_number
	GlobalState.save()

static func set_current_level(level_number):
	var game_state = get_game_state()
	if game_state:
		game_state.current_level = level_number
	GlobalState.save()

static func start_game():
	var game_state = get_game_state()
	if game_state:
		game_state.total_games_started += 1
	GlobalState.save()
