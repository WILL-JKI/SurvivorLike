extends CharacterBody2D
class_name IceLordPlayer

# Sinais
signal level_changed(new_level: int)
signal evolution_available(evolution_type: String)
signal enemy_frozen(enemy: Node2D)

# Variáveis de status base
@export_group("Base Stats")
@export var max_health: float = 80.0   # Mais frágil que outros
@export var movement_speed: float = 110.0  # Velocidade média
@export var experience_to_next_level: int = 100

# Variáveis de combate
@export_group("Combat Stats")
@export var base_damage: float = 15.0
@export var attack_cooldown: float = 1.0  # Cooldown entre projéteis
@export var projectile_speed: float = 200.0
@export var frost_stacks_per_hit: int = 1
@export var detection_range: float = 300.0  # Range para detectar inimigos

# Variáveis de evolução
@export_group("Evolution Stats")
@export var shatter_damage_bonus: float = 0.0  # Bônus de dano contra frozen
@export var piercing_amount: int = 0
@export var blizzard_active: bool = false
@export var lance_mode: bool = false

# Variáveis internas
var current_health: float
var current_experience: int = 0
var current_level: int = 1
var evolution_route: String = ""  # "blizzard", "lance", ou ""
var can_attack: bool = true

# Variáveis de knockback
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 800.0

# Referências dos nós
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer
@onready var camera: Camera2D = $Camera2D
@onready var blizzard_area: Area2D = $BlizzardArea  # Para evolução blizzard

# Cena do projétil
var ice_projectile_scene: PackedScene

func _ready():
	# Carregar cena do projétil
	ice_projectile_scene = load("res://Characters/IceLord/IceProjectile.tscn")
	
	# Configurar player
	add_to_group("players")
	current_health = max_health
	
	# Configurar colisão
	collision_layer = 1  # Layer do player
	collision_mask = 2   # Colide com paredes
	
	# Configurar timer de ataque
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	
	# Configurar câmera
	camera.make_current()
	camera.zoom = Vector2(1.5, 1.5)
	
	# Configurar blizzard area (inicialmente desabilitada)
	setup_blizzard_area()
	
	print("IceLordPlayer: Ice Lord inicializado")

func setup_blizzard_area():
	if not blizzard_area:
		return
	
	blizzard_area.collision_layer = 0
	blizzard_area.collision_mask = 2  # Detecta inimigos
	blizzard_area.monitoring = false  # Desabilitado por padrão
	
	# Conectar sinais para blizzard
	blizzard_area.body_entered.connect(_on_blizzard_body_entered)
	blizzard_area.body_exited.connect(_on_blizzard_body_exited)

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
		velocity = input_vector * movement_speed
	else:
		velocity = Vector2.ZERO

func handle_knockback(delta):
	# Aplicar knockback se houver
	if knockback_velocity != Vector2.ZERO:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)

func handle_combat(delta):
	# Ataque automático quando há inimigos próximos
	if can_attack and not blizzard_active:
		var nearest_enemy = get_nearest_enemy()
		if nearest_enemy:
			attack_enemy(nearest_enemy)

func get_nearest_enemy() -> Node2D:
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

func attack_enemy(target: Node2D):
	if not can_attack or not ice_projectile_scene:
		return
	
	# Criar projétil
	var projectile = ice_projectile_scene.instantiate() as IceProjectile
	if not projectile:
		print("IceLordPlayer: Erro ao criar projétil!")
		return
	
	# Configurar projétil
	var direction = (target.global_position - global_position).normalized()
	projectile.setup_projectile(global_position, direction, projectile_speed)
	
	# Aplicar upgrades ao projétil
	apply_projectile_upgrades(projectile)
	
	# Conectar sinais
	projectile.enemy_hit.connect(_on_projectile_enemy_hit)
	
	# Adicionar à cena
	get_parent().add_child(projectile)
	
	# Iniciar cooldown
	can_attack = false
	attack_timer.start()
	
	print("IceLordPlayer: Projétil de gelo disparado contra %s" % target.name)

func apply_projectile_upgrades(projectile: IceProjectile):
	# Aplicar upgrades acumulados ao projétil
	projectile.frost_stacks = frost_stacks_per_hit
	projectile.damage = base_damage + (shatter_damage_bonus if is_target_frozen(null) else 0.0)
	projectile.piercing = piercing_amount
	
	# Modo lance (evolução)
	if lance_mode:
		projectile.set_infinite_piercing()
		projectile.upgrade_speed(1.5)

func is_target_frozen(target: Node2D) -> bool:
	# Verificar se o alvo está congelado (para bônus de shatter)
	if not target or not target.has_method("get"):
		return false
	
	return target.get("is_frozen") if target.has_method("get") else false

func _on_attack_timer_timeout():
	can_attack = true

func _on_projectile_enemy_hit(enemy: Node2D, frost_stacks: int):
	# Projétil atingiu um inimigo
	print("IceLordPlayer: Inimigo %s atingido com %d frost stacks" % [enemy.name, frost_stacks])
	
	# Verificar se o inimigo foi congelado
	if enemy.has_method("get") and enemy.get("is_frozen"):
		enemy_frozen.emit(enemy)

# Sistema de Blizzard (Evolução)
func _on_blizzard_body_entered(body: Node2D):
	if blizzard_active and body.is_in_group("enemies"):
		# Aplicar frost continuamente
		start_blizzard_effect_on_enemy(body)

