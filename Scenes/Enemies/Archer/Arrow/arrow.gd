extends Area2D

var speed: float = 350.0
var damage: int = 25
var direction: Vector2
var lifetime: float = 5.0  
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
    body_entered.connect(_on_body_entered)
    
    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = lifetime
    timer.one_shot = true
    timer.timeout.connect(queue_free)
    timer.start()

func _physics_process(delta):
    position += direction * speed * delta
    
    if sprite:
        sprite.rotation = direction.angle()

func set_direction(target_direction: Vector2):
    direction = target_direction.normalized()

func _on_body_entered(body):
    if body.is_in_group("Player"):
        if body.has_method("take_damage"):
            body.take_damage(damage)
        
        queue_free()
    elif body.has_method("take_damage") and not body.is_in_group("enemies"):
        queue_free()
