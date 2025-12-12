extends CharacterBody2D
class_name TestBoss

# Boss simples apenas para testar a câmera
# Não tem funcionalidade, apenas fica parado

@export var max_health: float = 500.0
@export var damage: float = 30.0
@export var detection_range: float = 120.0
@export var attack_range: float = 40.0
@export var attack_cooldown_time: float = 2.5

var current_health: float
var target_player: Node2D = null
var attack_cooldown: float = 0.0

# Variáveis de knockback
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 400.0  # Boss mais pesado, menos knockback

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	# Inicializar variáveis
	current_health = max_health
	
	# Configurar grupos - IMPORTANTE: adicionar ao grupo "boss"
	add_to_group("enemies")
	add_to_group("boss")  # Grupo especial para bosses (para câmera)
	
	# Configurar collision
	collision_layer = 2  # Layer dos inimigos
	collision_mask = 1   # Mask do player
	
	print("Test Boss spawnou! Câmera deve detectar automaticamente.")

func _physics_process(delta):
	handle_knockback(delta)
	update_attack_cooldown(delta)
	find_target()
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
	
	# Calcular direção do knockback (do boss para o player)
	var knockback_direction = (target_player.global_position - global_position).normalized()
	var knockback_force = knockback_direction * 200.0  # Boss faz mais knockback
	
	# Aplicar dano ao player
	target_player.take_damage(damage, knockback_force)
	
	# Efeito visual de ataque
	modulate = Color.YELLOW
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)
	
	# Definir cooldown
	attack_cooldown = attack_cooldown_time
	
	print("Boss atacou o player! Dano: ", damage)

func take_damage(amount: float, knockback_force: Vector2 = Vector2.ZERO):
	current_health -= amount
	
	# Aplicar knockback reduzido (boss é mais pesado)
	if knockback_force != Vector2.ZERO:
		apply_knockback(knockback_force * 0.3)  # Boss recebe menos knockback
	
	# Efeito visual de dano (piscar vermelho)
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Mostrar número de dano
	show_damage_number(amount, "boss")
	
	print("Test Boss recebeu ", amount, " de dano. Vida: ", current_health, "/", max_health)
	
	if current_health <= 0:
		die()

func apply_knockback(force: Vector2):
	knockback_velocity = force

func handle_knockback(delta):
	if knockback_velocity.length() > 0:
		# Aplicar knockback à posição (boss não usa move_and_slide)
		global_position += knockback_velocity * delta
		
		# Reduzir knockback gradualmente
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)

func show_damage_number(damage: float, damage_type: String = "boss"):
	# Carregar e instanciar número de dano
	var damage_number_scene = load("res://_Core/DamageNumber.tscn")
	var damage_number = damage_number_scene.instantiate()
	
	# Posicionar acima do boss
	damage_number.global_position = global_position + Vector2(randf_range(-25, 25), -40)
	
	# Configurar dano
	damage_number.setup_damage(damage, damage_type)
	
	# Adicionar à cena
	get_parent().add_child(damage_number)

func die():
	print("Test Boss foi derrotado!")
	
	# Dropar múltiplas orbs de XP (boss)
	drop_boss_xp_orbs()
	
	# Efeito de morte
	modulate = Color.BLACK
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
	tween.tween_callback(queue_free)

func drop_boss_xp_orbs():
	# Boss dropa múltiplas orbs
	var orb_count = randi_range(3, 5)
	
	for i in orb_count:
		var xp_orb_scene = load("res://_Core/XPOrb.tscn")
		var xp_orb = xp_orb_scene.instantiate()
		
		# Posicionar ao redor do boss
		var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		xp_orb.global_position = global_position + offset
		
		# Configurar como orb de boss
		xp_orb.setup_xp_orb(50, "boss")
		
		# Adicionar à cena
		get_parent().add_child(xp_orb)