extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

var player: CharacterBody2D
var orbit_radius: float = 80.0  # Distância da espada do player
var orbit_speed: float = 3.0    # Velocidade de rotação
var current_angle: float = 0.0

var damage: int = 10
var hit_cooldown: float = 0.5   # Tempo entre danos no mesmo inimigo
var enemies_hit: Dictionary = {}  # Controlar cooldown por inimigo

func _ready():
	print("Weapon iniciada!")
	
	# Encontrar o player
	player = get_tree().get_first_node_in_group("Player")
	if not player:
		print("Player não encontrado!")
		return
	
	# Conectar sinais de colisão
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _process(delta):
	if not player:
		return
	
	# Atualizar ângulo de rotação (gira ao redor do player)
	current_angle += orbit_speed * delta
	if current_angle > 2 * PI:
		current_angle -= 2 * PI
	
	# Calcular nova posição ao redor do player
	var offset = Vector2(cos(current_angle), sin(current_angle)) * orbit_radius
	global_position = player.global_position + offset
	
	# Rotacionar sprite para dar efeito de "corte"
	sprite.rotation = current_angle + PI/2  # +90 graus para alinhar
	
	# Limpar cooldowns expirados
	cleanup_hit_cooldowns(delta)

func cleanup_hit_cooldowns(delta):
	var keys_to_remove = []
	for enemy in enemies_hit.keys():
		# Verificar se o inimigo ainda existe
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
		# Verificar se o inimigo está em cooldown
		if body in enemies_hit:
			return
		
		print("Espada acertou inimigo!")
		
		# Causar dano ao inimigo
		if body.has_method("take_damage"):
			body.take_damage(damage)
			
			# Adicionar ao cooldown apenas se o inimigo ainda estiver vivo
			if is_instance_valid(body):
				enemies_hit[body] = hit_cooldown

func _on_body_exited(body):
	# Quando inimigo sai da área ou morre, remove do cooldown
	if body in enemies_hit:
		enemies_hit.erase(body)

# Funções para customizar (opcionais)
func set_orbit_radius(new_radius: float):
	orbit_radius = new_radius

func set_orbit_speed(new_speed: float):
	orbit_speed = new_speed

func set_damage(new_damage: int):
	damage = new_damage
	
