extends CharacterBody2D
class_name SimpleEnemy

# Variáveis do inimigo
@export var max_health: float = 50.0
@export var movement_speed: float = 80.0
@export var damage: float = 15.0
@export var detection_range: float = 100.0
@export var attack_range: float = 25.0

# Variáveis internas
var current_health: float
var target_player: Node2D = null
var is_poisoned: bool = false
var poison_damage: float = 0.0
var poison_timer: float = 0.0

# Variáveis de knockback
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 600.0

# Referências de nós
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	# Inicializar variáveis
	current_health = max_health
	
	# Configurar grupos
	add_to_group("enemies")
	
	# Configurar collision
	collision_layer = 2  # Layer dos inimigos
	collision_mask = 1   # Mask do player

func _physics_process(delta):
	handle_poison(delta)
	handle_knockback(delta)
	find_target()
	move_towards_target(delta)

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
	current_health -= amount
	
	# Aplicar knockback
	if knockback_force != Vector2.ZERO:
		apply_knockback(knockback_force)
	
	# Efeito visual de dano (piscar vermelho)
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	# Mostrar número de dano
	show_damage_number(amount, "normal")
	
	print("Inimigo recebeu ", amount, " de dano. Vida: ", current_health)
	
	if current_health <= 0:
		die()

func apply_poison(damage: float, duration: float):
	is_poisoned = true
	poison_damage = damage
	poison_timer = duration
	print("Inimigo foi envenenado!")

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
