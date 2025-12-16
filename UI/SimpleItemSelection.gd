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
	# Criar 3 botões de teste
	for i in range(3):
		var button = Button.new()
		button.text = "Item %d" % (i + 1)
		button.size = Vector2(200, 50)
		button.position = Vector2(100 + i * 220, 100)
		
		# Conectar sinal
		button.pressed.connect(func(): select_test_item(i))
		
		add_child(button)

func select_test_item(index: int):
	print("SimpleItemSelection: Item %d selecionado" % index)
	
	# Criar item de teste
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