func _on_blizzard_body_exited(body: Node2D):
	if blizzard_active and body.is_in_group("enemies"):
		stop_blizzard_effect_on_enemy(body)

func start_blizzard_effect_on_enemy(enemy: Node2D):
	# Aplicar frost a cada 0.5s enquanto estiver na área
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.timeout.connect(func(): apply_blizzard_frost(enemy, timer))
	add_child(timer)
	timer.start()
	
	# Marcar timer no inimigo para cleanup
	enemy.set_meta("blizzard_timer", timer)

func stop_blizzard_effect_on_enemy(enemy: Node2D):
	# Parar efeito de blizzard no inimigo
	if enemy.has_meta("blizzard_timer"):
		var timer = enemy.get_meta("blizzard_timer")
		if is_instance_valid(timer):
			timer.queue_free()
		enemy.remove_meta("blizzard_timer")

func apply_blizzard_frost(enemy: Node2D, timer: Timer):
	if not is_instance_valid(enemy) or not blizzard_active:
		timer.queue_free()
		return
	
	# Verificar se ainda está na área
	var bodies = blizzard_area.get_overlapping_bodies()
	if enemy in bodies and enemy.has_method("apply_frost"):
		enemy.apply_frost(1)  # 1 stack a cada 0.5s

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
	
	print("IceLordPlayer: Dano recebido: %.1f (Vida: %.1f/%.1f)" % [amount, current_health, max_health])

func heal(amount: float):
	current_health = min(max_health, current_health + amount)
	print("IceLordPlayer: Curado: %.1f (Vida: %.1f/%.1f)" % [amount, current_health, max_health])

func create_damage_effect():
	# Efeito visual de dano recebido
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.CYAN, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func die():
	print("IceLordPlayer: Ice Lord morreu!")
	# Implementar lógica de morte

# Funções de experiência e level
func gain_experience(amount: int):
	current_experience += amount
	
	while current_experience >= experience_to_next_level:
		level_up()

func level_up():
	current_experience -= experience_to_next_level
	current_level += 1
	experience_to_next_level = int(experience_to_next_level * 1.2)
	
	level_changed.emit(current_level)
	
	# Verificar evoluções especiais
	if current_level == 10:
		evolution_available.emit("evolution_choice")
	elif current_level == 25:
		evolution_available.emit("ultimate")
	
	print("IceLordPlayer: Level Up! Novo level: %d" % current_level)

# Sistema de upgrades
func apply_upgrade(upgrade_id: String, value: float = 0.0):
	match upgrade_id:
		"stats_damage":
			base_damage += value if value > 0 else 5.0
			print("IceLordPlayer: Dano aumentado para: %.1f" % base_damage)
		
		"stats_speed":
			projectile_speed += value if value > 0 else 30.0
			print("IceLordPlayer: Velocidade do projétil: %.1f" % projectile_speed)
		
		"stats_cooldown":
			attack_cooldown *= 0.9  # Reduz 10%
			attack_timer.wait_time = attack_cooldown
			print("IceLordPlayer: Cooldown reduzido para: %.2f" % attack_cooldown)
		
		"stats_pierce":
			piercing_amount += 1
			print("IceLordPlayer: Piercing aumentado para: %d" % piercing_amount)
		
		"stats_frost":
			frost_stacks_per_hit += 1
			print("IceLordPlayer: Frost stacks por hit: %d" % frost_stacks_per_hit)
		
		"passive_shatter":
			shatter_damage_bonus += 10.0
			print("IceLordPlayer: Bônus de shatter: %.1f" % shatter_damage_bonus)
		
		"stats_health":
			var heal_amount = value if value > 0 else 15.0
			max_health += heal_amount
			heal(heal_amount)
		
		"stats_movement":
			movement_speed += value if value > 0 else 15.0
			print("IceLordPlayer: Velocidade de movimento: %.1f" % movement_speed)
		
		"evo_blizzard":
			apply_evolution_blizzard()
		
		"evo_lance":
			apply_evolution_lance()
		
		_:
			print("IceLordPlayer: Upgrade desconhecido: ", upgrade_id)

func apply_evolution_blizzard():
	evolution_route = "blizzard"
	blizzard_active = true
	
	# Ativar área de blizzard
	if blizzard_area:
		blizzard_area.monitoring = true
	
	# Mudanças no player
	attack_cooldown *= 2.0  # Ataques mais lentos
	attack_timer.wait_time = attack_cooldown
	
	# Efeito visual
	sprite.modulate = Color.LIGHT_BLUE
	
	print("IceLordPlayer: Evolução BLIZZARD aplicada!")

func apply_evolution_lance():
	evolution_route = "lance"
	lance_mode = true
	
	# Mudanças no projétil (aplicadas em apply_projectile_upgrades)
	projectile_speed *= 1.5
	attack_cooldown *= 1.3  # Ataques mais lentos
	attack_timer.wait_time = attack_cooldown
	
	# Efeito visual
	sprite.modulate = Color.CYAN
	
	print("IceLordPlayer: Evolução LANCE aplicada!")

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
		"player_type": "Ice Lord",
		"base_damage": base_damage,
		"frost_stacks": frost_stacks_per_hit,
		"piercing": piercing_amount,
		"shatter_bonus": shatter_damage_bonus
	}
