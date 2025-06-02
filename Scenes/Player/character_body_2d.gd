extends CharacterBody2D

const SPEED = 250.0
var health = 100.0
var max_health = 100.0  # <- Adicionar esta linha
var is_dead = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_scene = preload("res://Scenes/Weapons/weapon.tscn")
@onready var level_up_menu_scene = preload("res://level_up_menu.tscn")

var weapon_instance
var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 10
var xp_base: int = 10
var xp_multiplier: float = 1.5
var current_speed: float = 250.0

func _ready():
    add_to_group("Player")
    call_deferred("setup_weapon")

func setup_weapon():
    weapon_instance = weapon_scene.instantiate()
    get_parent().add_child(weapon_instance)
    weapon_instance.z_index = 1
    print("Weapon instanciada!")

func take_damage(amount:float):
    var new_health = health - amount

    modulate = Color.YELLOW
    var tween = create_tween()
    tween.tween_property(self, "modulate", Color.WHITE, 0.1)
    
    if new_health <= 0:
        die()
        is_dead = true
    else:
        health = new_health
        print("Vida do player: ", health, "/", max_health)

func die():
    if is_dead:
        return
    set_process_input(false)
    set_physics_process(false)
    velocity = Vector2.ZERO
    weapon_instance.queue_free()
    
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

    while current_xp >= xp_to_next_level:
        level_up_player()

func show_level_up_menu():
    print("Mostrando menu de level up...")
    
    var canvas_layer = CanvasLayer.new()
    canvas_layer.layer = 100
    get_tree().current_scene.add_child(canvas_layer)

    var menu = level_up_menu_scene.instantiate()
    canvas_layer.add_child(menu)

func upgrade_health():
    # Aumentar vida máxima e vida atual
    max_health += 30.0
    health = max_health  # Heal completo ao fazer upgrade
    print("Vida máxima aumentada para: ", max_health)

func upgrade_speed():
    current_speed += 50.0  # +50 de velocidade
    print("Velocidade aumentada para: ", current_speed)

func level_up_player():
    current_xp -= xp_to_next_level
    current_level += 1
    
    xp_to_next_level = int(xp_base * pow(xp_multiplier, current_level - 1))
    
    print("*** LEVEL UP! *** Nível ", current_level)
    
    # Mostrar menu de level up
    show_level_up_menu()

func create_level_up_effect():
    modulate = Color.GOLD
    var tween = create_tween()
    tween.tween_property(self, "modulate", Color.WHITE, 0.5)

func get_level() -> int:
    return current_level

func _physics_process(delta: float) -> void:
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

    if direction.length() > 0:
        direction = direction.normalized()
        velocity = direction * current_speed  # Usar current_speed em vez de SPEED
        animated_sprite.play("walk")
        animated_sprite.flip_h = direction.x < 0
    else:
        velocity = velocity.move_toward(Vector2.ZERO, current_speed * delta * 10)
        animated_sprite.play("idle")

    move_and_slide()
