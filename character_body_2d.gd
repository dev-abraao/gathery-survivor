extends CharacterBody2D

const SPEED = 200.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Get input direction
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Normalize the direction to prevent faster diagonal movement
	if direction.length() > 0:
		direction = direction.normalized()
		velocity = direction * SPEED
		# Tocar animação de movimento
		animated_sprite.play("walk")
		animated_sprite.flip_h = direction.x < 0  # Flip sprite based on direction
	else:
		# Slow down when no input
		velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * 10)
		# Tocar animação idle quando não há input
		animated_sprite.play("idle")

	move_and_slide()
