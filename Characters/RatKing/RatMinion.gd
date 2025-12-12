extends Area2D
class_name RatMinion

# Estados do minion
enum State {
	FOLLOW_KING,    # Seguindo o Rat King
	ORGANIZE,       # Se organizando ao redor do King
	CHASE,          # Perseguindo inimigo
	ATTACK          # Atacando inimigo
}

# Variáveis de configuração (modificáveis externamente)
@export var speed: float = 100.0
@export var damage: float = 10.0
@export var is_poisonous: bool = false
@export var is_kamikaze: bool = false
@export var poison_damage: float = 5.0
@export var poison_duration: float = 3.0
@export var detection_range: float = 150.0
@export var attack_range: float = 20.0

# Variáveis internas
var current_state: State = State.FOLLOW_KING
var target_enemy: Node2D = null
var rat_king: Node2D = null
var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 30.0  # Tempo de vida do minion
var attack_cooldown: float = 0.0

# Variáveis de formação
var formation_position: Vector2 = Vector2.ZERO
var formation_angle: float = 0.0
var formation_distance: float = 50.0
var follow_distance: float = 80.0

# Referências de nós
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready():
	# Configurar grupos e sinais
	add_to_group("minions")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Encontrar o Rat King
	find_rat_king()
	
	# Configurar posição na formação
	setup_formation_position()
	
	# Configurar timer de vida
	lifetime_timer.wait_time = lifetime
	lifetime_timer.timeout.connect(_on_lifetime_expired)
	lifetime_timer.start()
	
	# Configurar collision layer/mask
	collision_layer = 4  # Layer dos minions
	collision_mask = 2   # Mask dos inimigos

func _physics_process(delta):
	update_state()
	execute_state(delta)
	
	# Atualizar formação periodicamente
	if current_state == State.ORGANIZE:
		update_formation_position()
	
	# Reduzir cooldown de ataque
	if attack_cooldown > 0:
		attack_cooldown -= delta

func update_state():
	# Sempre verificar se há inimigos próximos primeiro
	target_enemy = find_nearest_enemy()
	
	match current_state:
		State.FOLLOW_KING, State.ORGANIZE:
			if target_enemy:
				current_state = State.CHASE
			else:
				# Verificar se deve seguir ou se organizar
				if not rat_king:
					find_rat_king()
					return
				
				var distance_to_king = global_position.distance_to(rat_king.global_position)
				if distance_to_king > follow_distance:
					current_state = State.FOLLOW_KING
				else:
					current_state = State.ORGANIZE
		
		State.CHASE:
			if not is_instance_valid(target_enemy):
				current_state = State.FOLLOW_KING
				return
			
			var distance = global_position.distance_to(target_enemy.global_position)
			if distance <= attack_range:
				current_state = State.ATTACK
			elif distance > detection_range:
				current_state = State.FOLLOW_KING
		
		State.ATTACK:
			if not is_instance_valid(target_enemy):
				current_state = State.FOLLOW_KING
				return
			
			var distance = global_position.distance_to(target_enemy.global_position)
			if distance > attack_range:
				current_state = State.CHASE

func execute_state(delta):
	match current_state:
		State.FOLLOW_KING:
			follow_rat_king(delta)
		
		State.ORGANIZE:
			organize_around_king(delta)
		
		State.CHASE:
			if target_enemy:
				var direction = (target_enemy.global_position - global_position).normalized()
				velocity = direction * speed
				global_position += velocity * delta
		
		State.ATTACK:
			velocity = Vector2.ZERO
			if attack_cooldown <= 0 and target_enemy:
				perform_attack()

func find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest_enemy: Node2D = null
	var nearest_distance: float = detection_range
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy
	
	return nearest_enemy

