extends Node2D

@onready var player = get_parent().get_node("Player")
@onready var enemy_scene = preload("res://Scenes/Enemies/Goblin/Enemy.tscn")
@onready var world_tilemap = get_parent().get_node("World")  # Ajuste o caminho

var spawn_timer : float = 2.5
var time_elapsed : float = 0.0

var min_spawn_distance = 750
var max_spawn_distance = 900

func _process(delta):
    time_elapsed += delta
    
    if time_elapsed >= spawn_timer:
        time_elapsed = 0
        spawn_enemy()

func spawn_enemy():
    var random_angle = randf() * 2 * PI
    var random_distance = randf_range(min_spawn_distance, max_spawn_distance)
    var spawn_pos = player.position + Vector2(
        cos(random_angle) * random_distance,
        sin(random_angle) * random_distance
    )
    
    if is_valid_spawn_position(spawn_pos):
        create_enemy_at_position(spawn_pos)
        return
    

func is_valid_spawn_position(world_pos: Vector2) -> bool:
    for child in world_tilemap.get_children():
        if child is TileMapLayer:
            var tile_pos = child.local_to_map(world_pos)
            var source_id = child.get_cell_source_id(tile_pos)
            
            if child.name == "Water"  and source_id != -1:
                return false
            if child.name == "Foam"  and source_id != -1:
                return false
            if child.name == "Rocks"  and source_id != -1:
                return false
    
    return true

func create_enemy_at_position(spawn_pos: Vector2):
    var enemy_instance = enemy_scene.instantiate()
    enemy_instance.z_index = 1
    enemy_instance.position = spawn_pos
    
    get_parent().add_child(enemy_instance)

