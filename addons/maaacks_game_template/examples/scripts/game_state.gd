class_name GameStateExample
extends Resource

const STATE_NAME : String = "GameStateExample"
const FILE_PATH = "res://addons/maaacks_game_template/examples/scripts/game_state.gd"

@export var level_states : Dictionary = {}
@export var max_level_reached : int
@export var current_level : int
@export var times_played : int

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
		return new_level_state

static func has_game_state() -> bool:
	return GlobalState.has_state(STATE_NAME)

static func get_or_create_state() -> GameStateExample:
	return GlobalState.get_or_create_state(STATE_NAME, FILE_PATH)

static func get_current_level() -> int:
	if not has_game_state(): 
		return 0
	var game_state := get_or_create_state()
	return game_state.current_level

static func get_max_level_reached() -> int:
	if not has_game_state(): 
		return 0
	var game_state := get_or_create_state()
	return game_state.max_level_reached

static func level_reached(level_number : int) -> void:
	var game_state := get_or_create_state()
	game_state.max_level_reached = max(level_number, game_state.max_level_reached)
	game_state.current_level = level_number
	GlobalState.save()

static func set_current_level(level_number : int) -> void:
	var game_state := get_or_create_state()
	game_state.current_level = level_number
	GlobalState.save()

static func start_game() -> void:
	var game_state := get_or_create_state()
	game_state.times_played += 1
	GlobalState.save()
