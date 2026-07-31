extends Node

@export var state_machine: StateMachineComponent
@export var body: CharacterBody2D
@export var jump_state: State

@export var jump_buffer_seconds := 0.3
@export var coyote_time_seconds := 0.3

var _jump_buffer_timer := 0.0
var _coyote_time_timer := 0.0


func _process(delta: float) -> void:
	_coyote_time_timer -= delta
	_jump_buffer_timer -= delta
	
	if body.is_on_floor():
		_coyote_time_timer = coyote_time_seconds
	if Input.is_action_just_pressed("move_up"):
		_jump_buffer_timer = jump_buffer_seconds
	
	if _jump_buffer_timer > 0 and _coyote_time_timer > 0:
		state_machine.change_state(jump_state, null)
		_jump_buffer_timer = 0.0
		_coyote_time_timer = 0.0
