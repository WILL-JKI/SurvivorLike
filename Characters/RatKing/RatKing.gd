extends CharacterBody2D
class_name RatKing

# Sinais
signal level_changed(new_level: int)
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

# Variáveis de movimento para os minions
var is_moving: bool = false
var last_position: Vector2 = Vector2.ZERO
var movement_check_timer: float = 0.0

# Variáveis de câmera
var current_boss: Node2D = null

# Variáveis de knockback
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 800.0
var camera_base_zoom: Vector2 = Vector2(1.5, 1.5)  # Zoom para estética 16x16
var camera_boss_zoom: Vector2 = Vector2(1, 1)  # Zoom menor para bosses
var camera_smooth_speed: float = 3.0
var boss_camera_offset_strength: float = 0.25  # 25% em direção ao boss
var boss_detection_range: float = 400.0  # Distância para detectar boss

# Referências de nós
@onready var spawn_timer: Timer = $SpawnTimer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var camera: Camera2D = $Camera2D

# Cena do minion
var minion_scene: PackedScene

func _ready():
	# Carregar cena do minion
	minion_scene = load("res://Characters/RatKing/RatMinion.tscn")
	
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
	
	# Configurar câmera
	setup_camera()

func _physics_process(delta):
	handle_movement(delta)
	handle_knockback(delta)
	update_movement_state(delta)
	update_camera(delta)
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
	
	# Normalizar e aplicar velocidade (sem sobrescrever knockback)
	var movement_velocity = Vector2.ZERO
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		movement_velocity = input_vector * movement_speed
	
	# Combinar movimento normal com knockback
	if knockback_velocity.length() < 10.0:  # Se knockback é pequeno, permitir movimento
		velocity = movement_velocity
	# Se há knockback significativo, o movimento é limitado
	
	# Mover o personagem
	move_and_slide()

func update_movement_state(delta):
	# Verificar se o player está se movendo
	movement_check_timer += delta
	
	if movement_check_timer >= 0.1:  # Verificar a cada 0.1 segundos
		var current_position = global_position
		var distance_moved = current_position.distance_to(last_position)
		
		is_moving = distance_moved > 1.0  # Threshold de movimento
		last_position = current_position
		movement_check_timer = 0.0

# Função para os minions verificarem se o King está se movendo
func get_is_moving() -> bool:
	return is_moving

func _on_spawn_timer_timeout():
	# Spawnar múltiplos minions usando SummonManager
	for i in spawn_burst_count:
		if SummonManager.active_minions.size() < max_minions:
			spawn_minion()
		else:
			break

func spawn_minion():
	# Configurar posição de spawn (ao redor do player)
	var spawn_offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
	var spawn_position = global_position + spawn_offset
	
	# Usar SummonManager para spawnar
	var minion = SummonManager.spawn_minion(spawn_position, self)
	if minion:
		# Aplicar stats do player ao minion
		configure_minion(minion)
		active_minions.append(minion)  # Manter lista local para compatibilidade

func configure_minion(minion: RatMinion):
	# Definir referências
	minion.rat_king = self
	minion.summoner = self  # Para SummonManager
	
	# Aplicar stats base
	minion.speed = minion_speed
	minion.damage = minion_damage
	minion.lifetime = minion_lifetime
	
	# Configurar formação única para cada minion
	minion.setup_formation_position()
	
	# Aplicar efeitos especiais baseados em chance
	if minions_apply_poison and randf() < poison_chance:
		minion.is_poisonous = true
	
	if randf() < kamikaze_chance:
		minion.is_kamikaze = true
		minion.damage *= 1.5  # Kamikaze faz mais dano

func clean_dead_minions():
	# Remover minions mortos da lista local (SummonManager gerencia a lista principal)
	active_minions = active_minions.filter(func(minion): return is_instance_valid(minion))

func gain_experience(amount: int):
	current_experience += amount
	
	# Verificar level up
	while current_experience >= experience_to_next_level:
		current_experience -= experience_to_next_level
		level_up()

func level_up():
	current_level += 1
	level_changed.emit(current_level)
	
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

