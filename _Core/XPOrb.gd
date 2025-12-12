extends Area2D
class_name XPOrb

# Orb de experiência que é coletada pelo player

@export var xp_value: int = 10
@export var collection_distance: float = 30.0
@export var attraction_distance: float = 80.0
@export var attraction_speed: float = 200.0
@export var merge_distance: float = 20.0  # Distância para combinar orbs

var target_player: Node2D = null
var is_being_attracted: bool = false
var merge_check_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	# Configurar grupos e sinais
	add_to_group("xp_orbs")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Configurar collision
	collision_layer = 8   # Layer das orbs
	collision_mask = 1    # Mask do player
	
	# Efeito visual inicial
	create_spawn_effect()
	
	# Iniciar timer de verificação de merge
	merge_check_timer = randf_range(1.0, 3.0)  # Delay aleatório para evitar todos checarem ao mesmo tempo

func _physics_process(delta):
	find_nearest_player()
	handle_attraction(delta)
	handle_merge_check(delta)

func find_nearest_player():
	var players = get_tree().get_nodes_in_group("players")
	var nearest_player: Node2D = null
	var nearest_distance: float = attraction_distance
	
	for player in players:
		if not is_instance_valid(player):
			continue
		
		var distance = global_position.distance_to(player.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_player = player
	
	target_player = nearest_player

func handle_merge_check(delta):
	# Verificar merge com outras orbs periodicamente
	merge_check_timer -= delta
	if merge_check_timer <= 0:
		merge_check_timer = 2.0  # Verificar a cada 2 segundos
		check_for_merge()

func handle_attraction(delta):
	if not target_player:
		is_being_attracted = false
		return
	
	var distance_to_player = global_position.distance_to(target_player.global_position)
	
	# Verificar se deve ser coletada
	if distance_to_player <= collection_distance:
		collect_orb()
		return
	
	# Verificar se deve ser atraída
	if distance_to_player <= attraction_distance:
		is_being_attracted = true
		
		# Mover em direção ao player
		var direction = (target_player.global_position - global_position).normalized()
		var speed = attraction_speed * (1.0 + (attraction_distance - distance_to_player) / attraction_distance)
		global_position += direction * speed * delta
	else:
		is_being_attracted = false

func collect_orb():
	# Dar experiência ao player
	if target_player and target_player.has_method("gain_experience"):
		target_player.gain_experience(xp_value)
	
	# Efeito visual de coleta
	create_collection_effect()
	
	# Remover orb
	queue_free()

func create_spawn_effect():
	# Efeito de spawn (escala crescente)
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func create_collection_effect():
	# Efeito de coleta (brilho e desaparecimento)
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0), 0.2)

func _on_body_entered(body):
	if body.is_in_group("players"):
		collect_orb()

func _on_area_entered(area):
	if area.is_in_group("players"):
		collect_orb()

func check_for_merge():
	# Procurar outras orbs próximas para combinar
	var nearby_orbs = get_tree().get_nodes_in_group("xp_orbs")
	
	for orb in nearby_orbs:
		if orb == self or not is_instance_valid(orb):
			continue
		
		var distance = global_position.distance_to(orb.global_position)
		if distance <= merge_distance:
			# Combinar com a orb mais próxima
			merge_with_orb(orb)
			break

func merge_with_orb(other_orb: XPOrb):
	# Somar valores de XP
	var combined_value = xp_value + other_orb.xp_value
	
	# Determinar tipo da orb combinada baseado no valor total
	var new_type = get_orb_type_by_value(combined_value)
	
	# Atualizar esta orb com o valor combinado
	setup_xp_orb(combined_value, new_type)
	
	# Efeito visual de merge
	create_merge_effect()
	
	# Remover a outra orb
	other_orb.queue_free()
	
	print("Orbs combinadas! Novo valor: ", combined_value)

func get_orb_type_by_value(value: int) -> String:
	# Determinar tipo baseado no valor
	if value >= 100:
		return "boss"
	elif value >= 50:
		return "large"
	elif value >= 20:
		return "normal"
	else:
		return "small"

func create_merge_effect():
	# Efeito visual de combinação
	var original_scale = scale
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * 1.3, 0.2)
	tween.tween_property(self, "scale", original_scale, 0.2)

# Configurar valor da orb
func setup_xp_orb(value: int, orb_type: String = "normal"):
	xp_value = value
	
	# Diferentes tipos de orb baseados no valor
	match orb_type:
		"small":
			modulate = Color.CYAN
			scale = Vector2(0.6, 0.6)
		"normal":
			modulate = Color.YELLOW
			scale = Vector2(0.8, 0.8)
		"large":
			modulate = Color.ORANGE
			scale = Vector2(1.0, 1.0)
		"boss":
			modulate = Color.PURPLE
			scale = Vector2(1.2, 1.2)
		_:
			modulate = Color.YELLOW
			scale = Vector2(0.8, 0.8)
	
	# Atualizar texto de valor se houver (para debug)
	update_visual_feedback()

func update_visual_feedback():
	# Opcional: mostrar valor da orb visualmente
	# Pode ser usado para debug ou feedback visual
	pass