func perform_attack():
	if not target_enemy or not target_enemy.has_method("take_damage"):
		return
	
	# Aplicar dano base
	target_enemy.take_damage(damage)
	
	# Aplicar efeitos especiais
	if is_poisonous and target_enemy.has_method("apply_poison"):
		target_enemy.apply_poison(poison_damage, poison_duration)
	
	# Kamikaze: destruir o minion após o ataque
	if is_kamikaze:
		create_explosion_effect()
		queue_free()
		return
	
	# Definir cooldown para próximo ataque
	attack_cooldown = 1.0

func create_explosion_effect():
	# TODO: Adicionar efeito visual de explosão
	# Aplicar dano em área se for kamikaze
	var explosion_radius = 50.0
	var enemies_in_range = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= explosion_radius and enemy.has_method("take_damage"):
			enemy.take_damage(damage * 1.5)  # Dano aumentado para kamikaze

func _on_body_entered(body):
	if body.is_in_group("enemies") and current_state == State.ATTACK:
		if attack_cooldown <= 0:
			perform_attack()

func _on_area_entered(area):
	if area.is_in_group("enemies") and current_state == State.ATTACK:
		if attack_cooldown <= 0:
			perform_attack()

func _on_lifetime_expired():
	queue_free()

# Funções de comportamento com o Rat King
func find_rat_king():
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.has_method("get_player_info"):  # Verificar se é o Rat King
			rat_king = player
			break

func setup_formation_position():
	# Definir posição aleatória na formação circular
	formation_angle = randf() * TAU  # Ângulo aleatório
	formation_distance = randf_range(30.0, 60.0)  # Distância aleatória

func follow_rat_king(delta):
	if not rat_king:
		velocity = Vector2.ZERO
		return
	
	# Mover em direção ao Rat King
	var direction = (rat_king.global_position - global_position).normalized()
	velocity = direction * speed * 1.2  # Mais rápido para alcançar
	global_position += velocity * delta

func organize_around_king(delta):
	if not rat_king:
		velocity = Vector2.ZERO
		return
	
	# Calcular posição desejada na formação
	var desired_position = rat_king.global_position + Vector2(
		cos(formation_angle) * formation_distance,
		sin(formation_angle) * formation_distance
	)
	
	# Mover suavemente para a posição desejada
	var direction = (desired_position - global_position)
	var distance = direction.length()
	
	if distance > 5.0:  # Se não está na posição
		direction = direction.normalized()
		velocity = direction * speed * 0.8  # Movimento mais suave
		global_position += velocity * delta
	else:
		# Patrulhar lentamente ao redor da posição
		formation_angle += delta * 0.5  # Rotação lenta
		velocity = Vector2.ZERO

func update_formation_position():
	# Atualizar posição na formação para evitar sobreposição
	var minions = get_tree().get_nodes_in_group("minions")
	var nearby_minions = 0
	
	for minion in minions:
		if minion != self and is_instance_valid(minion):
			var distance = global_position.distance_to(minion.global_position)
			if distance < 25.0:  # Muito próximo
				nearby_minions += 1
	
	# Ajustar distância se há muitos minions próximos
	if nearby_minions > 2:
		formation_distance = min(formation_distance + 10.0, 80.0)
	elif nearby_minions == 0:
		formation_distance = max(formation_distance - 5.0, 30.0)

# Função para aplicar upgrades externos
func apply_upgrade(upgrade_data: Dictionary):
	if upgrade_data.has("speed_multiplier"):
		speed *= upgrade_data.speed_multiplier
	
	if upgrade_data.has("damage_multiplier"):
		damage *= upgrade_data.damage_multiplier
	
	if upgrade_data.has("is_poisonous"):
		is_poisonous = upgrade_data.is_poisonous
	
	if upgrade_data.has("is_kamikaze"):
		is_kamikaze = upgrade_data.is_kamikaze
	
	if upgrade_data.has("lifetime_multiplier"):
		lifetime *= upgrade_data.lifetime_multiplier
		lifetime_timer.wait_time = lifetime
