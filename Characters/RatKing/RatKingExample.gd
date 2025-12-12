extends Node
# Exemplo de como usar o sistema do Rat King

# Este script demonstra como integrar o Rat King com o sistema de jogo

var rat_king
var upgrade_manager: UpgradeManager

func _ready():
	setup_rat_king_system()

func setup_rat_king_system():
	# Instanciar o Rat King
	var rat_king_scene = load("res://Characters/RatKing/RatKing.tscn")
	rat_king = rat_king_scene.instantiate()
	add_child(rat_king)
	
	# Configurar posição inicial
	rat_king.global_position = Vector2(400, 300)
	
	# Instanciar o gerenciador de upgrades
	upgrade_manager = UpgradeManager.new()
	add_child(upgrade_manager)
	
	# Conectar sinais
	rat_king.level_changed.connect(_on_rat_king_level_up)
	rat_king.evolution_available.connect(_on_evolution_available)
	upgrade_manager.upgrade_selected.connect(_on_upgrade_selected)
	
	# Simular ganho de experiência para teste
	simulate_experience_gain()

func _on_rat_king_level_up(new_level: int):
	print("Rat King subiu para o nível: ", new_level)
	
	# Oferecer upgrades (exceto em níveis especiais)
	if new_level != 10 and new_level != 25:
		offer_random_upgrades()

func _on_evolution_available(evolution_type: String):
	print("Evolução disponível: ", evolution_type)
	
	match evolution_type:
		"route_selection":
			offer_evolution_choice()
		"ultimate":
			offer_ultimate_choice()

func offer_random_upgrades():
	var available_upgrades = upgrade_manager.get_available_upgrades(
		rat_king.current_level, 
		rat_king.evolution_route, 
		3
	)
	
	print("Upgrades disponíveis:")
	for i in range(available_upgrades.size()):
		var upgrade = available_upgrades[i]
		print(str(i + 1) + ". " + upgrade.name + " - " + upgrade.description)
	
	# Simular seleção aleatória para exemplo
	if available_upgrades.size() > 0:
		var selected_upgrade = available_upgrades[randi() % available_upgrades.size()]
		upgrade_manager.apply_upgrade_to_player(selected_upgrade.id, rat_king)

func offer_evolution_choice():
	print("Escolha sua evolução:")
	print("1. Rota do Enxame - Muitos ratos fracos")
	print("2. Rota das Bestas - Poucos ratos fortes")
	
	# Simular escolha aleatória para exemplo
	var choice = randi() % 2
	if choice == 0:
		upgrade_manager.apply_upgrade_to_player("evo_swarm", rat_king)
	else:
		upgrade_manager.apply_upgrade_to_player("evo_beast", rat_king)

func offer_ultimate_choice():
	var ultimate_id = ""
	
	match rat_king.evolution_route:
		"swarm":
			ultimate_id = "ultimate_plague_lord"
			print("Ultimate disponível: Senhor da Praga")
		"beast":
			ultimate_id = "ultimate_rat_emperor"
			print("Ultimate disponível: Imperador dos Ratos")
	
	if ultimate_id != "":
		upgrade_manager.apply_upgrade_to_player(ultimate_id, rat_king)

func _on_upgrade_selected(upgrade_id: String):
	print("Upgrade aplicado: ", upgrade_id)
	
	# Atualizar UI ou outros sistemas conforme necessário
	update_ui()

func update_ui():
	var info = rat_king.get_player_info()
	print("Status do Rat King:")
	print("  Nível: ", info.level)
	print("  Vida: ", info.health, "/", info.max_health)
	print("  Experiência: ", info.experience, "/", info.exp_to_next)
	print("  Ratos Ativos: ", info.active_minions, "/", info.max_minions)
	print("  Rota de Evolução: ", info.evolution_route)

func simulate_experience_gain():
	# Simular ganho de experiência ao longo do tempo para teste
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.timeout.connect(_give_experience)
	add_child(timer)
	timer.start()

func _give_experience():
	rat_king.gain_experience(50)
	print("Experiência ganha! Total: ", rat_king.current_experience)

# Função para configurar input actions (adicionar no Input Map)
func setup_input_actions():
	# Estas ações devem ser configuradas no Input Map do projeto:
	# move_up (W, Seta para cima)
	# move_down (S, Seta para baixo)  
	# move_left (A, Seta para esquerda)
	# move_right (D, Seta para direita)
	pass