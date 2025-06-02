extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

var player: CharacterBody2D
var orbit_radius: float = 80.0
var orbit_speed: float = 3.0
var current_angle: float = 0.0

var damage: int = 10
var hit_cooldown: float = 0.5
var enemies_hit: Dictionary = {}

func _ready():
	print("Weapon iniciada!")

	player = get_tree().get_first_node_in_group("Player")
	if not player:
		return

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _process(delta):
	if not player:
		return

	current_angle += orbit_speed * delta
	if current_angle > 2 * PI:
		current_angle -= 2 * PI

	var offset = Vector2(cos(current_angle), sin(current_angle)) * orbit_radius
	global_position = player.global_position + offset

	sprite.rotation = current_angle + PI / 4 
	cleanup_hit_cooldowns(delta)

func cleanup_hit_cooldowns(delta):
	var keys_to_remove = []
	for enemy in enemies_hit.keys():
		if not is_instance_valid(enemy):
			keys_to_remove.append(enemy)
			continue
			
		enemies_hit[enemy] -= delta
		if enemies_hit[enemy] <= 0:
			keys_to_remove.append(enemy)
	
	for key in keys_to_remove:
		enemies_hit.erase(key)

func _on_body_entered(body):
	if body.is_in_group("enemies") and is_instance_valid(body):
		if body in enemies_hit:
			return
		
		
		if body.has_method("take_damage"):
			body.take_damage(damage)
			
			if is_instance_valid(body):
				enemies_hit[body] = hit_cooldown

func _on_body_exited(body):
	if body in enemies_hit:
		enemies_hit.erase(body)

# Funções para customizar (opcionais)
func set_orbit_radius(new_radius: float):
	orbit_radius = new_radius

func set_orbit_speed(new_speed: float):
	orbit_speed = new_speed

func set_damage(new_damage: int):
	damage = new_damage
	
