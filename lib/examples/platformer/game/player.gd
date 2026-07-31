extends CharacterBody2D

@export_group("Dependencies")
@export var state_machine: StateMachineComponent
@export var velocity_component: VelocityComponent

@export_group("Parameters")

func _physics_process(delta: float) -> void:
	state_machine.process_frame(delta)
	velocity = velocity_component.apply_desired_velocity(velocity, delta)
	move_and_slide()
