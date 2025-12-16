extends CharacterBody2D
class_name SimpleEnemy

# Variáveis do inimigo
@export var max_health: float = 50.0
@export var movement_speed: float = 80.0
@export var damage: float = 15.0
@export var detection_range: float = 100.0
@export var attack_range: float = 25.0
@export var attack_cooldown_time: float = 1.5

# Variáveis internas
var current_health: float
var target_player: Node2D = null
var is_poisoned: bool = false
var poison_damage: float = 0.0
var poison_timer: float = 0.0
var attack_cooldown: float = 0.0

# Sistema de Frost (Ice Lord)
var frost_stacks: int = 0
var is_frozen: bool = false
var base_movement_speed: float  # Para restaurar velocidade após frost
var freeze_timer: float = 0.0
var freeze_duration: float = 3.0

# Variáveis de knockback
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 600.0

# Referências de nós
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	# Inicializar variáveis
	current_health = max_health
	base_movement_speed = movement_speed  # Salvar velocidade original
	
	# Configurar grupos
	add_to_group("enemies")
	
	# Configurar collision
	collision_layer = 2  # Layer dos inimigos
	collision_mask = 1   # Mask do player

func _physics_process(delta):
	handle_poison(delta)
	handle_frost(delta)
	handle_knockback(delta)
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
		# Mover em direção ao player (considerando knockback)
		var movement_velocity = Vector2.ZERO
		if knockback_velocity.length() < 10.0:  # Se knockback é pequeno, permitir movimento
			var direction = (target_player.global_position - global_position).normalized()
			movement_velocity = direction * movement_speed
		
		velocity = movement_velocity
	
	move_and_slide()

func take_damage(amount: float, knockback_force: Vector2 = Vector2.ZERO):
	var final_damage = amount
	var damage_type = "normal"
	
	# Bônus de Shatter se estiver congelado
	if is_frozen:
		final_damage *= 1.5  # 50% de bônus de dano
		damage_type = "shatter"
		
		# Quebrar o gelo (descongelar imediatamente)
		unfreeze_enemy()
		
		# Efeito visual especial de shatter
		create_shatter_effect()
		
		print("SHATTER! Dano aumentado de %.1f para %.1f" % [amount, final_damage])
	
	current_health -= final_damage
	
	# Aplicar knockback
	if knockback_force != Vector2.ZERO:
		apply_knockback(knockback_force)
	
	# Efeito visual de dano
	if damage_type == "shatter":
		modulate = Color.CYAN  # Azul para shatter
	else:
		modulate = Color.RED   # Vermelho normal
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	# Mostrar número de dano
	show_damage_number(final_damage, damage_type)
	
	print("Inimigo recebeu %.1f de dano (%s). Vida: %.1f" % [final_damage, damage_type, current_health])
	
	if current_health <= 0:
		die()

func create_shatter_effect():
	# Efeito visual especial quando um inimigo congelado é quebrado
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Flash azul brilhante
	tween.tween_property(sprite, "modulate", Color.CYAN, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.3).set_delay(0.1)
	
	# Efeito de "explosão" de gelo
	tween.tween_property(sprite, "scale", sprite.scale * 1.3, 0.1)
	tween.tween_property(sprite, "scale", sprite.scale, 0.2).set_delay(0.1)

func apply_poison(damage: float, duration: float):
	is_poisoned = true
	poison_damage = damage
	poison_timer = duration
	print("Inimigo foi envenenado!")

# Sistema de Frost (Ice Lord)
func apply_frost(amount: int):
	frost_stacks += amount
	
	# Reduzir velocidade em 10% por stack
	var speed_reduction = frost_stacks * 0.1
	movement_speed = base_movement_speed * (1.0 - min(speed_reduction, 0.8))  # Máximo 80% redução
	
	# Efeito visual de frost
	var frost_intensity = min(frost_stacks / 3.0, 1.0)
	modulate = Color.WHITE.lerp(Color(0.7, 0.7, 1.0, 1.0), frost_intensity)
	
	print("Inimigo recebeu %d frost stacks (total: %d). Velocidade: %.1f" % [amount, frost_stacks, movement_speed])
	
	# Verificar se deve congelar
	if frost_stacks >= 3 and not is_frozen:
		freeze_enemy()

