extends CanvasLayer
# UI de Debug simples que fica fixa na tela

@export var update_interval: float = 0.5
var is_debug_visible: bool = false
var update_timer: float = 0.0

# Referências dos nós (serão definidas em _ready)
var control: Control
var debug_panel: Panel
var debug_label: RichTextLabel

func _ready():
	# Configurar layer
	layer = 100  # CanvasLayer alto para ficar na frente
	
	# Configurar input
	set_process_unhandled_input(true)
	
	# Otimização: não processar até ser ativado
	set_process(false)
	
	# Encontrar nós manualmente (mais confiável que @onready)
	print("SimpleDebugUI: === INICIALIZANDO ===")
	
	# Buscar Control
	control = get_node_or_null("Control")
	if not control:
		print("SimpleDebugUI: ERRO - Control não encontrado!")
		return
	print("SimpleDebugUI: Control encontrado")
	
	# Buscar DebugPanel
	debug_panel = control.get_node_or_null("DebugPanel")
	if not debug_panel:
		print("SimpleDebugUI: ERRO - DebugPanel não encontrado!")
		return
	print("SimpleDebugUI: DebugPanel encontrado")
	
	# Buscar VBoxContainer
	var vbox = debug_panel.get_node_or_null("VBoxContainer")
	if not vbox:
		print("SimpleDebugUI: ERRO - VBoxContainer não encontrado!")
		return
	print("SimpleDebugUI: VBoxContainer encontrado")
	
	# Buscar DebugLabel
	debug_label = vbox.get_node_or_null("DebugLabel")
	if not debug_label:
		print("SimpleDebugUI: ERRO - DebugLabel não encontrado!")
		return
	print("SimpleDebugUI: DebugLabel encontrado")
	
	# Configurar UI
	control.visible = false
	debug_label.text = "Debug UI Pronta!"
	
	# Aplicar fonte UI diretamente
	if ResourceLoader.exists("res://Assets/Fonts/UIFont.ttf"):
		var ui_font = load("res://Assets/Fonts/UIFont.ttf")
		debug_label.add_theme_font_override("normal_font", ui_font)
		debug_label.add_theme_font_size_override("normal_font_size", 14)
		print("SimpleDebugUI: UiFont aplicada diretamente")
	else:
		print("SimpleDebugUI: UIFont.ttf não encontrada")
		# Tentar através do FontManager como fallback
		if FontManager and FontManager.ui_font:
			debug_label.add_theme_font_override("normal_font", FontManager.ui_font)
			debug_label.add_theme_font_size_override("normal_font_size", 14)
			print("SimpleDebugUI: Fonte UI aplicada via FontManager")
		else:
			print("SimpleDebugUI: Nenhuma fonte UI disponível")
	
	# Configurar cores para RichTextLabel (múltiplas propriedades)
	debug_label.add_theme_color_override("default_color", Color.WHITE)
	debug_label.add_theme_color_override("font_color", Color.WHITE)
	debug_label.modulate = Color.WHITE
	print("SimpleDebugUI: Cor branca aplicada")
	
	print("SimpleDebugUI: Inicialização completa (ESC para ativar)")

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):  # ESC como alternativa
		toggle_debug()
		get_viewport().set_input_as_handled()

func _process(delta):
	if is_debug_visible:
		update_timer += delta
		if update_timer >= update_interval:
			update_timer = 0.0
			update_debug_info()

func toggle_debug():
	is_debug_visible = not is_debug_visible
	control.visible = is_debug_visible
	
	# Otimização: só processar quando visível
	set_process(is_debug_visible)
	
	if is_debug_visible:
		update_debug_info()
		print("Debug UI ativada")
	else:
		print("Debug UI desativada")

