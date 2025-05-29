extends Node2D

@onready var player = get_parent().get_node("Player")
@onready var enemy_scene = get_parent().get_node("Enemy")

# Reference to the enemy scene (assuming Enemy is a scene, not just a node)

var spawn_timer : float = 2.5
var time_elapsed : float = 0.0

# Spawn settings
var min_spawn_distance = 600.0
var max_spawn_distance = 800.0

func _process(delta):
	time_elapsed += delta
	
	if time_elapsed >= spawn_timer:
		time_elapsed = 0
		spawn_enemy()

func spawn_enemy():
	# Create a new instance of the enemy scene
	var enemy_instance = get_parent().get_node("Enemy").duplicate()
	
	# Set spawn position in a circle around the player
	var random_angle = randf() * 2 * PI
	var random_distance = randf_range(min_spawn_distance, max_spawn_distance)
	var spawn_pos = player.position + Vector2(
		cos(random_angle) * random_distance,
		sin(random_angle) * random_distance
	)
	
	enemy_instance.position = spawn_pos
	
	# Add the enemy to the main scene
	get_parent().add_child(enemy_instance)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
