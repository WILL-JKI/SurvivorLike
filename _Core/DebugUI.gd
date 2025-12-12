extends Control
class_name DebugUI

# UI de Debug para monitoramento do jogo

@export var update_interval: float = 0.5  # Atualizar a cada 0.5 segundos

var is_visible: bool = false
var update_timer: float = 0.0
var performance_monitor: PerformanceMonitor

# Referências de nós
@onready var debug_panel: Panel = $DebugPanel
@onready var debug_label: RichTextLabel = $DebugPanel/VBoxContainer/DebugLabel
@onready var title_label: Label = $DebugPanel/VBoxContainer/TitleLabel

func _ready():
	# Configurar UI inicial
	setup_debug_ui()
	
	# Esconder por padrão
	visible = false
	
	# Configurar input
	set_process_unhandled_input(true)
	
	# Criar monitor de performance
	performance_monitor = PerformanceMonitor.new()
	add_child(performance_monitor)

func _unhandled_input(event):
	# Toggle debug com F3
	if event.is_action_pressed("dv_debug"):
		toggle_debug()

func _process(delta):
	if not is_visible:
		return
	
	# Atualizar informações periodicamente
	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0.0
		update_debug_info()

func setup_debug_ui():
	# Configurar aparência do painel
	if debug_panel:
		debug_panel.modulate = Color(0, 0, 0, 0.8)  # Fundo semi-transparente
	
	if title_label:
		title_label.text = "DEBUG INFO (F3 to toggle)"
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if debug_label:
		debug_label.fit_content = true
		debug_label.scroll_active = false

func toggle_debug():
	is_visible = not is_visible
	visible = is_visible
	
	if is_visible:
		update_debug_info()
		print("Debug UI ativada")
	else:
		print("Debug UI desativada")

func update_debug_info():
	if not debug_label:
		return
	
	var debug_text = ""
	
	# Informações de Performance
	debug_text += "[color=yellow][b]PERFORMANCE[/b][/color]\n"
	
	if performance_monitor:
		var perf = performance_monitor.get_performance_summary()
		debug_text += "FPS: " + str(perf.current_fps) + " (avg: " + str(int(perf.average_fps)) + ")\n"
		debug_text += "Frame Time: " + str(snapped(perf.frame_time_ms, 0.1)) + "ms (avg: " + str(snapped(perf.avg_frame_time_ms, 0.1)) + "ms)\n"
		debug_text += "FPS Range: " + str(int(perf.min_fps)) + " - " + str(int(perf.max_fps)) + "\n"
		debug_text += "Memory: " + str(snapped(perf.memory_mb, 0.1)) + " MB\n"
	else:
		debug_text += "FPS: " + str(Engine.get_frames_per_second()) + "\n"
		debug_text += "Frame Time: " + str(snapped(1.0 / Engine.get_frames_per_second() * 1000, 0.1)) + "ms\n"
		debug_text += "Memory: " + format_bytes(OS.get_static_memory_peak_usage()) + "\n"
	
	debug_text += "Process ID: " + str(OS.get_process_id()) + "\n"
	
	# Informações do Engine
	debug_text += "Engine: Godot " + Engine.get_version_info().string + "\n"
	debug_text += "\n"
	
	# Informações de Entidades
	debug_text += "[color=cyan][b]ENTITIES[/b][/color]\n"
	var entity_counts = get_entity_counts()
	
	debug_text += "XP Orbs (x): " + str(entity_counts.xp_orbs) + "\n"
	debug_text += "Enemies (e): " + str(entity_counts.enemies) + "\n"
	debug_text += "Bosses (b): " + str(entity_counts.bosses) + "\n"
	debug_text += "Minions (m): " + str(entity_counts.minions) + "\n"
	debug_text += "Players (p): " + str(entity_counts.players) + "\n"
	debug_text += "Total Nodes: " + str(get_tree().get_node_count()) + "\n"
	debug_text += "\n"
	
	# Informações do Player
	var player_info = get_player_info()
	if player_info:
		debug_text += "[color=green][b]PLAYER[/b][/color]\n"
		debug_text += "Level: " + str(player_info.level) + "\n"
		debug_text += "Health: " + str(int(player_info.health)) + "/" + str(int(player_info.max_health)) + "\n"
		debug_text += "XP: " + str(player_info.experience) + "/" + str(player_info.exp_to_next) + "\n"
		# Informações específicas por tipo de player
		if player_info.has("active_minions") and player_info.has("max_minions"):
			debug_text += "Active Minions: " + str(player_info.active_minions) + "/" + str(player_info.max_minions) + "\n"
		elif player_info.has("enemies_in_fury"):
			debug_text += "Enemies in Fury Range: " + str(player_info.enemies_in_fury) + "\n"
		debug_text += "Evolution: " + str(player_info.evolution_route if player_info.evolution_route != "" else "None") + "\n"
		debug_text += "\n"
	
	# Informações de Sistema
	debug_text += "[color=orange][b]SYSTEM[/b][/color]\n"
	debug_text += "OS: " + OS.get_name() + "\n"
	debug_text += "Processor: " + OS.get_processor_name() + "\n"
	debug_text += "Threads: " + str(OS.get_processor_count()) + "\n"
	
	# Informações de Viewport
	var viewport = get_viewport()
	if viewport:
		debug_text += "Screen: " + str(viewport.get_visible_rect().size) + "\n"
		debug_text += "Render: " + str(viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME)) + " draw calls\n"
	
	debug_text += "\n"
	
	# Informações de Input
	debug_text += "[color=magenta][b]CONTROLS[/b][/color]\n"
	debug_text += "F3: Toggle Debug\n"
	debug_text += "WASD: Move Player\n"
	debug_text += "ESC: Spawn Boss (TestRatKing)\n"
	debug_text += "SPACE: Spawn Enemies (TestRatKing)\n"
	
	# Atualizar o texto
	debug_label.text = debug_text

func get_entity_counts() -> Dictionary:
	var counts = {
		"xp_orbs": 0,
		"enemies": 0,
		"bosses": 0,
		"minions": 0,
		"players": 0
	}
	
	# Contar XP Orbs
	var xp_orbs = get_tree().get_nodes_in_group("xp_orbs")
	counts.xp_orbs = xp_orbs.size()
	
	# Contar Enemies (incluindo bosses)
	var enemies = get_tree().get_nodes_in_group("enemies")
	counts.enemies = enemies.size()
	
	# Contar Bosses especificamente
	var bosses = get_tree().get_nodes_in_group("boss")
	counts.bosses = bosses.size()
	
	# Ajustar contagem de enemies (remover bosses da contagem)
	counts.enemies -= counts.bosses
	
	# Contar Minions
	var minions = get_tree().get_nodes_in_group("minions")
	counts.minions = minions.size()
	
	# Contar Players
	var players = get_tree().get_nodes_in_group("players")
	counts.players = players.size()
	
	return counts

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

# Função para adicionar informações customizadas
func add_custom_info(title: String, info: String):
	if debug_label:
		debug_label.text += "\n[color=white][b]" + title + "[/b][/color]\n" + info + "\n"
