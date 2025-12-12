extends Label
class_name DamageNumber

# Sistema de números de dano flutuantes

@export var float_speed: float = 50.0
@export var float_duration: float = 1.5
@export var fade_start_time: float = 0.8

var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 0.0

func _ready():
	# Configurar aparência inicial
	modulate = Color.WHITE
	z_index = 100  # Aparecer na frente de tudo
	
	# Movimento inicial aleatório para cima
	velocity = Vector2(randf_range(-20, 20), -float_speed)
	
	# Configurar fonte pixel art
	setup_pixel_font()

func setup_pixel_font():
	# Usar FontManager se disponível
	if FontManager:
		FontManager.apply_pixel_font(self, 16)
	else:
		# Fallback manual
		add_theme_font_size_override("font_size", 12)
		add_theme_color_override("font_outline_color", Color.BLACK)
		add_theme_constant_override("outline_size", 1)
	
	# Configurar sombra
	add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	add_theme_constant_override("shadow_offset_x", 1)
	add_theme_constant_override("shadow_offset_y", 1)

func _process(delta):
	# Atualizar posição
	global_position += velocity * delta
	
	# Reduzir velocidade gradualmente
	velocity = velocity.lerp(Vector2.ZERO, delta * 2.0)
	
	# Atualizar tempo de vida
	lifetime += delta
	
	# Começar a fade após um tempo
	if lifetime > fade_start_time:
		var fade_progress = (lifetime - fade_start_time) / (float_duration - fade_start_time)
		modulate.a = 1.0 - fade_progress
	
	# Remover após duração completa
	if lifetime >= float_duration:
		queue_free()

# Configurar o número de dano
func setup_damage(damage_amount: float, damage_type: String = "normal"):
	text = str(int(damage_amount))
	
	# Cores diferentes para tipos de dano
	match damage_type:
		"normal":
			modulate = Color.WHITE
		"poison":
			modulate = Color.GREEN
		"critical":
			modulate = Color.YELLOW
			add_theme_font_size_override("font_size", 16)
			# Outline mais forte para críticos
			add_theme_constant_override("outline_size", 2)
		"boss":
			modulate = Color.RED
			add_theme_font_size_override("font_size", 14)
			# Outline vermelho para boss
			add_theme_color_override("font_outline_color", Color.DARK_RED)
		"player_damage":
			modulate = Color.RED
			add_theme_font_size_override("font_size", 18)
			# Outline preto mais forte para dano do player
			add_theme_color_override("font_outline_color", Color.BLACK)
			add_theme_constant_override("outline_size", 2)
			# Movimento diferente para dano recebido
			velocity = Vector2(randf_range(-30, 30), -float_speed * 1.5)
		_:
			modulate = Color.WHITE
