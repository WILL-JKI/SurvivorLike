extends Node
class_name UIManager

# Gerenciador central de UI do jogo

# Referências das UIs
@onready var game_hud: GameHUD = $GameHUD
@onready var item_selection: ItemSelectionUI = $ItemSelectionUI

# Estado da UI
var is_item_selection_open: bool = false
var pending_level_ups: Array[int] = []  # Fila de level ups pendentes

func _ready():
	# Configurar sinais
	setup_signals()
	
	print("UIManager: Gerenciador de UI inicializado")

func setup_signals():
	# Conectar sinais da seleção de itens
	if item_selection:
		item_selection.item_selected.connect(_on_item_selected)
		item_selection.selection_cancelled.connect(_on_selection_cancelled)

func _on_item_selected(item: ItemData):
	print("UIManager: Item selecionado - %s" % item.display_name)
	is_item_selection_open = false
	
	# Criar efeito visual de item aplicado
	create_item_applied_effect(item)
	
	# Processar próximo level up se houver
	if not pending_level_ups.is_empty():
		await get_tree().create_timer(0.3).timeout  # Pequeno delay entre seleções
		process_next_level_up()

func _on_selection_cancelled():
	print("UIManager: Seleção de item cancelada")
	is_item_selection_open = false
	
	# Processar próximo level up se houver
	if not pending_level_ups.is_empty():
		await get_tree().create_timer(0.3).timeout  # Pequeno delay entre seleções
		process_next_level_up()

func create_item_applied_effect(item: ItemData):
	# Efeito visual quando um item é aplicado
	if not game_hud:
		return
	
	# Criar label temporário para mostrar o item aplicado
	var effect_label = Label.new()
	effect_label.text = "%s aplicado!" % item.display_name
	effect_label.modulate = Color.YELLOW
	effect_label.z_index = 100
	
	# Posicionar no centro da tela
	effect_label.anchors_preset = Control.PRESET_CENTER
	effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Adicionar à cena
	add_child(effect_label)
	
	# Animar efeito
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Movimento para cima
	tween.tween_property(effect_label, "position", effect_label.position + Vector2(0, -100), 2.0)
	
	# Fade out
	tween.tween_property(effect_label, "modulate", Color.TRANSPARENT, 2.0)
	
	# Remover após animação
	tween.tween_callback(effect_label.queue_free).set_delay(2.0)

# Função para mostrar seleção de itens
func show_item_selection(items: Array[ItemData] = []):
	print("UIManager: show_item_selection chamado - is_open: %s, items: %d" % [is_item_selection_open, items.size()])
	
	if is_item_selection_open:
		print("UIManager: Seleção já está aberta, ignorando")
		return
	
	is_item_selection_open = true
	
	if not item_selection:
		print("UIManager: ERRO - item_selection é null!")
		return
	
	if items.is_empty():
		print("UIManager: Mostrando seleção aleatória de 3 itens")
		# Mostrar seleção aleatória
		item_selection.show_random_selection(3)
	else:
		print("UIManager: Mostrando itens específicos: %d itens" % items.size())
		# Mostrar itens específicos
		item_selection.show_item_selection(items)

# Função para conectar com player
func connect_to_player(player: Node2D):
	if not player:
		return
	
	# Conectar HUD ao player
	if game_hud:
		game_hud.set_player(player)
	
	# Conectar sinais de level up
	if player.has_signal("level_changed"):
		player.level_changed.connect(_on_player_level_up)
	
	print("UIManager: Conectado ao player %s" % player.name)

func _on_player_level_up(new_level: int):
	print("UIManager: Player subiu para level %d" % new_level)
	
	# Adicionar à fila de level ups
	pending_level_ups.append(new_level)
	
	# Se não há seleção aberta, processar imediatamente
	if not is_item_selection_open:
		process_next_level_up()

func process_next_level_up():
	# Processar o próximo level up da fila
	if pending_level_ups.is_empty():
		print("UIManager: Fila de level ups vazia, nada para processar")
		return
	
	var level = pending_level_ups.pop_front()
	print("UIManager: Processando level up %d (restam %d na fila)" % [level, pending_level_ups.size()])
	
	# Debug: verificar se item_selection existe
	if not item_selection:
		print("UIManager: ERRO - item_selection é null!")
		return
	
	print("UIManager: Chamando show_item_selection...")
	show_item_selection()

# Funções de controle da UI
func set_hud_visible(visible: bool):
	if game_hud:
		game_hud.set_hud_visible(visible)

func set_hud_paused(paused: bool):
	if game_hud:
		game_hud.set_hud_paused(paused)

# Função para debug - forçar seleção de item
func debug_force_item_selection():
	show_item_selection()

# Função para debug - aplicar item específico
func debug_apply_item(item_name: String):
	var item = ItemManager.get_item_by_name(item_name)
	if item:
		ItemManager.apply_item(item)
		create_item_applied_effect(item)
		print("UIManager: Item aplicado via debug - %s" % item_name)
	else:
		print("UIManager: ERRO - Item não encontrado: %s" % item_name)