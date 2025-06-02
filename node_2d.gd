extends Node2D

var ui_scene = preload("res://Scenes/GameUI/UI.tscn")

func _ready():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	add_child(canvas_layer)
	
	var ui_instance = ui_scene.instantiate()
	canvas_layer.add_child(ui_instance)
	
	ui_instance.add_to_group("UI")
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.connect_to_ui()
