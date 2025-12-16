extends Control
class_name SimpleItemSelection

# Versão simplificada da UI de seleção de itens para teste

signal item_selected(item: ItemData)

func _ready():
	print("SimpleItemSelection: UI inicializada")
	hide()  # Inicialmente invisível

func show_selection():
	print("SimpleItemSelection: Mostrando seleção")
	show()
	
	# Criar botões simples para teste
	create_test_buttons()

func create_test_buttons():
	# Obter itens reais do ItemManager
	var items = ItemManager.get_random_items(3)
	
	# Criar botões para itens reais
	for i in range(items.size()):
		var item = items[i]
		var button = Button.new()
		button.text = "%d. %s\n+%.0f%% %s" % [i + 1, item.display_name, item.value * 100, item.stat_key]
		button.custom_minimum_size = Vector2(250, 80)
		button.position = Vector2(50 + i * 270, 150)
		
		# Conectar sinal com item real
		button.pressed.connect(func(): select_real_item(item))
		
		add_child(button)
	
	print("SimpleItemSelection: %d botões de itens criados" % items.size())

func select_real_item(item: ItemData):
	print("SimpleItemSelection: Item selecionado - %s" % item.display_name)
	
	# Aplicar item
	ItemManager.apply_item(item)
	
	# Emitir sinal
	item_selected.emit(item)
	
	# Fechar
	hide()

func select_test_item(index: int):
	print("SimpleItemSelection: Item %d selecionado (fallback)" % index)
	
	# Criar item de teste como fallback
	var test_item = ItemData.new()
	test_item.display_name = "Item de Teste %d" % index
	test_item.stat_key = "move_speed"
	test_item.value = 0.1
	
	# Aplicar item
	ItemManager.apply_item(test_item)
	
	# Emitir sinal
	item_selected.emit(test_item)
	
	# Fechar
	hide()

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		hide()