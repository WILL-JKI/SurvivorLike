extends Area2D
class_name IceProjectile

# Sinais
signal enemy_hit(enemy: Node2D, frost_stacks: int)
signal projectile_destroyed()

# Variáveis de configuração
@export_group("Projectile Stats")
@export var speed: float = 200.0
@export var frost_stacks: int = 1  # Quantos stacks de frost aplicar
@export var damage: float = 15.0   # Dano base do projétil
@export var lifetime: float = 3.0  # Tempo de vida máximo
@export var piercing: int = 0      # Quantos inimigos pode atravessar (0 = para no primeiro)

# Variáveis internas
var direction: Vector2 = Vector2.RIGHT
var enemies_hit: int = 0
var has_hit_enemies: Array[Node2D] = []  # Evitar hit múltiplo no mesmo inimigo

# Referências dos nós
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready():
	# Configurar área
	add_to_group("projectiles")
	collision_layer = 8  # Layer dos projéteis
	collision_mask = 2   # Detecta inimigos (layer 2)
	
	# Conectar sinais
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Configurar timer de vida
	lifetime_timer.wait_time = lifetime
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(_on_lifetime_expired)
	lifetime_timer.start()
	
	# Orientar sprite na direção do movimento
	rotation = direction.angle()
	
	print("IceProjectile: Projétil de gelo criado - Frost stacks: %d, Piercing: %d" % [frost_stacks, piercing])

func _physics_process(delta):
	# Movimento linear simples
	position += transform.x * speed * delta

func setup_projectile(start_pos: Vector2, target_direction: Vector2, projectile_speed: float = 200.0):
	# Configurar projétil antes de adicionar à cena
	global_position = start_pos
	direction = target_direction.normalized()
	speed = projectile_speed
	rotation = direction.angle()

func _on_body_entered(body: Node2D):
	if body.is_in_group("enemies") and body not in has_hit_enemies:
		hit_enemy(body)

func _on_area_entered(area: Area2D):
	if area.is_in_group("enemies") and area not in has_hit_enemies:
		hit_enemy(area)

func hit_enemy(enemy: Node2D):
	# Evitar hit múltiplo no mesmo inimigo
	if enemy in has_hit_enemies:
		return
	
	has_hit_enemies.append(enemy)
	enemies_hit += 1
	
	# Aplicar frost stacks
	if enemy.has_method("apply_frost"):
		enemy.apply_frost(frost_stacks)
		print("IceProjectile: Aplicando %d frost stacks em %s" % [frost_stacks, enemy.name])
	
	# Aplicar dano base
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
	
	# Emitir sinal
	enemy_hit.emit(enemy, frost_stacks)
	
	# Efeito visual de impacto
	create_hit_effect(enemy.global_position)
	
	# Verificar se deve ser destruído
	if piercing <= 0 or enemies_hit > piercing:
		destroy_projectile()

func create_hit_effect(hit_position: Vector2):
	# Efeito visual de impacto de gelo
	var effect_scene = preload("res://_Core/DamageNumber.tscn")
	var effect = effect_scene.instantiate()
	
	effect.global_position = hit_position
	effect.setup_damage(frost_stacks, "frost_effect")
	
	get_parent().add_child(effect)
	
	# Efeito de partículas de gelo (placeholder)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.CYAN, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func _on_lifetime_expired():
	print("IceProjectile: Projétil expirou por tempo limite")
	destroy_projectile()

func destroy_projectile():
	# Emitir sinal antes de destruir
	projectile_destroyed.emit()
	
	# Efeito de destruição
	create_destruction_effect()
	
	# Destruir projétil
	queue_free()

func create_destruction_effect():
	# Efeito visual de destruição (cristais de gelo se espalhando)
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out
	tween.tween_property(sprite, "modulate", Color.TRANSPARENT, 0.2)
	
	# Escala para simular explosão de gelo
	tween.tween_property(sprite, "scale", sprite.scale * 1.5, 0.2)

# Funções para upgrades
func upgrade_piercing(amount: int):
	piercing += amount
	print("IceProjectile: Piercing aumentado para: %d" % piercing)

func upgrade_frost_stacks(amount: int):
	frost_stacks += amount
	print("IceProjectile: Frost stacks aumentado para: %d" % frost_stacks)

func upgrade_speed(multiplier: float):
	speed *= multiplier
	print("IceProjectile: Velocidade aumentada para: %.1f" % speed)

func upgrade_damage(amount: float):
	damage += amount
	print("IceProjectile: Dano aumentado para: %.1f" % damage)

func set_infinite_piercing():
	piercing = 999  # Piercing "infinito"
	print("IceProjectile: Piercing infinito ativado!")