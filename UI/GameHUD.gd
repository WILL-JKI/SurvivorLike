extends Control
class_name GameHUD

# HUD principal do jogo com barras de HP e XP

# Referências dos nós
@onready var health_bar: ProgressBar = $VBoxContainer/HealthContainer/HealthBar
@onready var health_label: Label = $VBoxContainer/HealthContainer/HealthLabel
@onready var xp_bar: ProgressBar = $VBoxContainer/XPContainer/XPBar
@onready var xp_label: Label = $VBoxContainer/XPContainer/XPLabel
@onready var level_label: Label = $VBoxContainer/LevelContainer/LevelLabel
@onready var stats_label: Label = $VBoxContainer/StatsContainer/StatsLabel

# Referência do player atual
var current_player: Node2D = null

func _ready():
	# Configurar HUD
	setup_hud()
	
	# Encontrar player na cena
	find_player()
	
	print("GameHUD: HUD inicializado")

func setup_hud():
	# Configurar barras de progresso com verificações de segurança
	if health_bar:
		health_bar.min_value = 0
		health_bar.max_value = 100
		health_bar.value = 100
		health_bar.show_percentage = false
		print("GameHUD: Health bar configurada")
	else:
		print("GameHUD: AVISO - Health bar não encontrada")
	
	if xp_bar:
		xp_bar.min_value = 0
		xp_bar.max_value = 100
		xp_bar.value = 0
		xp_bar.show_percentage = false
		print("GameHUD: XP bar configurada")
	else:
		print("GameHUD: AVISO - XP bar não encontrada")

func find_player():
	# Procurar player na cena
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		set_player(players[0])
	else:
		# Tentar novamente após um frame
		await get_tree().process_frame
		call_deferred("find_player")

func set_player(player: Node2D):
	current_player = player
	
	if current_player:
		# Conectar sinais do player se disponíveis
		if current_player.has_signal("level_changed"):
			current_player.level_changed.connect(_on_player_level_changed)
		
		# Atualizar HUD inicial
		update_hud()
		print("GameHUD: Player conectado - %s" % current_player.name)

func _process(delta):
	# Atualizar HUD continuamente
	if current_player:
		update_hud()

func update_hud():
	if not current_player:
		return
	
	# Atualizar barra de vida
	update_health_bar()
	
	# Atualizar barra de XP
	update_xp_bar()
	
	# Atualizar level
	update_level_display()
	
	# Atualizar stats (opcional)
	update_stats_display()

func update_health_bar():
	if not health_bar or not current_player:
		return
	
	var max_health = current_player.get("max_health")
	var current_health = current_player.get("current_health")
	
	if max_health != null and current_health != null:
		health_bar.max_value = max_health
		health_bar.value = current_health
		
		# Atualizar label
		if health_label:
			health_label.text = "HP: %.0f/%.0f" % [current_health, max_health]
		
		# Cor da barra baseada na porcentagem
		var health_percent = current_health / max_health
		if health_percent > 0.6:
			health_bar.modulate = Color.GREEN
		elif health_percent > 0.3:
			health_bar.modulate = Color.YELLOW
		else:
			health_bar.modulate = Color.RED

func update_xp_bar():
	if not xp_bar or not current_player:
		return
	
	var current_xp = current_player.get("current_experience")
	var xp_to_next = current_player.get("experience_to_next_level")
	
	if current_xp != null and xp_to_next != null:
		xp_bar.max_value = xp_to_next
		xp_bar.value = current_xp
		
		# Atualizar label
		if xp_label:
			xp_label.text = "XP: %d/%d" % [current_xp, xp_to_next]
		
		# Cor da barra de XP
		xp_bar.modulate = Color.CYAN

func update_level_display():
	if not level_label or not current_player:
		return
	
	var current_level = current_player.get("current_level")
	if current_level != null:
		level_label.text = "Level: %d" % current_level

func update_stats_display():
	if not stats_label:
		return
	
	# Mostrar algumas stats importantes
	var stats_text = ""
	
	# Stats do GameManager
	var move_speed = GameManager.get_stat("move_speed")
	var area_size = GameManager.get_stat("area_size")
	var cooldown_reduction = GameManager.get_stat("cooldown_reduction")
	
	stats_text += "Speed: %.1fx  " % move_speed
	stats_text += "Area: %.1fx  " % area_size
	stats_text += "CDR: %.0f%%" % (cooldown_reduction * 100)
	
	stats_label.text = stats_text

func _on_player_level_changed(new_level: int):
	print("GameHUD: Player subiu para level %d" % new_level)
	
	# Efeito visual de level up
	create_level_up_effect()

func create_level_up_effect():
	# Efeito visual quando sobe de level
	if level_label:
		var tween = create_tween()
		tween.set_parallel(true)
		
		# Piscar o label
		tween.tween_property(level_label, "modulate", Color.YELLOW, 0.2)
		tween.tween_property(level_label, "scale", Vector2(1.2, 1.2), 0.2)
		
		tween.tween_delay(0.5)
		
		tween.tween_property(level_label, "modulate", Color.WHITE, 0.2)
		tween.tween_property(level_label, "scale", Vector2(1.0, 1.0), 0.2)

# Função para mostrar/esconder HUD
func set_hud_visible(visible: bool):
	self.visible = visible

# Função para pausar/despausar atualizações
func set_hud_paused(paused: bool):
	set_process(not paused)