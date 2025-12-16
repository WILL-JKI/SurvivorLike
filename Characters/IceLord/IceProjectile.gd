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
@export var knockback_force: float = 100.0  # Força de knockback
@export var area_multiplier: float = 1.0    # Multiplicador de área de efeito

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
	
	# Aplicar multiplicador de área
	apply_area_multiplier()
	
	# Orientar sprite na direção do movimento
	rotation = direction.angle()
	
	print("IceProjectile: Projétil de gelo criado - Frost stacks: %d, Piercing: %d, Área: %.2f" % [frost_stacks, piercing, area_multiplier])

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
	
	# Aplicar dano (compatível com diferentes assinaturas)
	if enemy.has_method("take_damage"):
		var knockback_vector = direction * knockback_force
		
		# Verificar se take_damage aceita parâmetro de knockback
		var method_info = enemy.get_method_list()
		var has_knockback_param = false
		for method in method_info:
			if method.name == "take_damage" and method.args.size() > 1:
				has_knockback_param = true
				break
		
		# Chamar take_damage com a assinatura correta
		print("IceProjectile: DEBUG - Aplicando dano %.1f a %s (knockback: %s)" % [damage, enemy.name, has_knockback_param])
		
		if has_knockback_param:
			enemy.take_damage(damage, knockback_vector)
			print("IceProjectile: Dano e knockback aplicados a %s: %.1f" % [enemy.name, damage])
		else:
			enemy.take_damage(damage)
			print("IceProjectile: Dano aplicado a %s: %.1f" % [enemy.name, damage])
			
			# Aplicar knockback separadamente se suportado
			if enemy.has_method("apply_knockback"):
				enemy.apply_knockback(knockback_vector)
	
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

func set_area_multiplier(multiplier: float):
	area_multiplier = multiplier
	apply_area_multiplier()

func apply_area_multiplier():
	# Aplicar multiplicador de área ao collision shape
	if collision_shape and collision_shape.shape:
		var original_scale = collision_shape.scale
		collision_shape.scale = original_scale * area_multiplier
		
		# Aplicar também ao sprite para feedback visual
		if sprite:
			sprite.scale = sprite.scale * area_multiplier
		
		print("IceProjectile: Área multiplicada por %.2f" % area_multiplier)

func upgrade_knockback(multiplier: float):
	knockback_force *= multiplier
	print("IceProjectile: Knockback aumentado para: %.1f" % knockback_force)