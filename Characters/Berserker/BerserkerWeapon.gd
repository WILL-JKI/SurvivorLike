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

# Variáveis internas
var current_damage: float
var is_attacking: bool = false
var hit_enemies: Array[Node2D] = []  # Evitar hit múltiplo no mesmo ataque

# Referências dos nós
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_timer: Timer = $AttackTimer

func _ready():
	# Configurar área
	add_to_group("player_weapons")
	collision_layer = 0  # Não colide com nada
	collision_mask = 4   # Detecta inimigos (layer 4)
	
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

func attack() -> void:
	if is_attacking:
		return
	
	is_attacking = true
	hit_enemies.clear()
	
	# Ativar colisão
	set_collision_enabled(true)
	
	# Animação de ataque (rotação)
	create_attack_animation()
	
	# Timer para desativar
	attack_timer.start()
	
	print("BerserkerWeapon: Ataque iniciado - Dano: ", current_damage)

func create_attack_animation():
	# Animação de rotação da arma
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Rotação completa
	var start_rotation = sprite.rotation
	tween.tween_property(sprite, "rotation", start_rotation + TAU, attack_duration)
	
	# Efeito de escala (pulso)
	var original_scale = sprite.scale
	tween.tween_property(sprite, "scale", original_scale * 1.2, attack_duration * 0.5)
	tween.tween_property(sprite, "scale", original_scale, attack_duration * 0.5).set_delay(attack_duration * 0.5)
	
	# Efeito de cor (flash)
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
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
	
	hit_enemies.append(enemy)
	
	# Aplicar dano
	if enemy.has_method("take_damage"):
		enemy.take_damage(current_damage)
	
	# Aplicar knockback
	apply_knockback(enemy)
	
	# Emitir sinal
	enemy_hit.emit(enemy, current_damage)
	
	# Efeito visual no inimigo
	create_hit_effect(enemy)
	
	print("BerserkerWeapon: Inimigo atingido - Dano: ", current_damage)

func apply_knockback(enemy: Node2D):
	if not enemy.has_method("apply_knockback"):
		return
	
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
