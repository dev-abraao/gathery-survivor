extends CharacterBody2D

@onready var player = get_parent().get_node("Player")

const speed = 100.0

func _physics_process(delta: float) -> void:
	if player:
		position += (player.position - position).normalized() * speed * delta
	else:
		# Try to find player again in case it was added after this node was initializedteste
		player = get_tree().get_first_node_in_group("Player")

	if position.distance_to(player.position) < 50.0:
		# If the enemy is close enough to the player, stop moving
		return

	move_and_slide()
