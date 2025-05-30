extends CharacterBody2D

const SPEED = 250.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_scene = preload("res://Scenes/Weapons/weapon.tscn")
var weapon_instance

func _ready():
	# Adicionar player ao grupo
	add_to_group("Player")
	
	# Usar call_deferred para adicionar a weapon
	call_deferred("setup_weapon")

func setup_weapon():
	weapon_instance = weapon_scene.instantiate()
	get_parent().add_child(weapon_instance)
	print("Weapon instanciada!")

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
