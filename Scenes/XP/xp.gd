extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

var xp_value: int = 1
var collection_range: float = 150.0 
var move_speed: float = 250.0
var is_being_collected: bool = false
var player: CharacterBody2D

func _ready():

    z_index = 10
    scale = Vector2(1, 1)

    if not body_entered.is_connected(_on_body_entered):
        body_entered.connect(_on_body_entered)

    player = get_tree().get_first_node_in_group("Player")
    
    create_spawn_effect()

func _physics_process(delta):
    if not player:
        return
        
    var distance_to_player = global_position.distance_to(player.global_position)
    

    if distance_to_player <= collection_range and not is_being_collected:
        is_being_collected = true

    if is_being_collected:
        move_towards_player(delta)

func move_towards_player(delta):
    if not player:
        return
        
    var direction = (player.global_position - global_position).normalized()
    global_position += direction * move_speed * delta
    var distance = global_position.distance_to(player.global_position)
    
    if distance < 30:
        collect_xp()

func _on_body_entered(body):
    if body.is_in_group("Player"):
        collect_xp()

func collect_xp():
    if player and player.has_method("gain_xp"):
        player.gain_xp(xp_value)

    create_collection_effect()
    queue_free()

func create_spawn_effect():
    modulate = Color.TRANSPARENT
    var tween = create_tween()
    tween.tween_property(self, "modulate", Color.CYAN, 0.5)  # Azul brilhante para ser visível

func create_collection_effect():
    var tween = create_tween()
    tween.parallel().tween_property(self, "scale", Vector2(2, 2), 0.2)
    tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.2)

func set_xp_value(value: int):
    xp_value = value