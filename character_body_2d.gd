extends CharacterBody2D

const SPEED = 500.0

func _physics_process(delta: float) -> void:
	# Get input direction
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Normalize the direction to prevent faster diagonal movement
	if direction.length() > 0:
		direction = direction.normalized()
		velocity = direction * SPEED
	else:
		# Slow down when no input
		velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * 10)
	
	move_and_slide()
