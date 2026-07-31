extends State

@export_group("Dependencies")
@export var state_machine: StateMachineComponent
@export var sprite: FlippingAnimatedSprite2D
@export var velocity: VelocityComponent
@export var body: CharacterBody2D

@export_group("Parameters")
@export var animation: String = "fall"
@export var horizontal_move_speed: float = 300
@export var horizontal_acceleration: float = 2000
@export var terminal_velocity: float = 1000
@export var gravity: float = 1000


@export_group("To States")
@export var idle_state: State
@export var jump_state: State

@export_group("From States")
@export var run_state: State

func process_frame(delta: float) -> void:
	
	var axis := Input.get_axis("move_left", "move_right")
	sprite.process_vector2(Vector2(axis, 0))
	if not axis == 0.0:
		velocity.desired_velocity.x = horizontal_move_speed * axis
		velocity.acceleration.x = horizontal_acceleration
	elif axis == 0.0:
		velocity.desired_velocity.x = 0
	
	if body.is_on_floor():
		state_machine.change_state(idle_state, self)
	

func start(prev: State) -> void:
	velocity.acceleration.y = gravity
	velocity.desired_velocity.y = terminal_velocity

	sprite.play(animation)
