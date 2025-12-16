extends Node
class_name UISystemTest

# Script de teste para o sistema completo de UI

func _ready():
	print("=== TESTE: Sistema de UI Completo ===")
	
	# Aguardar inicialização
	await get_tree().process_frame
	
	# Testar componentes da UI
	test_ui_components()

func test_ui_components():
	print("\n--- TESTE: Componentes da UI ---")
	
	# Verificar se ItemManager está funcionando
	if ItemManager.all_items.size() == 10:
		print("✅ ItemManager: 10 itens carregados")
	else:
		print("❌ ItemManager: Esperado 10 itens, encontrado %d" % ItemManager.all_items.size())
	
	# Verificar GameManager
	if GameManager.global_stats.size() == 10:
		print("✅ GameManager: 10 stats globais configurados")
	else:
		print("❌ GameManager: Stats globais incorretos")
	
	# Testar criação de UI
	test_ui_creation()

func test_ui_creation():
	print("\n--- TESTE: Criação de UI ---")
	
	# Testar GameHUD
	var hud_scene = load("res://UI/GameHUD.tscn")
	if hud_scene:
		var hud = hud_scene.instantiate()
		if hud:
			print("✅ GameHUD: Cena carregada e instanciada")
			hud.queue_free()
		else:
			print("❌ GameHUD: Falha ao instanciar")
	else:
		print("❌ GameHUD: Falha ao carregar cena")
	
	# Testar ItemSelectionUI
	var item_ui_scene = load("res://UI/ItemSelectionUI.tscn")
	if item_ui_scene:
		var item_ui = item_ui_scene.instantiate()
		if item_ui:
			print("✅ ItemSelectionUI: Cena carregada e instanciada")
			item_ui.queue_free()
		else:
			print("❌ ItemSelectionUI: Falha ao instanciar")
	else:
		print("❌ ItemSelectionUI: Falha ao carregar cena")
	
	# Testar UIManager
	var ui_manager_scene = load("res://UI/UIManager.tscn")
	if ui_manager_scene:
		var ui_manager = ui_manager_scene.instantiate()
		if ui_manager:
			print("✅ UIManager: Cena carregada e instanciada")
			ui_manager.queue_free()
		else:
			print("❌ UIManager: Falha ao instanciar")
	else:
		print("❌ UIManager: Falha ao carregar cena")

func test_item_selection_flow():
	print("\n--- TESTE: Fluxo de Seleção de Itens ---")
	
	# Simular seleção de itens
	var random_items = ItemManager.get_random_items(3)
	if random_items.size() == 3:
		print("✅ Seleção aleatória: 3 itens obtidos")
		
		for i in range(random_items.size()):
			var item = random_items[i]
			print("  %d. %s (%s: +%.2f)" % [i+1, item.display_name, item.stat_key, item.value])
	else:
		print("❌ Seleção aleatória: Esperado 3 itens, obtido %d" % random_items.size())

func test_stat_integration():
	print("\n--- TESTE: Integração de Stats ---")
	
	# Resetar stats
	GameManager.reset_global_stats()
	
	# Aplicar alguns itens
	var test_items = [
		"Bota de Hermes",      # move_speed
		"Café Expresso",       # cooldown_reduction
		"Sanduíche de Jake"    # area_size
	]
	
	for item_name in test_items:
		var item = ItemManager.get_item_by_name(item_name)
		if item:
			ItemManager.apply_item(item)
			print("✅ Item aplicado: %s" % item_name)
		else:
			print("❌ Item não encontrado: %s" % item_name)
	
	# Verificar stats finais
	print("\nStats após aplicação:")
	print("  Move Speed: %.2f" % GameManager.get_stat("move_speed"))
	print("  Cooldown Reduction: %.2f" % GameManager.get_stat("cooldown_reduction"))
	print("  Area Size: %.2f" % GameManager.get_stat("area_size"))

# Função para testar no console
func simulate_level_up_flow():
	print("\n=== SIMULAÇÃO: Fluxo de Level Up ===")
	
	# 1. Player sobe de level
	print("1. Player subiu de level!")
	
	# 2. Obter itens aleatórios
	var items = ItemManager.get_random_items(3)
	print("2. Itens disponíveis:")
	for i in range(items.size()):
		var item = items[i]
		print("   %d. %s - %s" % [i+1, item.display_name, item.description])
	
	# 3. Simular seleção (primeiro item)
	if items.size() > 0:
		var selected_item = items[0]
		print("3. Item selecionado: %s" % selected_item.display_name)
		
		# 4. Aplicar item
		ItemManager.apply_item(selected_item)
		print("4. Item aplicado! Novo valor de %s: %.2f" % [selected_item.stat_key, GameManager.get_stat(selected_item.stat_key)])
	
	print("✅ Fluxo de level up simulado com sucesso!")

func debug_ui_system():
	print("\n=== DEBUG: Sistema de UI ===")
	
	print("Cenas disponíveis:")
	var ui_scenes = [
		"res://UI/GameHUD.tscn",
		"res://UI/ItemSelectionUI.tscn", 
		"res://UI/UIManager.tscn"
	]
	
	for scene_path in ui_scenes:
		if FileAccess.file_exists(scene_path):
			print("  ✅ %s" % scene_path)
		else:
			print("  ❌ %s (não encontrado)" % scene_path)
	
	print("\nItens disponíveis: %d" % ItemManager.all_items.size())
	print("Stats globais: %d" % GameManager.global_stats.size())
	
	print("\n✅ Debug do sistema de UI concluído!")