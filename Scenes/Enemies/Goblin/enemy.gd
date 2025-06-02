extends CharacterBody2D

@onready var player = get_parent().get_node("Player")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const speed = 100.0
const attack_range = 100.0
const attack_cooldown = 1.5

var is_attacking = false
var attack_timer = 0.0
var max_health = 30
var current_health = 30
var is_dead = false

func _ready():
	add_to_group("enemies")
	current_health = max_health

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		return
	
	if attack_timer > 0:
		attack_timer -= delta
	
	var distance_to_player = position.distance_to(player.position)
	
	if is_attacking:
		return
	
	if distance_to_player <= attack_range and attack_timer <= 0:
		attack()
		return
	
	if distance_to_player <= attack_range:
		animated_sprite.play("idle")
		return
	
	var direction = (player.position - position).normalized()
	velocity = direction * speed
	
	animated_sprite.play("walk")
	animated_sprite.flip_h = (player.position.x < position.x)
	
	move_and_slide()

func attack():
	if is_dead:
		return
		
	is_attacking = true
	attack_timer = attack_cooldown
	velocity = Vector2.ZERO
	
	animated_sprite.flip_h = (player.position.x < position.x)
	animated_sprite.play("attack")
	
	if not animated_sprite.animation_finished.is_connected(_on_attack_finished):
		animated_sprite.animation_finished.connect(_on_attack_finished)

func _on_attack_finished():
	if animated_sprite.animation == "attack" and not is_dead:
		is_attacking = false
		deal_damage_to_player()

func deal_damage_to_player():
	if is_dead:
		return
		
	var distance_to_player = position.distance_to(player.position)
	if distance_to_player <= attack_range:
		player.take_damage(50)

func take_damage(amount: int):
	if is_dead:
		return
		
	current_health -= amount
	print("Inimigo levou ", amount, " de dano! Vida: ", current_health)
	
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	if current_health <= 0:
		die()

func die():
	if is_dead:
		return

	is_dead = true
	print("Inimigo morreu!")

	velocity = Vector2.ZERO
	is_attacking = false
	set_collision_layer(0)
	set_collision_mask(0)
	remove_from_group("enemies")
	drop_xp()

	animated_sprite.play("death")

	var death_timer = Timer.new()
	add_child(death_timer)
	death_timer.wait_time = 1.4
	death_timer.one_shot = true
	death_timer.timeout.connect(queue_free)
	death_timer.start()

func drop_xp():
	var xp_orb_scene = preload("res://Scenes/XP/xporb.tscn")
	var xp_orb = xp_orb_scene.instantiate()
	
	xp_orb.global_position = global_position
	
	var xp_amount = randi_range(1, 3)
	xp_orb.set_xp_value(xp_amount)
	
	get_parent().add_child(xp_orb)
