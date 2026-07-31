extends State

@export_group("Dependencies")
@export var state_machine: StateMachineComponent
@export var sprite: AnimatedSprite2D
@export var velocity: VelocityComponent
@export var body: CharacterBody2D

@export_group("Parameters")
@export var animation: String = "hurt"
@export var damp_accel: float = 3000
@export var duration_seconds: float = 1.5
@export var terminal_velocity: float = 1000
@export var gravity: float = 1000

@export_group("To States")
@export var idle_state: State

var _duration_timer: float = 0

func process_frame(delta: float) -> void:
	_duration_timer -= delta
	if _duration_timer <= 0:
		state_machine.change_state(idle_state, self)

func start(prev: State) -> void:
	velocity.desired_velocity.x = 0
	velocity.acceleration.x = damp_accel
	_duration_timer = duration_seconds
	body.velocity.y = -1000
	velocity.desired_velocity.y = terminal_velocity
	velocity.acceleration.y = gravity
	sprite.play(animation)


func _on_health_component_health_hurt(...args: Array) -> void:
	state_machine.change_state(self, null)
