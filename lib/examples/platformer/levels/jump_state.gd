extends State

@export_group("Dependencies")
@export var state_machine: StateMachineComponent
@export var sprite: FlippingAnimatedSprite2D
@export var velocity: VelocityComponent
@export var body: CharacterBody2D

@export_group("Parameters")
@export var animation: String = "jump"
@export var variable_jump_rate: float = 0.6
@export var jump_velocity: float = -1000
@export var terminal_velocity: float = 1000
@export var horizontal_move_speed: float = 300
@export var horizontal_acceleration: float = 2000
@export var gravity: float = 1000

@export_group("To States")
@export var idle_state: State
@export var fall_state: State

func process_frame(delta: float) -> void:
	var axis := Input.get_axis("move_left", "move_right")
	sprite.process_vector2(Vector2(axis, 0))
	
	velocity.desired_velocity.x = horizontal_move_speed * axis
	velocity.acceleration.x = horizontal_acceleration
	
	if Input.is_action_just_released("move_up"):
		body.velocity.y *= variable_jump_rate

	if body.velocity.y >= 0:
		state_machine.change_state(fall_state, self)
	

func start(prev: State) -> void:
	body.velocity.y = jump_velocity
	velocity.acceleration.y = gravity
	velocity.desired_velocity.y = terminal_velocity
	if not Input.is_action_pressed("move_up"):
		body.velocity.y *= variable_jump_rate
	sprite.play(animation)
