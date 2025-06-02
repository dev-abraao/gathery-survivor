extends Control

var player : CharacterBody2D

# Animation settings
var animation_duration: float = 0.3
var health_tween: Tween
var xp_tween: Tween

func _ready() -> void:
	print("teste barra de vida carregada!")
	add_to_group("UI")
	
	
	player = get_tree().get_first_node_in_group("Player")
	if player:
		var health = player.get_health()
		var max_health = player.get_max_health()
		$HP/HealthBar.value = health
		$HP/HealthBar.max_value = max_health
		$HP/Label.text = str(int(health))
		$XPBar.value = player.get_xp()
		$XPBar.max_value = player.get_xp_to_next_level()

func set_health(new_health) -> void:
	if health_tween:
		health_tween.kill()
	
	health_tween = create_tween()
	health_tween.tween_property($HP/HealthBar, "value", new_health, animation_duration)
	$HP/Label.text = str(int(new_health))
	
	print("UI: Health updated to ", new_health)

func set_max_health(new_max_health) -> void:
	$HP/HealthBar.max_value = new_max_health
	print("UI: Max health updated to ", new_max_health)

func set_xp(new_xp) -> void:
	if xp_tween:
		xp_tween.kill()
	
	xp_tween = create_tween()
	xp_tween.tween_property($XPBar, "value", new_xp, animation_duration)

func set_xp_to_next_level(new_xp_to_next_level) -> void:
	$XPBar.max_value = new_xp_to_next_level
