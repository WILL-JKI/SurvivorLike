extends Area2D
class_name XPOrb

# Orb de experiência que é coletada pelo player

@export var xp_value: int = 10
@export var collection_distance: float = 30.0
@export var attraction_distance: float = 80.0
@export var attraction_speed: float = 200.0
@export var float_speed: float = 20.0

var target_player: Node2D = null
var is_being_attracted: bool = false
var lifetime: float = 30.0  # Orb desaparece após 30 segundos
var float_direction: Vector2

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready():
	# Configurar grupos e sinais
	add_to_group("xp_orbs")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Configurar timer de vida
	lifetime_timer.wait_time = lifetime
	lifetime_timer.timeout.connect(_on_lifetime_expired)
	lifetime_timer.start()
	
	# Configurar collision
	collision_layer = 8   # Layer das orbs
	collision_mask = 1    # Mask do player
	
	# Movimento inicial aleatório
	float_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	# Efeito visual inicial
	create_spawn_effect()

func _physics_process(delta):
	find_nearest_player()
	handle_movement(delta)
	handle_attraction(delta)

func find_nearest_player():
	var players = get_tree().get_nodes_in_group("players")
	var nearest_player: Node2D = null
	var nearest_distance: float = attraction_distance
	
	for player in players:
		if not is_instance_valid(player):
			continue
		
		var distance = global_position.distance_to(player.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_player = player
	
	target_player = nearest_player

func handle_movement(delta):
	if not is_being_attracted:
		# Movimento flutuante suave
		global_position += float_direction * float_speed * delta
		
		# Mudar direção ocasionalmente
		if randf() < 0.02:  # 2% de chance por frame
			float_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func handle_attraction(delta):
	if not target_player:
		is_being_attracted = false
		return
	
	var distance_to_player = global_position.distance_to(target_player.global_position)
	
	# Verificar se deve ser coletada
	if distance_to_player <= collection_distance:
		collect_orb()
		return
	
	# Verificar se deve ser atraída
	if distance_to_player <= attraction_distance:
		is_being_attracted = true
		
		# Mover em direção ao player
		var direction = (target_player.global_position - global_position).normalized()
		var speed = attraction_speed * (1.0 + (attraction_distance - distance_to_player) / attraction_distance)
		global_position += direction * speed * delta
	else:
		is_being_attracted = false

func collect_orb():
	# Dar experiência ao player
	if target_player and target_player.has_method("gain_experience"):
		target_player.gain_experience(xp_value)
	
	# Efeito visual de coleta
	create_collection_effect()
	
	# Remover orb
	queue_free()

func create_spawn_effect():
	# Efeito de spawn (escala crescente)
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func create_collection_effect():
	# Efeito de coleta (brilho e desaparecimento)
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0), 0.2)

func _on_body_entered(body):
	if body.is_in_group("players"):
		collect_orb()

func _on_area_entered(area):
	if area.is_in_group("players"):
		collect_orb()

func _on_lifetime_expired():
	# Efeito de desaparecimento por tempo
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.0)
	tween.tween_callback(queue_free)

# Configurar valor da orb
func setup_xp_orb(value: int, orb_type: String = "normal"):
	xp_value = value
	
	# Diferentes tipos de orb
	match orb_type:
		"small":
			xp_value = 5
			modulate = Color.CYAN
			scale = Vector2(0.8, 0.8)
		"normal":
			xp_value = 10
			modulate = Color.YELLOW
		"large":
			xp_value = 25
			modulate = Color.ORANGE
			scale = Vector2(1.2, 1.2)
		"boss":
			xp_value = 100
			modulate = Color.PURPLE
			scale = Vector2(1.5, 1.5)
		_:
			modulate = Color.YELLOW