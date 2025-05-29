extends CharacterBody2D

@onready var player = get_parent().get_node("Player")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const speed = 100.0

func _physics_process(delta: float) -> void:
    if not player:
        # Try to find player again in case it was added after this node was initialized
        player = get_tree().get_first_node_in_group("Player")
        return

    var distance_to_player = position.distance_to(player.position)

    if distance_to_player < 50.0:
        animated_sprite.play("idle")
        return

    # Move towards player
    var direction = (player.position - position).normalized()
    velocity = direction * speed

    # Play walk animation and flip sprite
    animated_sprite.play("walk")
    animated_sprite.flip_h = (player.position.x < position.x)

    move_and_slide()
