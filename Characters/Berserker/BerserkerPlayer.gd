extends CharacterBody2D
class_name BerserkerPlayer

# Sinais
signal level_changed(new_level: int)
signal evolution_available(evolution_type: String)
signal enemy_killed(enemy: Node2D)

# Variáveis de status base
@export_group("Base Stats")
@export var max_health: float = 120.0  # Mais tanque que RatKing
@export var movement_speed: float = 100.0  # Mais lento, mas mais resistente
@export var experience_to_next_level: int = 100

# Variáveis de combate
@export_group("Combat Stats")
@export var base_damage: float = 25.0
@export var base_cooldown: float = 1.5  # Cooldown base da arma
@export var fury_multiplier: float = 0.1  # 10% de redução por inimigo próximo

# Variáveis de evolução
@export_group("Evolution")
@export var vampirism_chance: float = 0.0  # Chance de curar ao matar
@export var vampirism_heal: float = 5.0    # Quantidade de cura

# Variáveis internas
var current_health: float
var current_experience: int = 0
var current_level: int = 1
var evolution_route: String = ""  # "giant", "duelist", ou ""
var enemies_in_fury_range: int = 0
var current_attack_cooldown: float = 0.0
var last_movement_direction: Vector2 = Vector2.RIGHT  # Direção do último movimento

# Stats modificados por itens globais
var effective_max_health: float
var effective_movement_speed: float
var effective_base_cooldown: float
var effective_xp_multiplier: float = 1.0

# Variáveis de knockback
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 800.0

# Referências dos nós
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var weapon: BerserkerWeapon = $BerserkerWeapon
@onready var fury_detector: Area2D = $FuryDetector
@onready var attack_timer: Timer = $AttackTimer
@onready var camera: Camera2D = $Camera2D

func _ready():
	# Configurar player
	add_to_group("players")
	
	# Inicializar stats com valores base
	update_stats_from_global()
	current_health = effective_max_health
	
	# Conectar ao sinal de mudança de stats do GameManager
	if GameManager:
		GameManager.stat_changed.connect(_on_global_stat_changed)
	
	# Configurar colisão
	collision_layer = 1  # Layer do player
	collision_mask = 2   # Colide com paredes
	
	# Conectar sinais da arma
	weapon.enemy_hit.connect(_on_weapon_enemy_hit)
	weapon.attack_completed.connect(_on_weapon_attack_completed)
	
	# Configurar detector de fúria
	setup_fury_detector()
	
	# Configurar timer de ataque
	attack_timer.wait_time = effective_base_cooldown
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	
	# Configurar câmera
	camera.make_current()
	camera.zoom = Vector2(1.5, 1.5)
	
	print("BerserkerPlayer: Berserker inicializado")

func setup_fury_detector():
	# Configurar área de detecção de fúria
	fury_detector.collision_layer = 0
	fury_detector.collision_mask = 2  # Detecta inimigos (layer 2)
	
	# Conectar sinais
	fury_detector.area_entered.connect(_on_fury_area_entered)
	fury_detector.area_exited.connect(_on_fury_area_exited)
	fury_detector.body_entered.connect(_on_fury_body_entered)
	fury_detector.body_exited.connect(_on_fury_body_exited)
	
	print("BerserkerPlayer: FuryDetector configurado - Layer: 0, Mask: 2")
	fury_detector.body_entered.connect(_on_fury_body_entered)
	fury_detector.body_exited.connect(_on_fury_body_exited)

func _physics_process(delta):
	handle_movement(delta)
	handle_knockback(delta)
	handle_combat(delta)
	move_and_slide()

func handle_movement(delta):
	# Input de movimento
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
		velocity = input_vector * effective_movement_speed
		# Atualizar direção do último movimento para ataques
		last_movement_direction = input_vector
	else:
		velocity = Vector2.ZERO

func handle_knockback(delta):
	# Aplicar knockback se houver
	if knockback_velocity != Vector2.ZERO:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)

func handle_combat(delta):
	# Teste manual de ataque (pressione SPACE)
	if Input.is_action_just_pressed("ui_accept"):  # SPACE
		print("BerserkerPlayer: Ataque manual ativado!")
		attack()
	
	# Ataque automático quando há inimigos próximos
	if enemies_in_fury_range > 0 and attack_timer.is_stopped():
		print("BerserkerPlayer: Condições para ataque atendidas!")
		attack()
	
	# Debug: mostrar status a cada 2 segundos
	if Engine.get_process_frames() % 120 == 0:  # A cada 2 segundos (60 FPS)
		print("BerserkerPlayer: Debug - Inimigos próximos: %d, Timer parado: %s" % [enemies_in_fury_range, attack_timer.is_stopped()])

func attack():
	# Calcular cooldown com base na fúria
	var fury_reduction = enemies_in_fury_range * fury_multiplier
	var final_cooldown = effective_base_cooldown * (1.0 - min(fury_reduction, 0.8))  # Máximo 80% redução
	
	# Determinar direção do ataque
	var attack_direction = get_attack_direction()
	
	# Iniciar ataque da espada na direção determinada
	weapon.attack(attack_direction)
	
	# Configurar próximo ataque
	attack_timer.wait_time = final_cooldown
	attack_timer.start()
	
	print("BerserkerPlayer: Espada atacando na direção: %s! Cooldown: %.2f" % [attack_direction, final_cooldown])