func freeze_enemy():
	is_frozen = true
	movement_speed = 0.0  # Parar completamente
	freeze_timer = freeze_duration
	
	# Efeito visual de congelamento
	modulate = Color(0.5, 0.5, 1.0, 1.0)  # Azul forte
	
	# Efeito de escala para indicar congelamento
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", sprite.scale * 1.1, 0.2)
	tween.tween_property(sprite, "scale", sprite.scale, 0.2).set_delay(0.2)
	
	print("Inimigo CONGELADO por %.1f segundos!" % freeze_duration)

func handle_frost(delta):
	if is_frozen:
		freeze_timer -= delta
		
		# Descongelar quando o timer acabar
		if freeze_timer <= 0:
			unfreeze_enemy()
	else:
		# Reduzir frost stacks gradualmente (1 stack a cada 2 segundos)
		if frost_stacks > 0:
			var stack_decay_rate = 0.5  # stacks por segundo
			frost_stacks = max(0, frost_stacks - int(stack_decay_rate * delta))
			
			# Atualizar velocidade baseada nos stacks restantes
			if frost_stacks > 0:
				var speed_reduction = frost_stacks * 0.1
				movement_speed = base_movement_speed * (1.0 - min(speed_reduction, 0.8))
				
				# Atualizar visual
				var frost_intensity = min(frost_stacks / 3.0, 1.0)
				modulate = Color.WHITE.lerp(Color(0.7, 0.7, 1.0, 1.0), frost_intensity)
			else:
				# Sem frost stacks, restaurar normal
				movement_speed = base_movement_speed
				modulate = Color.WHITE

func unfreeze_enemy():
	is_frozen = false
	frost_stacks = max(0, frost_stacks - 1)  # Perder 1 stack ao descongelar
	
	# Restaurar velocidade baseada nos stacks restantes
	if frost_stacks > 0:
		var speed_reduction = frost_stacks * 0.1
		movement_speed = base_movement_speed * (1.0 - min(speed_reduction, 0.8))
		
		# Visual de frost reduzido
		var frost_intensity = min(frost_stacks / 3.0, 1.0)
		modulate = Color.WHITE.lerp(Color(0.7, 0.7, 1.0, 1.0), frost_intensity)
	else:
		# Sem frost, restaurar completamente
		movement_speed = base_movement_speed
		modulate = Color.WHITE
	
	print("Inimigo descongelado! Frost stacks restantes: %d" % frost_stacks)

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

func apply_knockback(force: Vector2):
	knockback_velocity = force

func handle_knockback(delta):
	if knockback_velocity.length() > 0:
		# Aplicar knockback à velocidade
		velocity += knockback_velocity
		
		# Reduzir knockback gradualmente
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)

func show_damage_number(damage: float, damage_type: String = "normal"):
	# Carregar e instanciar número de dano
	var damage_number_scene = load("res://_Core/DamageNumber.tscn")
	var damage_number = damage_number_scene.instantiate()
	
	# Posicionar acima do inimigo
	damage_number.global_position = global_position + Vector2(randf_range(-15, 15), -25)
	
	# Configurar dano
	damage_number.setup_damage(damage, damage_type)
	
	# Adicionar à cena
	get_parent().add_child(damage_number)

func die():
	print("Inimigo morreu!")
	
	# Dropar orb de XP
	drop_xp_orb()
	
	queue_free()

func drop_xp_orb():
	# Carregar e instanciar orb de XP
	var xp_orb_scene = load("res://_Core/XPOrb.tscn")
	var xp_orb = xp_orb_scene.instantiate()
	
	# Posicionar na posição do inimigo
	xp_orb.global_position = global_position
	
	# Configurar valor da orb (inimigo normal)
	xp_orb.setup_xp_orb(15, "normal")
	
	# Adicionar à cena
	get_parent().add_child(xp_orb)

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
	
	# Calcular direção do knockback (do inimigo para o player)
	var knockback_direction = (target_player.global_position - global_position).normalized()
	var knockback_force = knockback_direction * 100.0  # Força do knockback no player
	
	# Aplicar dano ao player
	target_player.take_damage(damage, knockback_force)
	
	# Efeito visual de ataque
	modulate = Color.YELLOW
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Definir cooldown
	attack_cooldown = attack_cooldown_time
	
	print("Inimigo atacou o player! Dano: ", damage)
