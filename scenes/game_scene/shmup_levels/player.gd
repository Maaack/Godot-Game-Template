extends CharacterBody2D
class_name Player

@export_group("Dependencies")
@export var vel: VelocityComponent
@export var input: InputComponent

@export_group("Movement")
@export var movement_speed := 200


func _physics_process(delta: float) -> void:
	velocity = input.get_movement_vector() * movement_speed
	move_and_slide()


#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