func get_attack_direction() -> Vector2:
	# Prioridade: direção para o inimigo mais próximo, senão direção do movimento
	var nearest_enemy = find_nearest_enemy_in_fury()
	
	if nearest_enemy:
		# Atacar na direção do inimigo mais próximo
		return (nearest_enemy.global_position - global_position).normalized()
	else:
		# Atacar na direção do último movimento
		return last_movement_direction

func find_nearest_enemy_in_fury() -> Node2D:
	# Encontrar o inimigo mais próximo dentro do range de fúria
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest_enemy: Node2D = null
	var nearest_distance: float = 150.0  # Range de detecção para ataque direcional
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy
	
	return nearest_enemy

func _on_attack_timer_timeout():
	# Timer pronto para próximo ataque
	pass

func _on_weapon_enemy_hit(enemy: Node2D, damage: float):
	# Inimigo foi atingido pela arma
	print("BerserkerPlayer: Inimigo atingido por %.1f de dano" % damage)

func _on_weapon_attack_completed():
	# Ataque da arma foi completado
	pass

# Funções do detector de fúria
func _on_fury_area_entered(area: Area2D):
	print("BerserkerPlayer: Area detectada: ", area.name, " - Grupos: ", area.get_groups())
	if area.is_in_group("enemies"):
		enemies_in_fury_range += 1
		update_fury_visual()
		print("BerserkerPlayer: Inimigo (Area) entrou na fúria!")

func _on_fury_area_exited(area: Area2D):
	if area.is_in_group("enemies"):
		enemies_in_fury_range = max(0, enemies_in_fury_range - 1)
		update_fury_visual()
		print("BerserkerPlayer: Inimigo (Area) saiu da fúria!")

func _on_fury_body_entered(body: Node2D):
	print("BerserkerPlayer: Body detectado: ", body.name, " - Grupos: ", body.get_groups())
	if body.is_in_group("enemies"):
		enemies_in_fury_range += 1
		update_fury_visual()
		print("BerserkerPlayer: Inimigo (Body) entrou na fúria!")

func _on_fury_body_exited(body: Node2D):
	if body.is_in_group("enemies"):
		enemies_in_fury_range = max(0, enemies_in_fury_range - 1)
		update_fury_visual()
		print("BerserkerPlayer: Inimigo (Body) saiu da fúria!")

func update_fury_visual():
	# Efeito visual baseado na fúria
	var fury_intensity = min(enemies_in_fury_range / 5.0, 1.0)  # Máximo com 5 inimigos
	sprite.modulate = Color.WHITE.lerp(Color.RED, fury_intensity * 0.5)
	
	print("BerserkerPlayer: Fúria atualizada - Inimigos próximos: %d" % enemies_in_fury_range)

# Funções de dano e cura
func take_damage(amount: float, knockback_force: Vector2 = Vector2.ZERO):
	current_health -= amount
	current_health = max(0, current_health)
	
	# Aplicar knockback se fornecido
	if knockback_force != Vector2.ZERO:
		apply_knockback(knockback_force)
	
	# Efeito visual de dano
	create_damage_effect()
	
	if current_health <= 0:
		die()
	
	print("BerserkerPlayer: Dano recebido: %.1f (Vida: %.1f/%.1f)" % [amount, current_health, max_health])

func heal(amount: float):
	current_health = min(max_health, current_health + amount)
	print("BerserkerPlayer: Curado: %.1f (Vida: %.1f/%.1f)" % [amount, current_health, max_health])

func create_damage_effect():
	# Efeito visual de dano recebido
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func die():
	print("BerserkerPlayer: Berserker morreu!")
	# Implementar lógica de morte

# Funções de experiência e level
func gain_experience(amount: int):
	# Aplicar multiplicador de XP dos itens globais
	var modified_amount = int(amount * effective_xp_multiplier)
	current_experience += modified_amount
	
	print("BerserkerPlayer: XP ganho: %d (base: %d, multiplicador: %.2fx)" % [modified_amount, amount, effective_xp_multiplier])
	
	while current_experience >= experience_to_next_level:
		level_up()

func level_up():
	current_experience -= experience_to_next_level
	current_level += 1
	experience_to_next_level = int(experience_to_next_level * 1.2)  # Progressão exponencial
	
	level_changed.emit(current_level)
	
	# Verificar evoluções especiais
	if current_level == 10:
		evolution_available.emit("evolution_choice")
	elif current_level == 25:
		evolution_available.emit("ultimate")
	
	print("BerserkerPlayer: Level Up! Novo level: %d" % current_level)