func update_debug_info():
	if not debug_label:
		print("SimpleDebugUI: ERRO - debug_label não encontrado!")
		return
	
	# Usar Array para StringBuilder (mais eficiente)
	var debug_lines: Array[String] = []
	
	# Performance
	debug_lines.append("[color=yellow][b]PERFORMANCE[/b][/color]")
	debug_lines.append("FPS: %d" % Engine.get_frames_per_second())
	debug_lines.append("Frame Time: %.1fms" % (1.0 / max(Engine.get_frames_per_second(), 1) * 1000))
	debug_lines.append("Memory: %s" % format_bytes(OS.get_static_memory_peak_usage()))
	debug_lines.append("")
	
	# Entidades
	debug_lines.append("[color=cyan][b]ENTITIES[/b][/color]")
	var entity_counts = get_entity_counts()
	debug_lines.append("XP Orbs (x): %d" % entity_counts.xp_orbs)
	debug_lines.append("Enemies (e): %d" % entity_counts.enemies)
	debug_lines.append("Bosses (b): %d" % entity_counts.bosses)
	debug_lines.append("Minions (m): %d" % entity_counts.minions)
	debug_lines.append("Players (p): %d" % entity_counts.players)
	debug_lines.append("Total Nodes: %d" % get_tree().get_node_count())
	debug_lines.append("")
	
	# Player Info
	var player_info = get_player_info()
	if player_info:
		debug_lines.append("[color=green][b]PLAYER[/b][/color]")
		debug_lines.append("Level: %s" % str(player_info.level))
		debug_lines.append("Health: %d/%d" % [int(player_info.health), int(player_info.max_health)])
		debug_lines.append("XP: %s/%s" % [str(player_info.experience), str(player_info.exp_to_next)])
		debug_lines.append("")
	
	# Controles
	debug_lines.append("[color=magenta][b]CONTROLS[/b][/color]")
	debug_lines.append("ESC: Toggle Debug")
	debug_lines.append("WASD: Move Player")
	
	# Juntar todas as linhas de uma vez (mais eficiente)
	debug_label.text = "\n".join(debug_lines)

func get_entity_counts() -> Dictionary:
	# Usar cache se disponível, senão usar método direto
	if NodeGroupCache:
		return {
			"xp_orbs": NodeGroupCache.get_group_size_cached("xp_orbs"),
			"enemies": NodeGroupCache.get_group_size_cached("enemies") - NodeGroupCache.get_group_size_cached("boss"),
			"bosses": NodeGroupCache.get_group_size_cached("boss"),
			"minions": NodeGroupCache.get_group_size_cached("minions"),
			"players": NodeGroupCache.get_group_size_cached("players")
		}
	else:
		# Fallback sem cache
		var bosses_count = get_tree().get_nodes_in_group("boss").size()
		return {
			"xp_orbs": get_tree().get_nodes_in_group("xp_orbs").size(),
			"enemies": get_tree().get_nodes_in_group("enemies").size() - bosses_count,
			"bosses": bosses_count,
			"minions": get_tree().get_nodes_in_group("minions").size(),
			"players": get_tree().get_nodes_in_group("players").size()
		}

# Cache do player para evitar busca constante
var cached_player: Node = null
var player_cache_timer: float = 0.0

func get_player_info() -> Dictionary:
	# Atualizar cache do player a cada 1 segundo
	player_cache_timer -= get_process_delta_time()
	if player_cache_timer <= 0 or not cached_player or not is_instance_valid(cached_player):
		player_cache_timer = 1.0
		var players = NodeGroupCache.get_nodes_in_group_cached("players") if NodeGroupCache else get_tree().get_nodes_in_group("players")
		cached_player = players[0] if players.size() > 0 else null
	
	if cached_player and cached_player.has_method("get_player_info"):
		return cached_player.get_player_info()
	return {}

func format_bytes(bytes: int) -> String:
	var units = ["B", "KB", "MB", "GB"]
	var size = float(bytes)
	var unit_index = 0
	
	while size >= 1024.0 and unit_index < units.size() - 1:
		size /= 1024.0
		unit_index += 1
	
	return str(snapped(size, 0.1)) + " " + units[unit_index]
