extends CharacterBody2D
class_name SimpleBoss

# Variáveis do boss
@export var max_health: float = 200.0
@export var movement_speed: float = 60.0
@export var damage: float = 25.0
@export var detection_range: float = 150.0
@export var attack_range: float = 40.0
@export var attack_cooldown_time: float = 2.0

# Variáveis internas
var current_health: float
var target_player: Node2D = null
var attack_cooldown: float = 0.0
var is_poisoned: bool = false
var poison_damage: float = 0.0
var poison_timer: float = 0.0

# Referências de nós
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

func _ready():
	# Inicializar variáveis
	current_health = max_health
	
	# Configurar grupos
	add_to_group("enemies")
	add_to_group("boss")  # Grupo especial para bosses
	
	# Configurar collision
	collision_layer = 2  # Layer dos inimigos
	collision_mask = 1   # Mask do player
	
	# Configurar área de ataque
	if attack_area:
		attack_area.body_entered.connect(_on_attack_area_entered)
		attack_area.body_exited.connect(_on_attack_area_exited)
	
	print("Boss spawnou com ", max_health, " de vida!")

func _physics_process(delta):
	handle_poison(delta)
	update_attack_cooldown(delta)
	find_target()
	move_towards_target(delta)
	try_attack()

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
	
	var distance_to_target = global_position.distance_to(target_player.global_position)
	
	# Parar de se mover se estiver no alcance de ataque
	if distance_to_target <= attack_range:
		velocity = Vector2.ZERO
	else:
		# Mover em direção ao player
		var direction = (target_player.global_position - global_position).normalized()
		velocity = direction * movement_speed
	
	move_and_slide()

func update_attack_cooldown(delta):
	if attack_cooldown > 0:
		attack_cooldown -= delta

func try_attack():
	if not target_player or attack_cooldown > 0:
		return
	
	var distance_to_target = global_position.distance_to(target_player.global_position)
	if distance_to_target <= attack_range:
		perform_attack()

func perform_attack():
	if not target_player or not target_player.has_method("take_damage"):
		return
	
	# Aplicar dano ao player
	target_player.take_damage(damage)
	
	# Efeito visual de ataque
	modulate = Color.YELLOW
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Definir cooldown
	attack_cooldown = attack_cooldown_time
	
	print("Boss atacou! Dano: ", damage)

func _on_attack_area_entered(body):
	if body.is_in_group("players"):
		target_player = body

func _on_attack_area_exited(body):
	if body == target_player:
		target_player = null

func take_damage(amount: float):
	current_health -= amount
	
	# Efeito visual de dano (piscar vermelho)
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	print("Boss recebeu ", amount, " de dano. Vida: ", current_health, "/", max_health)
	
	if current_health <= 0:
		die()

func apply_knockback(knockback_force: Vector2):
	# Aplicar knockback ao boss (bosses são mais resistentes)
	var reduced_knockback = knockback_force * 0.3  # Bosses recebem menos knockback
	velocity += reduced_knockback
	print("Boss recebeu knockback reduzido: ", reduced_knockback)

func apply_poison(damage: float, duration: float):
	is_poisoned = true
	poison_damage = damage
	poison_timer = duration
	print("Boss foi envenenado!")

func handle_poison(delta):
	if is_poisoned:
		poison_timer -= delta
		
		# Aplicar dano de veneno a cada segundo
		if int(poison_timer) != int(poison_timer + delta):
			current_health -= poison_damage
			print("Boss - Dano de veneno: ", poison_damage)
			
			if current_health <= 0:
				die()
		
		# Remover veneno quando acabar
		if poison_timer <= 0:
			is_poisoned = false
			print("Veneno do boss acabou")

func die():
	print("Boss foi derrotado!")
	
	# Dar experiência massiva ao player
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.has_method("gain_experience"):
			player.gain_experience(200)  # Experiência de boss
	
	# Efeito de morte
	modulate = Color.BLACK
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
	tween.tween_callback(queue_free)