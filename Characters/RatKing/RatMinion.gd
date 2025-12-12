extends Area2D
class_name RatMinion

# Estados do minion
enum State {
	IDLE,
	CHASE,
	ATTACK
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
var current_state: State = State.IDLE
var target_enemy: Node2D = null
var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 30.0  # Tempo de vida do minion
var attack_cooldown: float = 0.0

# Referências de nós
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready():
	# Configurar grupos e sinais
	add_to_group("minions")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
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
	
	# Reduzir cooldown de ataque
	if attack_cooldown > 0:
		attack_cooldown -= delta

func update_state():
	match current_state:
		State.IDLE:
			target_enemy = find_nearest_enemy()
			if target_enemy:
				current_state = State.CHASE
		
		State.CHASE:
			if not is_instance_valid(target_enemy):
				current_state = State.IDLE
				return
			
			var distance = global_position.distance_to(target_enemy.global_position)
			if distance <= attack_range:
				current_state = State.ATTACK
			elif distance > detection_range:
				current_state = State.IDLE
		
		State.ATTACK:
			if not is_instance_valid(target_enemy):
				current_state = State.IDLE
				return
			
			var distance = global_position.distance_to(target_enemy.global_position)
			if distance > attack_range:
				current_state = State.CHASE

func execute_state(delta):
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
		
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