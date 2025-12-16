extends Area2D
class_name BerserkerWeapon

# Sinais
signal enemy_hit(enemy: Node2D, damage: float)
signal attack_completed()

# Variáveis de configuração
@export_group("Weapon Stats")
@export var base_damage: float = 25.0
@export var knockback_force: float = 300.0
@export var area_size: float = 1.0  # Multiplicador de escala
@export var attack_duration: float = 0.3  # Duração do ataque
@export var attack_range: float = 80.0  # Alcance da espada
@export var attack_width: float = 60.0  # Largura do cone de ataque

# Variáveis internas
var current_damage: float
var is_attacking: bool = false
var hit_enemies: Array[Node2D] = []  # Evitar hit múltiplo no mesmo ataque
var attack_direction: Vector2 = Vector2.RIGHT  # Direção do ataque da espada

# Referências dos nós
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_timer: Timer = $AttackTimer

func _ready():
	# Configurar área
	add_to_group("player_weapons")
	collision_layer = 0  # Não colide com nada
	collision_mask = 2   # Detecta inimigos (layer 2)
	
	# Conectar sinais
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Configurar timer
	attack_timer.wait_time = attack_duration
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_finished)
	
	# Inicializar stats
	current_damage = base_damage
	update_weapon_scale()
	
	# Desativar colisão inicialmente
	set_collision_enabled(false)
	
	print("BerserkerWeapon: Arma inicializada")

func attack(direction: Vector2 = Vector2.RIGHT) -> void:
	if is_attacking:
		return
	
	is_attacking = true
	hit_enemies.clear()
	attack_direction = direction.normalized()
	
	# Posicionar e orientar a espada na direção do ataque
	position_sword_for_attack()
	
	# Ativar colisão
	set_collision_enabled(true)
	
	# Animação de ataque (slash)
	create_sword_animation()
	
	# Timer para desativar
	attack_timer.start()
	
	print("BerserkerWeapon: Espada atacando na direção: ", attack_direction, " - Dano: ", current_damage)

func position_sword_for_attack():
	# Posicionar a espada à frente do player na direção do ataque
	var offset_distance = attack_range * 0.5  # Meio do alcance
	global_position = get_parent().global_position + (attack_direction * offset_distance)
	
	# Orientar a espada na direção do ataque
	rotation = attack_direction.angle()
	
	# Ajustar a collision shape para ser retangular (espada)
	if collision_shape and collision_shape.shape is CircleShape2D:
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = Vector2(attack_range, attack_width) * area_size
		collision_shape.shape = rect_shape

func create_sword_animation():
	# Animação de slash da espada
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Movimento de slash (arco)
	var start_angle = attack_direction.angle() - 0.5  # -30 graus
	var end_angle = attack_direction.angle() + 0.5    # +30 graus
	
	sprite.rotation = start_angle
	tween.tween_property(sprite, "rotation", end_angle, attack_duration)
	
	# Efeito de escala (alongamento da espada)
	var original_scale = sprite.scale
	tween.tween_property(sprite, "scale", Vector2(original_scale.x * 1.5, original_scale.y * 0.8), attack_duration * 0.3)
	tween.tween_property(sprite, "scale", original_scale, attack_duration * 0.7).set_delay(attack_duration * 0.3)
	
	# Efeito de cor (flash metálico)
	tween.tween_property(sprite, "modulate", Color.CYAN, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2).set_delay(0.1)

func _on_area_entered(area: Area2D):
	if not is_attacking:
		return
	
	if area.is_in_group("enemies") and area not in hit_enemies:
		hit_enemy(area)

func _on_body_entered(body: Node2D):
	if not is_attacking:
		return
	
	if body.is_in_group("enemies") and body not in hit_enemies:
		hit_enemy(body)

