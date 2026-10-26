extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	var pressed_jump : bool
	if InputMap.has_action(&"jump"):
		pressed_jump = Input.is_action_just_pressed(&"jump")
	else:
		pressed_jump = Input.is_action_just_pressed("ui_accept")
	if pressed_jump and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction : float
	if InputMap.has_action(&"move_left") and InputMap.has_action(&"move_right"):
		direction = Input.get_axis(&"move_left", &"move_right")
	else:
		direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
