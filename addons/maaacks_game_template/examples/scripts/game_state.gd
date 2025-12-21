class_name GameStateExample
extends Resource

const STATE_NAME : String = "GameStateExample"
const FILE_PATH = "res://addons/maaacks_game_template/examples/scripts/game_state.gd"

@export var level_states : Dictionary = {}
@export var current_level_path : String
@export var checkpoint_level_path : String
@export var total_games_played : int
@export var play_time : int
@export var total_time : int

static func get_level_state(level_state_key : String) -> LevelStateExample:
	if not has_game_state(): 
		return
	var game_state := get_or_create_state()
	if level_state_key.is_empty() : return
	if level_state_key in game_state.level_states:
		return game_state.level_states[level_state_key] 
	else:
		var new_level_state := LevelStateExample.new()
		game_state.level_states[level_state_key] = new_level_state
		GlobalState.save()
		return new_level_state

static func has_game_state() -> bool:
	return GlobalState.has_state(STATE_NAME)

static func get_or_create_state() -> GameStateExample:
	return GlobalState.get_or_create_state(STATE_NAME, FILE_PATH)

static func get_current_level_path() -> String:
	if not has_game_state(): 
		return ""
	var game_state := get_or_create_state()
	return game_state.current_level_path

static func get_checkpoint_level_path() -> String:
	if not has_game_state(): 
		return ""
	var game_state := get_or_create_state()
	return game_state.checkpoint_level_path

static func get_levels_reached() -> int:
	if not has_game_state(): 
		return 0
	var game_state := get_or_create_state()
	return game_state.level_states.size()

static func set_checkpoint_level_path(level_path : String) -> void:
	var game_state := get_or_create_state()
	game_state.checkpoint_level_path = level_path
	get_level_state(level_path)
	GlobalState.save()

static func set_current_level_path(level_path : String) -> void:
	var game_state := get_or_create_state()
	game_state.current_level_path = level_path
	GlobalState.save()

static func start_game() -> void:
	var game_state := get_or_create_state()
	game_state.total_games_played += 1
	GlobalState.save()

static func continue_game() -> void:
	var game_state := get_or_create_state()
	game_state.current_level_path = game_state.checkpoint_level_path
	GlobalState.save()

static func reset() -> void:
	var game_state := get_or_create_state()
	game_state.level_states = {}
	game_state.current_level_path = ""
	game_state.checkpoint_level_path = ""
	game_state.play_time = 0
	game_state.total_time = 0
	GlobalState.save()
