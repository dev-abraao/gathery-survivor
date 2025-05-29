extends Node2D

@onready var player = get_parent().get_node("Player")
@onready var enemy_scene = preload("res://Enemy.tscn")  # Path to the enemy scene


var spawn_timer : float = 2.5
var time_elapsed : float = 0.0

var min_spawn_distance = 600.0
var max_spawn_distance = 800.0

func _process(delta):
	time_elapsed += delta
	
	if time_elapsed >= spawn_timer:
		time_elapsed = 0
		spawn_enemy()

func spawn_enemy():
	var enemy_instance = enemy_scene.instantiate()
	
	var random_angle = randf() * 2 * PI
	var random_distance = randf_range(min_spawn_distance, max_spawn_distance)
	var spawn_pos = player.position + Vector2(
		cos(random_angle) * random_distance,
		sin(random_angle) * random_distance
	)
	
	enemy_instance.position = spawn_pos
	
	var parent = get_parent()
	var tree_index = -1
	
	for i in range(parent.get_child_count()):
		var node = parent.get_child(i)
		if "Trees" in node.name:  # Adjust this condition based on your tree naming
			tree_index = i
			break
	
	if tree_index != -1:
		parent.add_child.call_deferred(enemy_instance)
		parent.move_child.call_deferred(enemy_instance, tree_index)
	else:
		parent.add_child(enemy_instance)

func _ready() -> void:
	pass
