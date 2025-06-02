extends Control

@onready var health_button = $CenterContainer/Panel/VBoxContainer/OptionsContainer/PlayerSection/PlayerPanel/PlayerOptions/HealthButton
@onready var speed_button = $CenterContainer/Panel/VBoxContainer/OptionsContainer/PlayerSection/PlayerPanel/PlayerOptions/SpeedButton
@onready var damage_button = $CenterContainer/Panel/VBoxContainer/OptionsContainer/WeaponSection/WeaponPanel/WeaponOptions/DamageButton
@onready var rotation_button = $CenterContainer/Panel/VBoxContainer/OptionsContainer/WeaponSection/WeaponPanel/WeaponOptions/RotationButton
@onready var new_weapon_button = $CenterContainer/Panel/VBoxContainer/OptionsContainer/WeaponSection/WeaponPanel/WeaponOptions/NewWeaponButton

var player: CharacterBody2D
var weapon_manager: Node

func _ready():
    print("Menu de level up carregado!")

    get_tree().paused = true

    player = get_tree().get_first_node_in_group("Player")
    weapon_manager = get_tree().get_first_node_in_group("WeaponManager")

    health_button.pressed.connect(_on_health_upgrade)
    speed_button.pressed.connect(_on_speed_upgrade)
    damage_button.pressed.connect(_on_damage_upgrade)
    rotation_button.pressed.connect(_on_rotation_upgrade)
    new_weapon_button.pressed.connect(_on_new_weapon_upgrade)

    update_button_availability()

    create_entrance_effect()

func create_entrance_effect():
    scale = Vector2(0.5, 0.5)
    modulate = Color.TRANSPARENT
    
    var tween = create_tween()
    tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.3)
    tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.3)

func update_button_availability():
    # Por enquanto, deixar todas as opções disponíveis
    # Depois implementaremos o sistema de weapon manager
    pass

func _on_health_upgrade():
    print("Upgrade de vida selecionado!")
    if player and player.has_method("upgrade_health"):
        player.upgrade_health()
    close_menu()

func _on_speed_upgrade():
    print("Upgrade de velocidade selecionado!")
    if player and player.has_method("upgrade_speed"):
        player.upgrade_speed()
    close_menu()

func _on_damage_upgrade():
    print("Upgrade de dano selecionado!")
    # Por enquanto só printar, depois implementaremos weapon manager
    close_menu()

func _on_rotation_upgrade():
    print("Upgrade de rotação selecionado!")
    # Por enquanto só printar, depois implementaremos weapon manager
    close_menu()

func _on_new_weapon_upgrade():
    print("Nova arma selecionada!")
    # Por enquanto só printar, depois implementaremos weapon manager
    close_menu()

func close_menu():
    print("Fechando menu de level up...")
    
    var tween = create_tween()
    tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.2)
    tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
    tween.tween_callback(func():
        get_tree().paused = false
        print("Jogo despausado!")
        queue_free()
    )
