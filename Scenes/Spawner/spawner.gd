extends Node2D

@onready var player = get_parent().get_node("Player")
@onready var enemy_scene = preload("res://Scenes/Enemies/Goblin/Enemy.tscn")
@onready var world_tilemap = get_parent().get_node("World")

# Configurações de spawn base
var base_spawn_timer: float = 2.5
var current_spawn_timer: float = 2.5
var time_elapsed: float = 0.0

# Dificuldade e spawn dinâmico
var min_spawn_timer: float = 0.2
var timer_reduction_per_level: float = 0.1
var enemies_per_spawn: int = 1
var max_enemies_per_spawn: int = 5

var min_spawn_distance = 750
var max_spawn_distance = 900

func _ready():
	print("Spawner iniciado!")

func _process(delta):
	time_elapsed += delta

	update_difficulty()
	
	if time_elapsed >= current_spawn_timer:
		time_elapsed = 0
		spawn_enemies_wave()

func update_difficulty():
	if not player:
		return

	var player_level = player.get_level()

	current_spawn_timer = max(
		min_spawn_timer, 
		base_spawn_timer - (timer_reduction_per_level * (player_level - 1))
	)

	enemies_per_spawn = min(
		max_enemies_per_spawn,
		1 + int((player_level - 1) / 2)
	)

	if Engine.get_process_frames() % 300 == 0:
		print("Nível: ", player_level, " | Timer: ", snappedf(current_spawn_timer, 0.1), "s | Inimigos/spawn: ", enemies_per_spawn)

func spawn_enemies_wave():
	for i in range(enemies_per_spawn):
		spawn_single_enemy()

		if i < enemies_per_spawn - 1:
			await get_tree().create_timer(0.1).timeout

func spawn_single_enemy():
	var attempts = 0
	var max_attempts = 10
	
	while attempts < max_attempts:
		var random_angle = randf() * 2 * PI
		var random_distance = randf_range(min_spawn_distance, max_spawn_distance)
		var spawn_pos = player.position + Vector2(
			cos(random_angle) * random_distance,
			sin(random_angle) * random_distance
		)
		
		if is_valid_spawn_position(spawn_pos):
			create_enemy_at_position(spawn_pos)
			return
		
		attempts += 1

	var fallback_angle = randf() * 2 * PI
	var fallback_pos = player.position + Vector2(
		cos(fallback_angle) * min_spawn_distance,
		sin(fallback_angle) * min_spawn_distance
	)
	create_enemy_at_position(fallback_pos)

func is_valid_spawn_position(world_pos: Vector2) -> bool:
	for child in world_tilemap.get_children():
		if child is TileMapLayer:
			var tile_pos = child.local_to_map(world_pos)
			var source_id = child.get_cell_source_id(tile_pos)
			
			if child.name == "Water" and source_id != -1:
				return false
			if child.name == "Foam" and source_id != -1:
				return false
			if child.name == "Rocks" and source_id != -1:
				return false
	
	return true

func create_enemy_at_position(spawn_pos: Vector2):
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.z_index = 1
	enemy_instance.position = spawn_pos
	
	get_parent().add_child(enemy_instance)

func get_spawn_info() -> String:
	var player_level = player.get_level() if player else 1
	return "Nível " + str(player_level) + " | Timer: " + str(snappedf(current_spawn_timer, 0.1)) + "s | Inimigos: " + str(enemies_per_spawn)
