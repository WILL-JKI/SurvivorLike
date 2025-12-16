extends Control
class_name ItemSelectionUI

# UI de seleção de itens para level up

signal item_selected(item: ItemData)
signal selection_cancelled()

# Referências dos nós
@onready var background: ColorRect = $Background
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var items_container: HBoxContainer = $VBoxContainer/ItemsContainer
@onready var skip_button: Button = $VBoxContainer/SkipButton

# Itens disponíveis para seleção
var available_items: Array[ItemData] = []

func _ready():
	# Configurar UI
	setup_ui()
	
	# Configurar template (agora é criação direta)
	create_item_button_template()
	
	# Inicialmente invisível
	hide()
	
	print("ItemSelectionUI: UI de seleção inicializada")

func setup_ui():
	# Configurar background
	if background:
		background.color = Color(0, 0, 0, 0.8)  # Semi-transparente
	
	# Configurar título
	if title_label:
		title_label.text = "LEVEL UP! Escolha um item:"
	
	# Configurar botão skip
	if skip_button:
		skip_button.text = "Pular (ESC)"
		skip_button.pressed.connect(_on_skip_pressed)

func create_item_button_template():
	# Não usar PackedScene - criar botões diretamente
	print("ItemSelectionUI: Template de botão configurado (criação direta)")

func show_item_selection(items: Array[ItemData]):
	print("ItemSelectionUI: show_item_selection chamado com %d itens" % items.size())
	
	available_items = items
	
	# Limpar container anterior
	clear_items_container()
	
	# Criar botões para cada item
	for i in range(items.size()):
		var item = items[i]
		print("ItemSelectionUI: Criando botão para item %d: %s" % [i, item.display_name])
		create_item_button(item, i)
	
	print("ItemSelectionUI: Mostrando UI...")
	# Mostrar UI
	show()
	
	print("ItemSelectionUI: Pausando jogo...")
	# Pausar o jogo
	get_tree().paused = true
	
	print("ItemSelectionUI: UI mostrada com %d itens para seleção" % items.size())

func clear_items_container():
	if not items_container:
		return
	
	# Remover todos os botões existentes
	for child in items_container.get_children():
		child.queue_free()

func create_item_button(item: ItemData, index: int):
	if not items_container:
		print("ItemSelectionUI: ERRO - Items container não encontrado")
		return
	
	# Criar botão diretamente
	var button = Button.new()
	button.name = "ItemButton_%d" % index
	button.custom_minimum_size = Vector2(200, 120)
	
	# Criar container vertical
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.anchors_preset = Control.PRESET_FULL_RECT
	vbox.add_theme_constant_override("separation", 5)
	button.add_child(vbox)
	
	# Criar componentes
	create_button_components(vbox, item)
	
	# Configurar botão
	setup_item_button(button, item, index)
	
	# Adicionar ao container
	items_container.add_child(button)

func create_button_components(vbox: VBoxContainer, item: ItemData):
	# Ícone do item
	var icon = TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = Vector2(64, 64)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(icon)
	
	# Nome do item
	var name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.text = "Item Name"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_label)
	
	# Descrição do item
	var desc_label = Label.new()
	desc_label.name = "DescLabel"
	desc_label.text = "Item Description"
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size.y = 40
	vbox.add_child(desc_label)

func setup_item_button(button: Button, item: ItemData, index: int):
	# Encontrar componentes do botão com verificação de segurança
	var vbox = button.get_node_or_null("VBoxContainer")
	if not vbox:
		print("ItemSelectionUI: ERRO - VBoxContainer não encontrado no botão")
		return
	
	var icon = vbox.get_node_or_null("Icon") as TextureRect
	var name_label = vbox.get_node_or_null("NameLabel") as Label
	var desc_label = vbox.get_node_or_null("DescLabel") as Label
	
	# Configurar ícone
	if icon and item.icon:
		icon.texture = item.icon
	
	# Configurar nome
	if name_label:
		name_label.text = item.display_name
	
	# Configurar descrição (substituir placeholder)
	if desc_label:
		var description = item.description
		if "{value}" in description:
			var value_text = ""
			if item.stat_key == "cooldown_reduction":
				value_text = str(int(item.value * 100))  # Porcentagem
			else:
				value_text = str(int(item.value * 100))  # Porcentagem para a maioria
			description = description.replace("{value}", value_text)
		desc_label.text = description
	
	# Conectar sinal
	button.pressed.connect(func(): _on_item_selected(item, index))
	
	# Configurar tecla de atalho (1, 2, 3...)
	if index < 9:
		var shortcut = Shortcut.new()
		var input_event = InputEventKey.new()
		input_event.keycode = KEY_1 + index
		shortcut.events = [input_event]
		button.shortcut = shortcut
	
	# Efeito hover
	button.mouse_entered.connect(func(): _on_item_hover(button, true))
	button.mouse_exited.connect(func(): _on_item_hover(button, false))

func _on_item_selected(item: ItemData, index: int):
	print("ItemSelectionUI: Item selecionado - %s" % item.display_name)
	
	# Aplicar item
	ItemManager.apply_item(item)
	
	# Emitir sinal
	item_selected.emit(item)
	
	# Fechar UI
	hide_selection()

func _on_skip_pressed():
	print("ItemSelectionUI: Seleção pulada")
	
	# Emitir sinal
	selection_cancelled.emit()
	
	# Fechar UI
	hide_selection()

func _on_item_hover(button: Button, is_hovering: bool):
	# Efeito visual de hover
	if is_hovering:
		button.modulate = Color(1.2, 1.2, 1.2)
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)
	else:
		button.modulate = Color.WHITE
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)

func hide_selection():
	# Esconder UI
	hide()
	
	# Despausar o jogo
	get_tree().paused = false
	
	print("ItemSelectionUI: UI de seleção fechada")

func _input(event):
	if not visible:
		return
	
	# ESC para pular
	if event.is_action_pressed("ui_cancel"):
		_on_skip_pressed()
		get_viewport().set_input_as_handled()

# Função para mostrar seleção aleatória
func show_random_selection(count: int = 3):
	print("ItemSelectionUI: show_random_selection chamado com count: %d" % count)
	
	if not ItemManager:
		print("ItemSelectionUI: ERRO - ItemManager é null!")
		return
	
	var random_items = ItemManager.get_random_items(count)
	print("ItemSelectionUI: ItemManager retornou %d itens" % random_items.size())
	
	if random_items.is_empty():
		print("ItemSelectionUI: ERRO - Nenhum item retornado pelo ItemManager!")
		return
	
	show_item_selection(random_items)

# Função para mostrar itens específicos
func show_specific_items(item_names: Array[String]):
	var items: Array[ItemData] = []
	
	for item_name in item_names:
		var item = ItemManager.get_item_by_name(item_name)
		if item:
			items.append(item)
	
	if items.size() > 0:
		show_item_selection(items)
	else:
		print("ItemSelectionUI: ERRO - Nenhum item válido encontrado")

# Função para debug - mostrar todos os itens
func debug_show_all_items():
	if ItemManager.all_items.size() > 0:
		show_item_selection(ItemManager.all_items)
	else:
		print("ItemSelectionUI: ERRO - Nenhum item disponível")