extends CharacterBody2D
class_name TestBoss

# Boss simples apenas para testar a câmera
# Não tem funcionalidade, apenas fica parado

@export var max_health: float = 500.0

var current_health: float

# Variáveis de knockback
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 400.0  # Boss mais pesado, menos knockback

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	# Inicializar variáveis
	current_health = max_health
	
	# Configurar grupos - IMPORTANTE: adicionar ao grupo "boss"
	add_to_group("enemies")
	add_to_group("boss")  # Grupo especial para bosses (para câmera)
	
	# Configurar collision
	collision_layer = 2  # Layer dos inimigos
	collision_mask = 1   # Mask do player
	
	print("Test Boss spawnou! Câmera deve detectar automaticamente.")

func _physics_process(delta):
	handle_knockback(delta)

func take_damage(amount: float, knockback_force: Vector2 = Vector2.ZERO):
	current_health -= amount
	
	# Aplicar knockback reduzido (boss é mais pesado)
	if knockback_force != Vector2.ZERO:
		apply_knockback(knockback_force * 0.3)  # Boss recebe menos knockback
	
	# Efeito visual de dano (piscar vermelho)
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Mostrar número de dano
	show_damage_number(amount, "boss")
	
	print("Test Boss recebeu ", amount, " de dano. Vida: ", current_health, "/", max_health)
	
	if current_health <= 0:
		die()

func apply_knockback(force: Vector2):
	knockback_velocity = force

func handle_knockback(delta):
	if knockback_velocity.length() > 0:
		# Aplicar knockback à posição (boss não usa move_and_slide)
		global_position += knockback_velocity * delta
		
		# Reduzir knockback gradualmente
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)

func show_damage_number(damage: float, damage_type: String = "boss"):
	# Carregar e instanciar número de dano
	var damage_number_scene = load("res://_Core/DamageNumber.tscn")
	var damage_number = damage_number_scene.instantiate()
	
	# Posicionar acima do boss
	damage_number.global_position = global_position + Vector2(randf_range(-25, 25), -40)
	
	# Configurar dano
	damage_number.setup_damage(damage, damage_type)
	
	# Adicionar à cena
	get_parent().add_child(damage_number)

func die():
	print("Test Boss foi derrotado!")
	
	# Dar experiência ao player
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.has_method("gain_experience"):
			player.gain_experience(100)
	
	queue_free()