extends Node

# Gerenciador de itens passivos do jogo
# Cria e gerencia todos os itens disponíveis
# Singleton autoload - não usar class_name

# Lista de todos os itens disponíveis
var all_items: Array[ItemData] = []

# Função para inicializar todos os itens
func initialize_items():
	all_items.clear()
	
	# 1. Sanduíche de Jake - Área
	var jake_sandwich = ItemData.new()
	jake_sandwich.display_name = "Sanduíche de Jake"
	jake_sandwich.stat_key = "area_size"
	jake_sandwich.value = 0.10
	jake_sandwich.description = "Um sanduíche mágico que expande suas habilidades.\n+{value}% Tamanho de Área"
	jake_sandwich.icon = load("res://icon.svg")  # Placeholder
	all_items.append(jake_sandwich)
	
	# 2. Trevo de 7 Folhas - Sorte
	var lucky_clover = ItemData.new()
	lucky_clover.display_name = "Trevo de 7 Folhas"
	lucky_clover.stat_key = "luck"
	lucky_clover.value = 0.07
	lucky_clover.description = "Um trevo extremamente raro que traz boa sorte.\n+{value}% Sorte"
	lucky_clover.icon = load("res://icon.svg")  # Placeholder
	all_items.append(lucky_clover)
	
	# 3. Café Expresso - Cooldown
	var espresso_coffee = ItemData.new()
	espresso_coffee.display_name = "Café Expresso"
	espresso_coffee.stat_key = "cooldown_reduction"
	espresso_coffee.value = 0.10
	espresso_coffee.description = "Cafeína pura que acelera suas reações.\n-{value}% Tempo de Recarga"
	espresso_coffee.icon = load("res://icon.svg")  # Placeholder
	all_items.append(espresso_coffee)
	
	# 4. Bota de Hermes - Velocidade
	var hermes_boots = ItemData.new()
	hermes_boots.display_name = "Bota de Hermes"
	hermes_boots.stat_key = "move_speed"
	hermes_boots.value = 0.10
	hermes_boots.description = "Botas aladas que aumentam sua agilidade.\n+{value}% Velocidade de Movimento"
	hermes_boots.icon = load("res://icon.svg")  # Placeholder
	all_items.append(hermes_boots)
	
	# 5. Óculos de Precisão - Velocidade de Projétil
	var precision_glasses = ItemData.new()
	precision_glasses.display_name = "Óculos de Precisão"
	precision_glasses.stat_key = "projectile_speed"
	precision_glasses.value = 0.20
	precision_glasses.description = "Lentes especiais que melhoram mira e velocidade.\n+{value}% Velocidade de Projétil"
	precision_glasses.icon = load("res://icon.svg")  # Placeholder
	all_items.append(precision_glasses)
	
	# 6. Manopla de Titã - Knockback
	var titan_gauntlet = ItemData.new()
	titan_gauntlet.display_name = "Manopla de Titã"
	titan_gauntlet.stat_key = "knockback"
	titan_gauntlet.value = 1.0
	titan_gauntlet.description = "Luvas forjadas pelos titãs, dobram sua força.\n+100% Força de Knockback"
	titan_gauntlet.icon = load("res://icon.svg")  # Placeholder
	all_items.append(titan_gauntlet)
	
	# 7. Imã de Sucata - Alcance de Coleta
	var scrap_magnet = ItemData.new()
	scrap_magnet.display_name = "Imã de Sucata"
	scrap_magnet.stat_key = "pickup_range"
	scrap_magnet.value = 0.30
	scrap_magnet.description = "Imã poderoso que atrai itens de longe.\n+{value}% Alcance de Coleta"
	scrap_magnet.icon = load("res://icon.svg")  # Placeholder
	all_items.append(scrap_magnet)
	
	# 8. Coração de Dragão - Vida Máxima
	var dragon_heart = ItemData.new()
	dragon_heart.display_name = "Coração de Dragão"
	dragon_heart.stat_key = "max_health_mult"
	dragon_heart.value = 0.20
	dragon_heart.description = "Coração de um dragão ancestral, aumenta sua vitalidade.\n+{value}% Vida Máxima"
	dragon_heart.icon = load("res://icon.svg")  # Placeholder
	all_items.append(dragon_heart)
	
	# 9. Anel de Espinhos - Dano de Retaliação
	var thorn_ring = ItemData.new()
	thorn_ring.display_name = "Anel de Espinhos"
	thorn_ring.stat_key = "thorns_damage"
	thorn_ring.value = 0.10
	thorn_ring.description = "Anel amaldiçoado que machuca quem te ataca.\n+{value}% Dano de Retaliação"
	thorn_ring.icon = load("res://icon.svg")  # Placeholder
	all_items.append(thorn_ring)
	
	# 10. Pergaminho Proibido - Ganho de XP
	var forbidden_scroll = ItemData.new()
	forbidden_scroll.display_name = "Pergaminho Proibido"
	forbidden_scroll.stat_key = "xp_gain"
	forbidden_scroll.value = 0.10
	forbidden_scroll.description = "Conhecimento sombrio que acelera seu aprendizado.\n+{value}% Ganho de XP"
	forbidden_scroll.icon = load("res://icon.svg")  # Placeholder
	all_items.append(forbidden_scroll)
	
	print("ItemManager: %d itens inicializados" % all_items.size())

# Função para obter item por nome
func get_item_by_name(item_name: String) -> ItemData:
	for item in all_items:
		if item.display_name == item_name:
			return item
	return null

# Função para obter itens por stat_key
func get_items_by_stat(stat_key: String) -> Array[ItemData]:
	var items: Array[ItemData] = []
	for item in all_items:
		if item.stat_key == stat_key:
			items.append(item)
	return items

# Função para obter itens aleatórios
func get_random_items(count: int) -> Array[ItemData]:
	print("ItemManager: get_random_items chamado com count: %d" % count)
	print("ItemManager: all_items.size(): %d" % all_items.size())
	
	if all_items.is_empty():
		print("ItemManager: all_items vazio, inicializando...")
		initialize_items()
		print("ItemManager: Após inicialização, all_items.size(): %d" % all_items.size())
	
	var available_items = all_items.duplicate()
	var selected_items: Array[ItemData] = []
	
	for i in range(min(count, available_items.size())):
		var random_index = randi() % available_items.size()
		selected_items.append(available_items[random_index])
		available_items.remove_at(random_index)
	
	print("ItemManager: Retornando %d itens selecionados" % selected_items.size())
	return selected_items

# Função para aplicar item
func apply_item(item: ItemData):
	if item and item.is_valid():
		item.apply_item_effect()
	else:
		print("ItemManager: ERRO - Item inválido ou nulo")

# Função para debug - listar todos os itens
func debug_list_all_items():
	print("ItemManager: === LISTA DE ITENS ===")
	for i in range(all_items.size()):
		var item = all_items[i]
		print("%d. %s (%s: +%.2f)" % [i+1, item.display_name, item.stat_key, item.value])
	print("ItemManager: === FIM DA LISTA ===")

# Inicializar itens automaticamente quando o script é carregado
func _ready():
	initialize_items()