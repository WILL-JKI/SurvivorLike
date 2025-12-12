extends CharacterBody2D
class_name RatKing

# Sinais
signal level_up(new_level: int)
signal evolution_available(evolution_type: String)

# Variáveis de status base
@export_group("Base Stats")
@export var max_health: float = 100.0
@export var movement_speed: float = 120.0
@export var experience_to_next_level: int = 100

# Variáveis de invocação
@export_group("Summoning")
@export var spawn_rate: float = 2.0  # Segundos entre spawns
@export var max_minions: int = 10
@export var minion_speed: float = 100.0
@export var minion_damage: float = 10.0
@export var minion_lifetime: float = 30.0

# Variáveis de efeitos especiais
@export_group("Special Effects")
@export var minions_apply_poison: bool = false
@export var poison_chance: float = 0.0
@export var kamikaze_chance: float = 0.0
@export var spawn_burst_count: int = 1  # Quantos ratos spawnar por vez

# Variáveis internas
var current_health: float
var current_experience: int = 0
var current_level: int = 1
var active_minions: Array[RatMinion] = []
var evolution_route: String = ""  # "swarm", "beast", ou ""

# Referências de nós
@onready var spawn_timer: Timer = $SpawnTimer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Preload do minion
const MINION_SCENE = preload("res://Characters/RatKing/RatMinion.tscn")

func _ready():
	# Inicializar variáveis
	current_health = max_health
	
	# Configurar grupos
	add_to_group("players")
	
	# Configurar timer de spawn
	spawn_timer.wait_time = spawn_rate
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
	# Configurar collision
	collision_layer = 1  # Layer do player
	collision_mask = 0   # Player não colide com nada por padrão

func _physics_process(delta):
	handle_movement(delta)
	clean_dead_minions()

func handle_movement(delta):
	# Input de movimento (WASD ou setas)
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	
	# Normalizar e aplicar velocidade
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * movement_speed
	else:
		velocity = Vector2.ZERO
	
	# Mover o personagem
	move_and_slide()

func _on_spawn_timer_timeout():
	# Spawnar múltiplos minions se necessário
	for i in spawn_burst_count:
		if active_minions.size() < max_minions:
			spawn_minion()
		else:
			break

func spawn_minion():
	if not MINION_SCENE:
		print("Erro: Cena do minion não encontrada!")
		return
	
	# Instanciar o minion
	var minion = MINION_SCENE.instantiate() as RatMinion
	if not minion:
		print("Erro: Falha ao instanciar minion!")
		return
	
	# Configurar posição de spawn (ao redor do player)
	var spawn_offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
	minion.global_position = global_position + spawn_offset
	
	# Aplicar stats do player ao minion
	configure_minion(minion)
	
	# Adicionar à cena e lista
	get_parent().add_child(minion)
	active_minions.append(minion)

func configure_minion(minion: RatMinion):
	# Aplicar stats base
	minion.speed = minion_speed
	minion.damage = minion_damage
	minion.lifetime = minion_lifetime
	
	# Aplicar efeitos especiais baseados em chance
	if minions_apply_poison and randf() < poison_chance:
		minion.is_poisonous = true
	
	if randf() < kamikaze_chance:
		minion.is_kamikaze = true
		minion.damage *= 1.5  # Kamikaze faz mais dano

func clean_dead_minions():
	# Remover minions mortos da lista
	active_minions = active_minions.filter(func(minion): return is_instance_valid(minion))

func gain_experience(amount: int):
	current_experience += amount
	
	# Verificar level up
	while current_experience >= experience_to_next_level:
		current_experience -= experience_to_next_level
		level_up()

func level_up():
	current_level += 1
	level_up.emit(current_level)
	
	# Verificar evoluções especiais
	if current_level == 10:
		evolution_available.emit("route_selection")
	elif current_level == 25:
		evolution_available.emit("ultimate")
	
	# Aumentar dificuldade para próximo level
	experience_to_next_level = int(experience_to_next_level * 1.2)

func apply_upgrade(upgrade_id: String):
	match upgrade_id:
		# Upgrades de quantidade
		"stats_amount":
			max_minions += 5
			print("Max minions aumentado para: ", max_minions)
		
		"stats_amount_large":
			max_minions += 10
			print("Max minions aumentado significativamente para: ", max_minions)
		
		# Upgrades de velocidade
		"stats_speed":
			minion_speed *= 1.2
			spawn_rate *= 0.9  # Spawn mais rápido
			spawn_timer.wait_time = spawn_rate
			print("Velocidade dos minions aumentada")
		
		# Upgrades de dano
		"stats_damage":
			minion_damage *= 1.3
			print("Dano dos minions aumentado")
		
		# Efeitos especiais
		"effect_poison":
			minions_apply_poison = true
			poison_chance = 0.3
			print("Minions agora podem aplicar veneno!")
		
		"effect_poison_upgrade":
			if minions_apply_poison:
				poison_chance = min(poison_chance + 0.2, 1.0)
				print("Chance de veneno aumentada para: ", poison_chance * 100, "%")
		
		"effect_kamikaze":
			kamikaze_chance = 0.15
			print("Alguns minions agora são kamikaze!")
		
		"effect_kamikaze_upgrade":
			kamikaze_chance = min(kamikaze_chance + 0.1, 0.5)
			print("Chance de kamikaze aumentada para: ", kamikaze_chance * 100, "%")
		
		# Upgrades de spawn
		"stats_burst":
			spawn_burst_count += 1
			print("Agora spawna ", spawn_burst_count, " ratos por vez")
		
		"stats_spawn_rate":
			spawn_rate *= 0.8
			spawn_timer.wait_time = spawn_rate
			print("Taxa de spawn aumentada")
		
		# Evoluções de nível 10
		"evo_swarm":
			evolution_route = "swarm"
			max_minions *= 2
			minion_damage *= 0.7  # Menos dano individual
			spawn_rate *= 0.5     # Spawn muito mais rápido
			spawn_timer.wait_time = spawn_rate
			print("EVOLUÇÃO: Rota do Enxame ativada!")
		
		"evo_beast":
			evolution_route = "beast"
			max_minions = int(max_minions * 0.6)  # Menos quantidade
			minion_damage *= 2.0   # Muito mais dano
			minion_speed *= 1.5    # Mais rápidos
			minion_lifetime *= 2.0 # Vivem mais
			print("EVOLUÇÃO: Rota das Bestas ativada!")
		
		# Ultimates de nível 25
		"ultimate_plague_lord":
			if evolution_route == "swarm":
				minions_apply_poison = true
				poison_chance = 1.0  # 100% de chance
				spawn_burst_count *= 2
				print("ULTIMATE: Senhor da Praga ativado!")
		
		"ultimate_rat_emperor":
			if evolution_route == "beast":
				minion_damage *= 2.0
				kamikaze_chance = 0.3
				# Spawnar um "Rat Champion" especial periodicamente
				print("ULTIMATE: Imperador dos Ratos ativado!")
		
		_:
			print("Upgrade desconhecido: ", upgrade_id)

func take_damage(amount: float):
	current_health -= amount
	
	if current_health <= 0:
		die()

func die():
	print("Rat King morreu!")
	# TODO: Implementar lógica de morte/game over

# Função para obter informações do player para UI
func get_player_info() -> Dictionary:
	return {
		"level": current_level,
		"health": current_health,
		"max_health": max_health,
		"experience": current_experience,
		"exp_to_next": experience_to_next_level,
		"active_minions": active_minions.size(),
		"max_minions": max_minions,
		"evolution_route": evolution_route
	}