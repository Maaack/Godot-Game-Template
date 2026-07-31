extends State

@export_group("Dependencies")
@export var state_machine: StateMachineComponent
@export var sprite: AnimatedSprite2D
@export var velocity: VelocityComponent
@export var body: CharacterBody2D

@export_group("Parameters")
@export var animation: String = "idle"
@export var damp_accel: float = 3000

@export_group("To States")
@export var run_state: State
@export var jump_state: State
@export var fall_state: State

var _target_velocity := Vector2.ZERO

func process_frame(delta: float) -> void:
	
	if not body.is_on_floor():
		state_machine.change_state(fall_state, self)
	elif not Input.get_axis("move_left", "move_right") == 0.0:
		state_machine.change_state(run_state, self)
	elif Input.is_action_just_pressed("move_up"):
		state_machine.change_state(jump_state, self)


func start(prev: State) -> void:
	velocity.desired_velocity = Vector2.ZERO
	velocity.acceleration.x = damp_accel
	sprite.play(animation)
