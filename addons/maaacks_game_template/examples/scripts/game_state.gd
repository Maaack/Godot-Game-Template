class_name GameStateExample
extends Resource

const STATE_NAME : String = "GameState"
const FILE_PATH = "res://addons/maaacks_game_template/examples/scripts/game_state.gd"

static var current_level : String
@export var level_states : Dictionary = {}

static func get_current_level_state() -> LevelStateExample:
	var game_state = get_game_state()
	if current_level.is_empty() : return
	if current_level in game_state.level_states:
		return game_state.level_states[current_level] 
	else:
		var new_level_state = LevelStateExample.new()
		game_state.level_states[current_level] = new_level_state
		return new_level_state

static func get_game_state() -> GameStateExample:
	return GlobalState.get_state(STATE_NAME, FILE_PATH)