# Sistema de upgrades
func apply_upgrade(upgrade_id: String, value: float = 0.0):
	match upgrade_id:
		"stats_aoe":
			weapon.upgrade_area_size(0.2)
		
		"stats_damage":
			weapon.upgrade_damage(value if value > 0 else 10.0)
		
		"stats_knockback":
			weapon.upgrade_knockback(value if value > 0 else 50.0)
		
		"stats_cooldown":
			base_cooldown *= 0.9  # Reduz 10%
			print("BerserkerPlayer: Cooldown reduzido para: %.2f" % base_cooldown)
		
		"stats_health":
			var heal_amount = value if value > 0 else 20.0
			max_health += heal_amount
			heal(heal_amount)
		
		"stats_speed":
			movement_speed += value if value > 0 else 10.0
			print("BerserkerPlayer: Velocidade aumentada para: %.1f" % movement_speed)
		
		"passive_vampirism":
			vampirism_chance += 0.15  # 15% de chance
			print("BerserkerPlayer: Vampirismo ativado: %.1f%%" % (vampirism_chance * 100))
		
		"evo_giant":
			apply_evolution_giant()
		
		"evo_duelist":
			apply_evolution_duelist()
		
		_:
			print("BerserkerPlayer: Upgrade desconhecido: ", upgrade_id)

func apply_evolution_giant():
	evolution_route = "giant"
	
	# Aplicar mudanças na arma
	weapon.apply_evolution_giant()
	
	# Mudanças no player
	max_health *= 1.5
	heal(max_health * 0.5)  # Curar 50% da vida máxima
	movement_speed *= 0.8   # Reduzir velocidade
	base_cooldown *= 1.2    # Aumentar cooldown
	
	# Efeito visual
	sprite.modulate = Color.ORANGE_RED
	scale *= 1.2
	
	print("BerserkerPlayer: Evolução GIGANTE aplicada!")

func apply_evolution_duelist():
	evolution_route = "duelist"
	
	# Aplicar mudanças na arma
	weapon.apply_evolution_duelist()
	
	# Criar segunda arma (implementar depois)
	# create_second_weapon()
	
	# Mudanças no player
	movement_speed *= 1.3   # Aumentar velocidade
	base_cooldown *= 0.6    # Reduzir muito o cooldown
	
	# Efeito visual
	sprite.modulate = Color.CYAN
	
	print("BerserkerPlayer: Evolução DUELISTA aplicada!")

# Função para vampirismo
func try_vampirism():
	if vampirism_chance > 0 and randf() < vampirism_chance:
		heal(vampirism_heal)
		print("BerserkerPlayer: Vampirismo ativado! Curado: %.1f" % vampirism_heal)

# Função para aplicar knockback no player
func apply_knockback(knockback_force: Vector2):
	knockback_velocity = knockback_force

# Função para obter informações do player (para debug UI)
func get_player_info() -> Dictionary:
	return {
		"level": current_level,
		"health": current_health,
		"max_health": max_health,
		"experience": current_experience,
		"exp_to_next": experience_to_next_level,
		"evolution_route": evolution_route,
		"enemies_in_fury": enemies_in_fury_range,
		"player_type": "Berserker",
		"base_damage": base_damage,
		"vampirism_chance": vampirism_chance
	}
# Sistema de Stats Globais
func update_stats_from_global():
	if not GameManager:
		# Usar valores base se GameManager não estiver disponível
		effective_max_health = max_health
		effective_movement_speed = movement_speed
		effective_base_cooldown = base_cooldown
		effective_xp_multiplier = 1.0
		return
	
	# Aplicar multiplicadores dos itens globais
	effective_max_health = max_health * GameManager.get_stat("max_health_mult")
	effective_movement_speed = movement_speed * GameManager.get_stat("move_speed")
	effective_xp_multiplier = GameManager.get_stat("xp_gain")
	
	# Aplicar redução de cooldown
	var cooldown_reduction = GameManager.get_stat("cooldown_reduction")
	effective_base_cooldown = base_cooldown * (1.0 - cooldown_reduction)
	
	# Atualizar vida atual proporcionalmente se a vida máxima mudou
	if current_health > 0:
		var health_ratio = current_health / max_health
		current_health = effective_max_health * health_ratio
	
	# Aplicar area_size à arma
	if weapon:
		var area_multiplier = GameManager.get_stat("area_size")
		weapon.set_area_size(area_multiplier)
	
	print("BerserkerPlayer: Stats atualizados - Vida: %.1f, Velocidade: %.1f, Cooldown: %.2f, XP: %.2fx" % [effective_max_health, effective_movement_speed, effective_base_cooldown, effective_xp_multiplier])

func _on_global_stat_changed(stat_key: String, new_value: float):
	# Reagir a mudanças específicas de stats
	match stat_key:
		"max_health_mult", "move_speed", "xp_gain", "cooldown_reduction":
			update_stats_from_global()
		"area_size":
			# Aplicar area_size à arma imediatamente
			if weapon:
				weapon.set_area_size(new_value)
		"knockback":
			# Aplicar knockback à arma
			if weapon:
				var knockback_multiplier = GameManager.get_stat("knockback")
				weapon.knockback_force = weapon.knockback_force * knockback_multiplier