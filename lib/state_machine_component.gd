extends Node
class_name StateMachineComponent


@export_group("States")
@export var starting_state: State

var _current_state: State

func _ready() -> void:
	_current_state = starting_state
	_current_state.start(null)

func process_frame(delta: float) -> void:
	_current_state.process_frame(delta)

func change_state(new: State, prev: State) -> void:
	print("State changed: ", new.name)
	_current_state = new
	new.start(prev)
