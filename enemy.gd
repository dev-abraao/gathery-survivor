extends CharacterBody2D

@onready var player = get_parent().get_node("Player")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const speed = 100.0
const attack_range = 50.0
const attack_cooldown = 1.5  # Tempo entre ataques em segundos

var is_attacking = false
var attack_timer = 0.0

func _physics_process(delta: float) -> void:
    if not player:
        # Try to find player again in case it was added after this node was initialized
        player = get_tree().get_first_node_in_group("Player")
        return
    
    # Atualizar timer de ataque
    if attack_timer > 0:
        attack_timer -= delta
    
    var distance_to_player = position.distance_to(player.position)
    
    # Se estiver atacando, não fazer nada até terminar
    if is_attacking:
        return
    
    # Se estiver próximo o suficiente e pode atacar
    if distance_to_player <= attack_range and attack_timer <= 0:
        attack()
        return
    
    # Se estiver próximo mas não pode atacar (cooldown)
    if distance_to_player <= attack_range:
        animated_sprite.play("idle")
        return
    
    # Move towards player
    var direction = (player.position - position).normalized()
    velocity = direction * speed
    
    # Play walk animation and flip sprite
    animated_sprite.play("walk")
    animated_sprite.flip_h = (player.position.x < position.x)
    
    move_and_slide()

func attack():
    is_attacking = true
    attack_timer = attack_cooldown
    velocity = Vector2.ZERO  # Para o movimento durante o ataque
    
    # Orientar sprite na direção do player
    animated_sprite.flip_h = (player.position.x < position.x)
    
    # Tocar animação de ataque
    animated_sprite.play("attack")
    
    # Conectar ao sinal de fim da animação se ainda não estiver conectado
    if not animated_sprite.animation_finished.is_connected(_on_attack_finished):
        animated_sprite.animation_finished.connect(_on_attack_finished)

func _on_attack_finished():
    # Só terminar o ataque se a animação que terminou foi a de ataque
    if animated_sprite.animation == "attack":
        is_attacking = false
        # Aqui você pode adicionar lógica de dano ao player se necessário
        deal_damage_to_player()

func deal_damage_to_player():
    # Verificar se ainda está no alcance para causar dano
    var distance_to_player = position.distance_to(player.position)
    if distance_to_player <= attack_range:
        print("Inimigo causou dano ao player!")
        # Aqui você pode chamar uma função do player para causar dano
        # Por exemplo: player.take_damage(10)