func hit_enemy(enemy: Node2D):
	# Evitar hit múltiplo
	if enemy in hit_enemies:
		return
	
	# Verificar se o inimigo está na direção do ataque (cone)
	if not is_enemy_in_attack_cone(enemy):
		return
	
	hit_enemies.append(enemy)
	
	# Aplicar dano
	if enemy.has_method("take_damage"):
		# Knockback na direção do ataque da espada
		var knockback_vec = attack_direction * knockback_force
		enemy.take_damage(current_damage, knockback_vec)
	
	# Aplicar knockback
	apply_knockback(enemy)
	
	# Emitir sinal
	enemy_hit.emit(enemy, current_damage)
	
	# Efeito visual no inimigo
	create_hit_effect(enemy)
	
	print("BerserkerWeapon: Inimigo atingido pela espada - Dano: ", current_damage)

func is_enemy_in_attack_cone(enemy: Node2D) -> bool:
	# Verificar se o inimigo está no cone de ataque da espada
	var player_pos = get_parent().global_position
	var enemy_pos = enemy.global_position
	var to_enemy = (enemy_pos - player_pos).normalized()
	
	# Verificar distância
	var distance = player_pos.distance_to(enemy_pos)
	if distance > attack_range * area_size:
		return false
	
	# Verificar ângulo (cone de 60 graus)
	var angle_diff = abs(attack_direction.angle_to(to_enemy))
	var max_angle = deg_to_rad(30)  # 30 graus para cada lado = 60 graus total
	
	return angle_diff <= max_angle

func apply_knockback(enemy: Node2D):
	# Knockback já foi aplicado junto com o dano na função take_damage
	# Esta função é mantida para compatibilidade com inimigos que não usam take_damage com knockback
	if not enemy.has_method("take_damage") and enemy.has_method("apply_knockback"):
		# Calcular direção do knockback
		var player_pos = get_parent().global_position
		var enemy_pos = enemy.global_position
		var knockback_direction = (enemy_pos - player_pos).normalized()
		
		# Aplicar knockback
		var knockback_velocity = knockback_direction * knockback_force
		enemy.apply_knockback(knockback_velocity)

func create_hit_effect(enemy: Node2D):
	# Efeito visual de impacto no inimigo
	if not enemy.has_method("create_hit_effect"):
		return
	
	enemy.create_hit_effect()

func _on_attack_finished():
	# Desativar colisão
	set_collision_enabled(false)
	is_attacking = false
	
	# Emitir sinal de ataque completo
	attack_completed.emit()
	
	print("BerserkerWeapon: Ataque finalizado")

func set_collision_enabled(enabled: bool):
	collision_shape.disabled = not enabled

func update_weapon_scale():
	# Atualizar escala da arma
	scale = Vector2.ONE * area_size
	print("BerserkerWeapon: Escala atualizada para: ", area_size)

func upgrade_damage(amount: float):
	current_damage += amount
	print("BerserkerWeapon: Dano aumentado para: ", current_damage)

func upgrade_knockback(amount: float):
	knockback_force += amount
	print("BerserkerWeapon: Knockback aumentado para: ", knockback_force)

func upgrade_area_size(multiplier: float):
	area_size += multiplier
	update_weapon_scale()

func set_damage(new_damage: float):
	current_damage = new_damage
	base_damage = new_damage

func set_knockback_force(new_force: float):
	knockback_force = new_force

func set_area_size(new_size: float):
	area_size = new_size
	update_weapon_scale()

# Função para evoluções especiais
func apply_evolution_giant():
	# Evolução Gigante: +200% área, +50% dano, -30% velocidade
	area_size *= 3.0
	current_damage *= 1.5
	attack_duration *= 1.3
	update_weapon_scale()
	print("BerserkerWeapon: Evolução Gigante aplicada!")

func apply_evolution_duelist():
	# Evolução Duelista: -50% área, +100% velocidade
	area_size *= 0.5
	attack_duration *= 0.5
	update_weapon_scale()
	print("BerserkerWeapon: Evolução Duelista aplicada!")
