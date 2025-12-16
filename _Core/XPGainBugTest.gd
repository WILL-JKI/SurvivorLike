extends Node
class_name XPGainBugTest

# Script para debugar o bug do XP gain afetando HP

func _ready():
	print("=== DEBUG: XP Gain Bug Test ===")
	
	# Aguardar inicialização
	await get_tree().process_frame
	
	# Testar aplicação do item de XP
	test_xp_gain_item()

func test_xp_gain_item():
	print("\n--- TESTE: Item de XP Gain ---")
	
	# Obter estado inicial
	print_current_stats("ANTES da aplicação")
	
	# Obter item de XP
	var xp_item = ItemManager.get_item_by_name("Pergaminho Proibido")
	if not xp_item:
		print("❌ ERRO: Item 'Pergaminho Proibido' não encontrado")
		return
	
	print("Item encontrado: %s" % xp_item.display_name)
	print("  Stat Key: %s" % xp_item.stat_key)
	print("  Value: %.3f" % xp_item.value)
	print("  Description: %s" % xp_item.description)
	
	# Aplicar item
	print("\nAplicando item...")
	ItemManager.apply_item(xp_item)
	
	# Aguardar um frame para propagação
	await get_tree().process_frame
	
	# Verificar estado após aplicação
	print_current_stats("DEPOIS da aplicação")
	
	# Verificar se há player na cena
	check_player_health()

func print_current_stats(moment: String):
	print("\n=== STATS %s ===" % moment)
	
	# Stats globais
	print("Stats Globais:")
	for stat_key in GameManager.global_stats.keys():
		var value = GameManager.get_stat(stat_key)
		print("  %s: %.3f" % [stat_key, value])
	
	# Stats de sessão
	print("Stats de Sessão:")
	for stat_key in GameManager.session_stats.keys():
		var value = GameManager.session_stats[stat_key]
		print("  %s: %s" % [stat_key, str(value)])

func check_player_health():
	print("\n--- VERIFICAÇÃO: Vida do Player ---")
	
	# Procurar player na cena
	var players = get_tree().get_nodes_in_group("players")
	if players.size() == 0:
		print("Nenhum player encontrado na cena")
		return
	
	var player = players[0]
	print("Player encontrado: %s" % player.name)
	
	# Verificar propriedades de vida
	if player.has_method("get"):
		var current_health = player.get("current_health")
		var max_health = player.get("max_health")
		var base_max_health = player.get("base_max_health")
		
		print("  Vida Atual: %s" % str(current_health))
		print("  Vida Máxima: %s" % str(max_health))
		print("  Vida Base: %s" % str(base_max_health))
		
		# Verificar se há valores absurdos
		if current_health != null and current_health > 1000:
			print("⚠️ ALERTA: Vida atual muito alta! %.1f" % current_health)
		
		if max_health != null and max_health > 1000:
			print("⚠️ ALERTA: Vida máxima muito alta! %.1f" % max_health)

func test_multiple_applications():
	print("\n--- TESTE: Múltiplas Aplicações ---")
	
	# Aplicar o mesmo item várias vezes para ver o que acontece
	var xp_item = ItemManager.get_item_by_name("Pergaminho Proibido")
	if not xp_item:
		return
	
	for i in range(3):
		print("\nAplicação %d:" % (i + 1))
		print_current_stats("Antes aplicação %d" % (i + 1))
		
		ItemManager.apply_item(xp_item)
		await get_tree().process_frame
		
		print_current_stats("Depois aplicação %d" % (i + 1))
		check_player_health()

# Função para debug manual
func debug_xp_item():
	print("\n=== DEBUG MANUAL: Item de XP ===")
	
	# Verificar se o item existe
	var xp_item = ItemManager.get_item_by_name("Pergaminho Proibido")
	if xp_item:
		print("✅ Item encontrado")
		print("   Nome: %s" % xp_item.display_name)
		print("   Stat: %s" % xp_item.stat_key)
		print("   Valor: %.3f" % xp_item.value)
		
		# Verificar se o stat_key existe
		if GameManager.global_stats.has(xp_item.stat_key):
			print("✅ Stat key válida")
			var current_value = GameManager.get_stat(xp_item.stat_key)
			print("   Valor atual: %.3f" % current_value)
		else:
			print("❌ Stat key inválida!")
	else:
		print("❌ Item não encontrado!")

func monitor_stat_changes():
	print("\n--- MONITOR: Mudanças de Stats ---")
	
	# Conectar ao sinal de mudança de stats
	if GameManager.has_signal("stat_changed"):
		GameManager.stat_changed.connect(_on_stat_changed_debug)
		print("✅ Conectado ao sinal de mudança de stats")
	else:
		print("❌ Sinal stat_changed não encontrado")

func _on_stat_changed_debug(stat_key: String, new_value: float):
	print("🔄 STAT CHANGED: %s = %.3f" % [stat_key, new_value])
	
	# Se for mudança de XP, verificar se afeta outras coisas
	if stat_key == "xp_gain":
		print("   ⚠️ XP Gain mudou! Verificando efeitos colaterais...")
		await get_tree().process_frame
		check_player_health()