extends Control

@onready var health_button = $CenterContainer/Panel/VBoxContainer/OptionsContainer/PlayerSection/PlayerPanel/PlayerOptions/HealthButton
@onready var speed_button = $CenterContainer/Panel/VBoxContainer/OptionsContainer/PlayerSection/PlayerPanel/PlayerOptions/SpeedButton
@onready var damage_button = $CenterContainer/Panel/VBoxContainer/OptionsContainer/WeaponSection/WeaponPanel/WeaponOptions/DamageButton
@onready var rotation_button = $CenterContainer/Panel/VBoxContainer/OptionsContainer/WeaponSection/WeaponPanel/WeaponOptions/RotationButton
@onready var new_weapon_button = $CenterContainer/Panel/VBoxContainer/OptionsContainer/WeaponSection/WeaponPanel/WeaponOptions/NewWeaponButton

var player: CharacterBody2D

func _ready():
    print("Menu de level up carregado!")
    get_tree().paused = true
    
    player = get_tree().get_first_node_in_group("Player")
    
    # Conectar botões
    health_button.pressed.connect(_on_health_upgrade)
    speed_button.pressed.connect(_on_speed_upgrade)
    damage_button.pressed.connect(_on_damage_upgrade)
    rotation_button.pressed.connect(_on_rotation_upgrade)
    new_weapon_button.pressed.connect(_on_new_weapon_upgrade)
    
    update_button_texts()
    update_button_availability()
    create_entrance_effect()

func update_button_texts():
    if player:
        health_button.text = "❤️ +50 Health\nCurrent: " + str(int(player.health)) + "/" + str(int(player.max_health))
        speed_button.text = "⚡ +50 Speed\nCurrent: " + str(int(player.current_speed))
        damage_button.text = "💥 +50% Damage\nCurrent: " + player.get_damage_info()
        rotation_button.text = "🌪️ +40% Rotation\nCurrent: " + player.get_speed_info()
        
        var weapon_count = player.get_weapon_count()
        new_weapon_button.text = "⚔️ New Weapon\nActive: " + str(weapon_count) + "/4"

func update_button_availability():
    if player and player.get_weapon_count() >= 4:
        new_weapon_button.disabled = true
        new_weapon_button.text = "❌ Max Weapons\n(4/4 active)"

func create_entrance_effect():
    scale = Vector2(0.5, 0.5)
    modulate = Color.TRANSPARENT
    var tween = create_tween()
    tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.3)
    tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.3)

func _on_health_upgrade():
    if player: player.upgrade_health()
    close_menu()

func _on_speed_upgrade():
    if player: player.upgrade_speed()
    close_menu()

func _on_damage_upgrade():
    if player: player.upgrade_weapon_damage()
    close_menu()

func _on_rotation_upgrade():
    if player: player.upgrade_weapon_speed()
    close_menu()

func _on_new_weapon_upgrade():
    if player: player.add_new_weapon()
    close_menu()

func close_menu():
    var tween = create_tween()
    tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.2)
    tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
    tween.tween_callback(func():
        get_tree().paused = false
        var parent = get_parent()
        if parent is CanvasLayer:
            parent.queue_free()
        else:
            queue_free()
    )
