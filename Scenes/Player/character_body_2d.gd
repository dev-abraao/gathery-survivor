extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_scene = preload("res://Scenes/Weapons/weapon.tscn")
@onready var level_up_menu_scene = preload("res://Scenes/Leveling Menu/level_up_menu.tscn")
@onready var ui = get_tree().get_first_node_in_group("UI")

var weapons: Array = []
var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 10
var xp_base: int = 10
var xp_multiplier: float = 1.5
var current_speed: float = 250.0
var health = 200.0
var max_health = 200.0
var is_dead = false

var damage_multiplier: float = 1.0
var rotation_multiplier: float = 1.0

func _ready():
	add_to_group("Player")
	call_deferred("setup_weapon")
	call_deferred("connect_to_ui")

func connect_to_ui():
	ui = get_tree().get_first_node_in_group("UI")
	if ui:
		ui.set_max_health(max_health)
		ui.set_health(health)
	else:
		await get_tree().create_timer(0.5).timeout
		connect_to_ui()

func setup_weapon():
	create_weapon()
	print("Primeira arma criada!")

func create_weapon():
	var weapon = weapon_scene.instantiate()
	get_parent().add_child(weapon)
	weapon.z_index = 1

	weapon.set_damage(int(10 * damage_multiplier))
	weapon.set_orbit_speed(3.0 * rotation_multiplier)

	weapons.append(weapon)

	redistribute_weapons()
	
	print("Arma criada! Total: ", weapons.size())

func redistribute_weapons():
	var total_weapons = weapons.size()
	
	for i in range(total_weapons):
		var weapon = weapons[i]
		if is_instance_valid(weapon):
				var angle = (2 * PI / total_weapons) * i
				weapon.current_angle = angle

				var radius = 80.0
				weapon.set_orbit_radius(radius)

				print("Arma ", i, " reposicionada - Ângulo: ", rad_to_deg(angle), "° - Raio: ", radius)

func take_damage(amount: float):
	var new_health = health - amount

	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	if new_health <= 0:
		die()
		is_dead = true
	else:
		health = new_health
		if ui:
			ui.set_health(health)
		print("Vida do player: ", health, "/", max_health)

func die():
	if is_dead:
		return
	set_process_input(false)
	set_physics_process(false)
	velocity = Vector2.ZERO

	if ui:
		ui.set_health(0)
	
	for weapon in weapons:
		if is_instance_valid(weapon):
			weapon.queue_free()
	
	animated_sprite.play("death")
	
	var death_timer = Timer.new()
	add_child(death_timer)
	death_timer.wait_time = 1.0
	death_timer.one_shot = true
	death_timer.timeout.connect(func(): get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn"))
	death_timer.start()

func gain_xp(amount: int):
	current_xp += amount
	print("Ganhou ", amount, " XP! Total: ", current_xp, "/", xp_to_next_level)
	if ui:
		ui.set_xp(current_xp)

	while current_xp >= xp_to_next_level:
		level_up_player()

func show_level_up_menu():
	print("Mostrando menu de level up...")
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	get_tree().current_scene.add_child(canvas_layer)

	var menu = level_up_menu_scene.instantiate()
	canvas_layer.add_child(menu)

# UPGRADES DO PLAYER
func upgrade_health():
	max_health += 30.0
	health = max_health  # Heal completo
	print("❤️ Vida máxima aumentada para: ", max_health)
	create_upgrade_effect(Color.GREEN)

	if ui:
		ui.set_max_health(max_health)
		ui.set_health(health)

func upgrade_speed():
	current_speed += 50.0
	print("⚡ Velocidade aumentada para: ", current_speed)
	create_upgrade_effect(Color.CYAN)

# UPGRADES DAS ARMAS
func upgrade_weapon_damage():
	damage_multiplier += 0.5  # +50% dano
	
	# Atualizar todas as armas
	for weapon in weapons:
		if is_instance_valid(weapon):
			weapon.set_damage(int(10 * damage_multiplier))
	
	print("💥 Dano das armas aumentado! Dano atual: ", int(10 * damage_multiplier))
	create_upgrade_effect(Color.RED)

func upgrade_weapon_speed():
	rotation_multiplier += 0.4
	
	for weapon in weapons:
		if is_instance_valid(weapon):
			weapon.set_orbit_speed(3.0 * rotation_multiplier)
	
	print("🌪️ Velocidade de rotação aumentada! Velocidade atual: ", 3.0 * rotation_multiplier)
	create_upgrade_effect(Color.YELLOW)

func add_new_weapon():
	if weapons.size() >= 4:
		print("❌ Número máximo de armas atingido!")
		return
	
	create_weapon()
	print("⚔️ Nova arma adicionada!")
	create_upgrade_effect(Color.MAGENTA)

func create_upgrade_effect(color: Color):
	modulate = color
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)

func level_up_player():
	current_xp -= xp_to_next_level
	current_level += 1
	
	xp_to_next_level = int(xp_base * pow(xp_multiplier, current_level - 1))
	if ui:
		ui.set_xp_to_next_level(xp_to_next_level)
		ui.set_xp(current_xp)
	
	print("🎉 *** LEVEL UP! *** Nível ", current_level)
	create_upgrade_effect(Color.GOLD)
	show_level_up_menu()

func get_level() -> int:
	return current_level

func get_weapon_count() -> int:
	weapons = weapons.filter(func(weapon): return is_instance_valid(weapon))
	return weapons.size()

func get_damage_info() -> String:
	return str(int(10 * damage_multiplier))

func get_speed_info() -> String:
	return str(snappedf(3.0 * rotation_multiplier, 0.1))

func get_health() -> int:
	return int(health)

func get_max_health() -> int:
	return int(max_health)

func get_xp() -> int:
	return current_xp
func get_xp_to_next_level() -> int:
	return xp_to_next_level

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction.length() > 0:
		direction = direction.normalized()
		velocity = direction * current_speed
		animated_sprite.play("walk")
		animated_sprite.flip_h = direction.x < 0
	else:
		velocity = velocity.move_toward(Vector2.ZERO, current_speed * delta * 10)
		animated_sprite.play("idle")

	move_and_slide()
