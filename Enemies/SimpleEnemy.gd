extends CharacterBody2D
class_name SimpleEnemy

# Variáveis do inimigo
@export var max_health: float = 50.0
@export var movement_speed: float = 80.0
@export var damage: float = 15.0
@export var detection_range: float = 100.0

# Variáveis internas
var current_health: float
var target_player: Node2D = null
var is_poisoned: bool = false
var poison_damage: float = 0.0
var poison_timer: float = 0.0

# Referências de nós
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	# Inicializar variáveis
	current_health = max_health
	
	# Configurar grupos
	add_to_group("enemies")
	
	# Configurar collision
	collision_layer = 2  # Layer dos inimigos
	collision_mask = 1   # Mask do player

func _physics_process(delta):
	handle_poison(delta)
	find_target()
	move_towards_target(delta)

func find_target():
	# Procurar o player mais próximo
	var players = get_tree().get_nodes_in_group("players")
	var nearest_player: Node2D = null
	var nearest_distance: float = detection_range
	
	for player in players:
		if not is_instance_valid(player):
			continue
		
		var distance = global_position.distance_to(player.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_player = player
	
	target_player = nearest_player

func move_towards_target(delta):
	if not target_player:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Mover em direção ao player
	var direction = (target_player.global_position - global_position).normalized()
	velocity = direction * movement_speed
	move_and_slide()

func take_damage(amount: float):
	current_health -= amount
	
	# Efeito visual de dano (piscar vermelho)
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	print("Inimigo recebeu ", amount, " de dano. Vida: ", current_health)
	
	if current_health <= 0:
		die()

func apply_poison(damage: float, duration: float):
	is_poisoned = true
	poison_damage = damage
	poison_timer = duration
	print("Inimigo foi envenenado!")

func handle_poison(delta):
	if is_poisoned:
		poison_timer -= delta
		
		# Aplicar dano de veneno a cada segundo
		if int(poison_timer) != int(poison_timer + delta):
			current_health -= poison_damage
			print("Dano de veneno: ", poison_damage)
			
			if current_health <= 0:
				die()
		
		# Remover veneno quando acabar
		if poison_timer <= 0:
			is_poisoned = false
			print("Veneno acabou")

func die():
	print("Inimigo morreu!")
	
	# Dar experiência ao player
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.has_method("gain_experience"):
			player.gain_experience(25)
	
	queue_free()