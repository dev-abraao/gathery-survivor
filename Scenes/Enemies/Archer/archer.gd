extends CharacterBody2D

@onready var player = get_parent().get_node("Player")
@onready var arrow_scene = preload("res://Scenes/Enemies/Archer/Arrow/arrow.tscn")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_sound: AudioStreamPlayer2D = $DamageSound 


const attack_cooldown = 3
var is_attacking = false
var attack_timer = 0.0
var max_health = 20
var current_health = 30
var is_dead = false

func _ready():
	add_to_group("enemies")
	current_health = max_health
	
	var damage_sound_path = "res://Audio/SFX/HitPlayer.mp3"
	var damage_audio = load(damage_sound_path)
	
	if damage_audio and damage_sound:
		damage_sound.stream = damage_audio
		damage_sound.volume_db = -10.0
		print("✅ Som de dano carregado para inimigo")
	else:
		print("❌ Som de dano não encontrado em:", damage_sound_path)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		return
	
	animated_sprite.flip_h = (player.global_position.x < global_position.x)
	
	if attack_timer > 0:
		attack_timer -= delta

	if attack_timer <= 0 and not is_attacking:
		attack()


func attack():
	if is_dead or not player:
		return
		
	is_attacking = true
	attack_timer = attack_cooldown
	
	animated_sprite.play("shoot")
	
	call_deferred("spawn_arrow")

func spawn_arrow():
	if is_dead or not player:
		return
		
	var arrow = arrow_scene.instantiate()
	arrow.global_position = global_position + Vector2(0, -10)
	var direction_to_player = (player.global_position - global_position).normalized()
	arrow.set_direction(direction_to_player)
	get_parent().add_child(arrow)
	is_attacking = false

func take_damage(amount: int):
	if is_dead:
		return
		
	current_health -= amount
	print("Inimigo levou ", amount, " de dano! Vida: ", current_health)
	
	if damage_sound and damage_sound.stream:
		damage_sound.play()
		print("🔊 Som de dano tocado!")
	
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	if current_health <= 0:
		call_deferred("die")

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
	
	call_deferred("drop_xp")

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
