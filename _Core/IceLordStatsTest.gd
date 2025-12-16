extends Node
class_name IceLordStatsTest

# Script de teste para verificar integração do Ice Lord com stats globais

func _ready():
	print("=== TESTE: Ice Lord + Stats Globais ===")
	
	# Aguardar inicialização
	await get_tree().process_frame
	
	# Testar aplicação de stats no Ice Lord
	test_ice_lord_stats()

func test_ice_lord_stats():
	print("\n--- TESTE: Aplicação de Stats no Ice Lord ---")
	
	# Simular alguns upgrades de stats
	print("Aplicando upgrades de teste...")
	
	# Aplicar Bota de Hermes (velocidade)
	GameManager.apply_stat_upgrade("move_speed", 0.10)
	
	# Aplicar Café Expresso (cooldown)
	GameManager.apply_stat_upgrade("cooldown_reduction", 0.10)
	
	# Aplicar Coração de Dragão (vida)
	GameManager.apply_stat_upgrade("max_health_mult", 0.20)
	
	# Aplicar Óculos de Precisão (velocidade de projétil)
	GameManager.apply_stat_upgrade("projectile_speed", 0.20)
	
	# Aplicar Manopla de Titã (knockback)
	GameManager.apply_stat_upgrade("knockback", 1.0)
	
	print("\nStats globais atuais:")
	for stat_key in GameManager.global_stats.keys():
		var value = GameManager.get_stat(stat_key)
		print("  %s: %.2f" % [stat_key, value])
	
	print("\n✅ Teste concluído! Ice Lord deve reagir aos stats em tempo real.")

func test_item_application():
	print("\n--- TESTE: Aplicação de Itens no Ice Lord ---")
	
	# Aplicar alguns itens de teste
	var items_to_test = [
		"Bota de Hermes",
		"Café Expresso", 
		"Coração de Dragão",
		"Óculos de Precisão"
	]
	
	for item_name in items_to_test:
		var item = ItemManager.get_item_by_name(item_name)
		if item:
			print("Aplicando: %s" % item_name)
			ItemManager.apply_item(item)
			await get_tree().process_frame  # Aguardar aplicação
	
	print("\n✅ Itens aplicados! Verificar se Ice Lord reagiu às mudanças.")

# Função para testar no console
func apply_random_items():
	print("\n=== APLICANDO ITENS ALEATÓRIOS ===")
	
	var random_items = ItemManager.get_random_items(5)
	for item in random_items:
		print("Aplicando: %s" % item.display_name)
		ItemManager.apply_item(item)
		await get_tree().process_frame
	
	print("\nStats finais:")
	for stat_key in GameManager.global_stats.keys():
		var value = GameManager.get_stat(stat_key)
		print("  %s: %.2f" % [stat_key, value])