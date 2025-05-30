extends CharacterBody2D

@onready var player = get_parent().get_node("Player")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const speed = 100.0
const attack_range = 50.0
const attack_cooldown = 1.5

var is_attacking = false
var attack_timer = 0.0
var max_health = 30
var current_health = 30

func _ready():
    # Adicionar ao grupo de inimigos
    add_to_group("enemies")
    current_health = max_health

func _physics_process(delta: float) -> void:
    if not player:
        player = get_tree().get_first_node_in_group("Player")
        return
    
    if attack_timer > 0:
        attack_timer -= delta
    
    var distance_to_player = position.distance_to(player.position)
    
    if is_attacking:
        return
    
    if distance_to_player <= attack_range and attack_timer <= 0:
        attack()
        return
    
    if distance_to_player <= attack_range:
        animated_sprite.play("idle")
        return
    
    var direction = (player.position - position).normalized()
    velocity = direction * speed
    
    animated_sprite.play("walk")
    animated_sprite.flip_h = (player.position.x < position.x)
    
    move_and_slide()

func attack():
    is_attacking = true
    attack_timer = attack_cooldown
    velocity = Vector2.ZERO
    
    animated_sprite.flip_h = (player.position.x < position.x)
    animated_sprite.play("attack")
    
    if not animated_sprite.animation_finished.is_connected(_on_attack_finished):
        animated_sprite.animation_finished.connect(_on_attack_finished)

func _on_attack_finished():
    if animated_sprite.animation == "attack":
        is_attacking = false
        deal_damage_to_player()

func deal_damage_to_player():
    var distance_to_player = position.distance_to(player.position)
    if distance_to_player <= attack_range:
        print("Inimigo causou dano ao player!")

func take_damage(amount: int):
    current_health -= amount
    print("Inimigo levou ", amount, " de dano! Vida: ", current_health)
    
    # Efeito visual (opcional)
    modulate = Color.RED
    var tween = create_tween()
    tween.tween_property(self, "modulate", Color.WHITE, 0.1)
    
    if current_health <= 0:
        die()

func die():
    print("Inimigo morreu!")
    queue_free()