func take_damage(amount: float, knockback_force: Vector2 = Vector2.ZERO):
	current_health -= amount
	
	# Aplicar knockback
	if knockback_force != Vector2.ZERO:
		apply_knockback(knockback_force)
	
	# Efeito visual de dano no player
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Mostrar número de dano (vermelho para player)
	show_damage_number(amount, "player_damage")
	
	print("Rat King recebeu ", amount, " de dano! Vida: ", current_health, "/", max_health)
	
	if current_health <= 0:
		die()

func apply_knockback(force: Vector2):
	knockback_velocity = force

func handle_knockback(delta):
	if knockback_velocity.length() > 0:
		# Aplicar knockback à velocidade
		velocity += knockback_velocity
		
		# Reduzir knockback gradualmente
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)

func show_damage_number(damage: float, damage_type: String = "player_damage"):
	# Carregar e instanciar número de dano
	var damage_number_scene = load("res://_Core/DamageNumber.tscn")
	var damage_number = damage_number_scene.instantiate()
	
	# Posicionar acima do player
	damage_number.global_position = global_position + Vector2(randf_range(-20, 20), -30)
	
	# Configurar dano
	damage_number.setup_damage(damage, damage_type)
	
	# Adicionar à cena
	get_parent().add_child(damage_number)

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
		"active_minions": SummonManager.active_minions.size(),
		"max_minions": max_minions,
		"evolution_route": evolution_route,
		"summon_stats": SummonManager.get_stats()
	}

# Sistema de Câmera
func setup_camera():
	if not camera:
		return
	
	# Configurar zoom base para estética pixel art
	camera.zoom = camera_base_zoom
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = camera_smooth_speed
	
	# Configurar para pixel perfect (Godot 4 não tem snap_to_pixel)
	# O pixel perfect é controlado pelas configurações do projeto
	
	print("Câmera configurada - Zoom: ", camera_base_zoom)

func update_camera(delta):
	if not camera:
		return
	
	# Detectar boss próximo
	var nearest_boss = find_nearest_boss()
	
	if nearest_boss != current_boss:
		current_boss = nearest_boss
		print("Boss detectado: ", current_boss != null)
	
	# Atualizar posição e zoom da câmera
	if current_boss:
		update_camera_with_boss(delta)
	else:
		update_camera_normal(delta)

func find_nearest_boss() -> Node2D:
	var bosses = get_tree().get_nodes_in_group("boss")
	var nearest_boss: Node2D = null
	var nearest_distance: float = boss_detection_range
	
	for boss in bosses:
		if not is_instance_valid(boss):
			continue
		
		var distance = global_position.distance_to(boss.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_boss = boss
	
	return nearest_boss

func update_camera_with_boss(delta):
	if not current_boss:
		return
	
	# Calcular posição entre player e boss (mais próximo do player)
	var player_pos = global_position
	var boss_pos = current_boss.global_position
	
	# Offset em direção ao boss, mas mantendo foco no player
	var direction_to_boss = (boss_pos - player_pos).normalized()
	var offset_distance = player_pos.distance_to(boss_pos) * boss_camera_offset_strength
	var target_position = player_pos + (direction_to_boss * offset_distance)
	
	# Suavizar transição da câmera
	camera.global_position = camera.global_position.lerp(target_position, camera_smooth_speed * delta)
	
	# Ajustar zoom para mostrar mais área
	var target_zoom = camera_boss_zoom
	camera.zoom = camera.zoom.lerp(target_zoom, camera_smooth_speed * delta)
	
	# Verificar se boss saiu da tela (aproximadamente)
	var screen_size = get_viewport().get_visible_rect().size / camera.zoom
	var camera_to_boss = boss_pos - camera.global_position
	
	if abs(camera_to_boss.x) > screen_size.x * 0.6 or abs(camera_to_boss.y) > screen_size.y * 0.6:
		# Boss muito longe, voltar para câmera normal
		current_boss = null

func update_camera_normal(delta):
	# Câmera centralizada no player
	var target_position = global_position
	camera.global_position = camera.global_position.lerp(target_position, camera_smooth_speed * delta)
	
	# Zoom normal
	var target_zoom = camera_base_zoom
	camera.zoom = camera.zoom.lerp(target_zoom, camera_smooth_speed * delta)
