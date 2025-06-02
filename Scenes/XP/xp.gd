extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

var xp_value: int = 1
var collection_range: float = 150.0 
var move_speed: float = 150.0
var is_being_collected: bool = false
var player: CharacterBody2D

func _ready():
    print("XP criado na posição: ", global_position)

    z_index = 10
    scale = Vector2(1, 1)

    if sprite and not sprite.texture:
        print("ERRO: Sprite do XP não tem textura!")
    
    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)

    player = get_tree().get_first_node_in_group("Player")
    if player:
        print("Player encontrado na posição: ", player.global_position)
        print("Distância inicial: ", global_position.distance_to(player.global_position))
    else:
        print("ERRO: Player não encontrado!")
    
    create_spawn_effect()

func _physics_process(delta):
    if not player:
        return
        
    var distance_to_player = global_position.distance_to(player.global_position)
    
    # Debug: sempre mostrar posição e distância
    if Engine.get_process_frames() % 60 == 0:  # A cada segundo
        print("XP na posição: ", global_position, " | Player em: ", player.global_position, " | Distância: ", distance_to_player)

    if distance_to_player <= collection_range and not is_being_collected:
        is_being_collected = true
        print("XP começou a se mover para o player! Distância: ", distance_to_player)

    if is_being_collected:
        move_towards_player(delta)

func move_towards_player(delta):
    if not player:
        return
        
    var direction = (player.global_position - global_position).normalized()
    
    # Mover com velocidade fixa
    global_position += direction * move_speed * delta
    
    # Verificar se chegou muito perto do player
    var distance = global_position.distance_to(player.global_position)
    print("XP se movendo... Distância: ", distance)
    
    if distance < 30:  # Quando muito próximo, coleta automaticamente
        collect_xp()

func _on_body_entered(body):
    print("Algo entrou na área do XP: ", body.name)
    if body.is_in_group("Player"):
        print("Player entrou na área do XP!")
        collect_xp()

func collect_xp():
    print("XP coletado! Valor: ", xp_value)
    
    if player and player.has_method("gain_xp"):
        player.gain_xp(xp_value)
    else:
        print("ERRO: Player não tem método gain_xp!")

    create_collection_effect()
    queue_free()

func create_spawn_effect():
    # Começar invisível e aparecer
    modulate = Color.TRANSPARENT
    var tween = create_tween()
    tween.tween_property(self, "modulate", Color.CYAN, 0.5)  # Azul brilhante para ser visível

func create_collection_effect():
    print("Criando efeito de coleta...")
    var tween = create_tween()
    tween.parallel().tween_property(self, "scale", Vector2(2, 2), 0.2)
    tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.2)

func set_xp_value(value: int):
    xp_value = value
    print("XP value definido como: ", value)