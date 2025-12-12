extends CharacterBody2D
class_name TestBoss

# Boss simples apenas para testar a câmera
# Não tem funcionalidade, apenas fica parado

@export var max_health: float = 500.0

var current_health: float

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

func take_damage(amount: float):
	current_health -= amount
	
	# Efeito visual de dano (piscar vermelho)
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	print("Test Boss recebeu ", amount, " de dano. Vida: ", current_health, "/", max_health)
	
	if current_health <= 0:
		die()

func die():
	print("Test Boss foi derrotado!")
	
	# Dar experiência ao player
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player.has_method("gain_experience"):
			player.gain_experience(100)
	
	queue_free()