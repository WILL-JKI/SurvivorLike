extends Node
class_name ItemSystemTest

# Script de teste para demonstrar o sistema de itens passivos

func _ready():
	print("=== TESTE DO SISTEMA DE ITENS ===")
	
	# Aguardar inicialização dos singletons
	await get_tree().process_frame
	
	# Testar inicialização dos itens
	test_item_initialization()
	
	# Testar aplicação de itens
	test_item_application()
	
	# Testar stats globais
	test_global_stats()

func test_item_initialization():
	print("\n--- TESTE: Inicialização dos Itens ---")
	
	if ItemManager.all_items.size() == 10:
		print("✅ 10 itens inicializados corretamente")
		ItemManager.debug_list_all_items()
	else:
		print("❌ ERRO: Esperado 10 itens, encontrado %d" % ItemManager.all_items.size())

func test_item_application():
	print("\n--- TESTE: Aplicação de Itens ---")
	
	# Testar Sanduíche de Jake (area_size)
	var jake_sandwich = ItemManager.get_item_by_name("Sanduíche de Jake")
	if jake_sandwich:
		print("Aplicando: %s" % jake_sandwich.display_name)
		ItemManager.apply_item(jake_sandwich)
		
		var area_size = GameManager.get_stat("area_size")
		if area_size == 1.10:
			print("✅ Area size aplicado corretamente: %.2f" % area_size)
		else:
			print("❌ ERRO: Area size esperado 1.10, obtido %.2f" % area_size)
	
	# Testar Café Expresso (cooldown_reduction)
	var espresso = ItemManager.get_item_by_name("Café Expresso")
	if espresso:
		print("Aplicando: %s" % espresso.display_name)
		ItemManager.apply_item(espresso)
		
		var cooldown_reduction = GameManager.get_stat("cooldown_reduction")
		if cooldown_reduction == 0.10:
			print("✅ Cooldown reduction aplicado corretamente: %.2f" % cooldown_reduction)
		else:
			print("❌ ERRO: Cooldown reduction esperado 0.10, obtido %.2f" % cooldown_reduction)

func test_global_stats():
	print("\n--- TESTE: Stats Globais ---")
	
	print("Stats atuais:")
	for stat_key in GameManager.global_stats.keys():
		var value = GameManager.get_stat(stat_key)
		print("  %s: %.2f" % [stat_key, value])
	
	# Testar aplicação manual de stat
	print("\nTestando aplicação manual de stat...")
	GameManager.apply_stat_upgrade("move_speed", 0.25)
	
	var move_speed = GameManager.get_stat("move_speed")
	if move_speed == 1.25:
		print("✅ Move speed aplicado corretamente: %.2f" % move_speed)
	else:
		print("❌ ERRO: Move speed esperado 1.25, obtido %.2f" % move_speed)

func test_random_items():
	print("\n--- TESTE: Itens Aleatórios ---")
	
	var random_items = ItemManager.get_random_items(3)
	print("3 itens aleatórios selecionados:")
	for item in random_items:
		print("  - %s (%s: +%.2f)" % [item.display_name, item.stat_key, item.value])

# Função para testar no console
func apply_test_items():
	print("\n=== APLICANDO ITENS DE TESTE ===")
	
	# Aplicar alguns itens para teste
	var items_to_test = [
		"Sanduíche de Jake",
		"Bota de Hermes", 
		"Café Expresso",
		"Coração de Dragão"
	]
	
	for item_name in items_to_test:
		var item = ItemManager.get_item_by_name(item_name)
		if item:
			ItemManager.apply_item(item)
			print("Aplicado: %s" % item_name)
	
	print("\nStats finais:")
	for stat_key in GameManager.global_stats.keys():
		var value = GameManager.get_stat(stat_key)
		print("  %s: %.2f" % [stat_key, value])