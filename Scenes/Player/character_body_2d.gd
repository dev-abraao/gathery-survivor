extends CharacterBody2D

const SPEED = 250.0
var health = 100.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_scene = preload("res://Scenes/Weapons/weapon.tscn")
var weapon_instance

func _ready():	
	# Usar call_deferred para adicionar a weapon
	call_deferred("setup_weapon")

func setup_weapon():
	weapon_instance = weapon_scene.instantiate()
	get_parent().add_child(weapon_instance)
	weapon_instance.z_index = 1
	print("Weapon instanciada!")
	
func take_damage(amount:float):
	var new_health = health - amount
	if new_health <= 0:
		die()
	else:
		health = new_health
		print("Vida do player", health)

func die():
	# Desabilitar movimento e input
	set_process_input(false)
	set_physics_process(false)
	velocity = Vector2.ZERO
	weapon_instance.queue_free()  # Remover a arma
	
	# Tocar animação de morte
	animated_sprite.play("death")
	
	# Criar um timer para mudar de cena após a animação
	var death_timer = Timer.new()
	add_child(death_timer)
	death_timer.wait_time = 1.0  # Ajuste para a duração da sua animação de morte
	death_timer.one_shot = true
	death_timer.timeout.connect(func(): get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn"))
	death_timer.start()

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction.length() > 0:
		direction = direction.normalized()
		velocity = direction * SPEED
		animated_sprite.play("walk")
		animated_sprite.flip_h = direction.x < 0
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta * 10)
		animated_sprite.play("idle")

	move_and_slide()
