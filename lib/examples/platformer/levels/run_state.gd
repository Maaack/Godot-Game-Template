extends State

@export_group("Dependencies")
@export var state_machine: StateMachineComponent
@export var sprite: AnimatedSprite2D
@export var velocity: VelocityComponent
@export var body: CharacterBody2D

@export_group("Parameters")
@export var animation: String = "run"
@export var horizontal_move_speed: float = 300
@export var horizontal_acceleration: float = 900

@export_group("To States")
@export var idle_state: State
@export var fall_state: State
@export var jump_state: State

func process_frame(delta: float) -> void:
	var axis := Input.get_axis("move_left", "move_right")
	velocity.desired_velocity.x = horizontal_move_speed * axis
	velocity.acceleration.x = horizontal_acceleration
	sprite.process_vector2(Vector2(axis, 0))
	
	if not body.is_on_floor():
		state_machine.change_state(fall_state, self)
	elif Input.get_axis("move_left", "move_right") == 0.0:
		state_machine.change_state(idle_state, self)

func start(prev: State) -> void:
	sprite.play(animation)
