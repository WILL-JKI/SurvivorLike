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
	
	if is_debug_visible:
		update_debug_info()
		print("Debug UI ativada")
	else:
		print("Debug UI desativada")

func update_debug_info():
	if not debug_label:
		print("SimpleDebugUI: ERRO - debug_label não encontrado!")
		return
	
	print("SimpleDebugUI: Atualizando informações de debug...")
	var debug_text = ""
	
	# Performance
	debug_text += "[color=yellow][b]PERFORMANCE[/b][/color]\n"
	debug_text += "FPS: " + str(Engine.get_frames_per_second()) + "\n"
	debug_text += "Frame Time: " + str(snapped(1.0 / max(Engine.get_frames_per_second(), 1) * 1000, 0.1)) + "ms\n"
	debug_text += "Memory: " + format_bytes(OS.get_static_memory_peak_usage()) + "\n"
	debug_text += "\n"
	
	# Entidades
	debug_text += "[color=cyan][b]ENTITIES[/b][/color]\n"
	var entity_counts = get_entity_counts()
	debug_text += "XP Orbs (x): " + str(entity_counts.xp_orbs) + "\n"
	debug_text += "Enemies (e): " + str(entity_counts.enemies) + "\n"
	debug_text += "Bosses (b): " + str(entity_counts.bosses) + "\n"
	debug_text += "Minions (m): " + str(entity_counts.minions) + "\n"
	debug_text += "Players (p): " + str(entity_counts.players) + "\n"
	debug_text += "Total Nodes: " + str(get_tree().get_node_count()) + "\n"
	debug_text += "\n"
	
	# Player Info
	var player_info = get_player_info()
	if player_info:
		debug_text += "[color=green][b]PLAYER[/b][/color]\n"
		debug_text += "Level: " + str(player_info.level) + "\n"
		debug_text += "Health: " + str(int(player_info.health)) + "/" + str(int(player_info.max_health)) + "\n"
		debug_text += "XP: " + str(player_info.experience) + "/" + str(player_info.exp_to_next) + "\n"
		debug_text += "\n"
	
	# Controles
	debug_text += "[color=magenta][b]CONTROLS[/b][/color]\n"
	debug_text += "ESC: Toggle Debug\n"
	debug_text += "WASD: Move Player\n"
	
	debug_label.text = debug_text
	print("SimpleDebugUI: Texto definido - comprimento: ", debug_text.length())

func get_entity_counts() -> Dictionary:
	return {
		"xp_orbs": get_tree().get_nodes_in_group("xp_orbs").size(),
		"enemies": get_tree().get_nodes_in_group("enemies").size() - get_tree().get_nodes_in_group("boss").size(),
		"bosses": get_tree().get_nodes_in_group("boss").size(),
		"minions": get_tree().get_nodes_in_group("minions").size(),
		"players": get_tree().get_nodes_in_group("players").size()
	}

func get_player_info() -> Dictionary:
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		var player = players[0]
		if player.has_method("get_player_info"):
			return player.get_player_info()
	return {}

func format_bytes(bytes: int) -> String:
	var units = ["B", "KB", "MB", "GB"]
	var size = float(bytes)
	var unit_index = 0
	
	while size >= 1024.0 and unit_index < units.size() - 1:
		size /= 1024.0
		unit_index += 1
	
	return str(snapped(size, 0.1)) + " " + units[unit_index]