extends Node
class_name UpgradeManager

# Gerenciador de upgrades para o Rat King

# Sinais
signal upgrade_selected(upgrade_id: String)

# Referência ao player
var rat_king

# Pool de upgrades disponíveis
var upgrade_pool: Dictionary = {}

func _ready():
	initialize_upgrade_pool()

func initialize_upgrade_pool():
	# Upgrades básicos (Nível 1-9)
	upgrade_pool["stats_amount"] = create_upgrade_data(
		"stats_amount",
		"Mais Ratos",
		"Aumenta o número máximo de ratos em 5",
		UpgradeData.Rarity.COMMON,
		1, 9
	)
	
	upgrade_pool["stats_amount_large"] = create_upgrade_data(
		"stats_amount_large",
		"Enxame Crescente",
		"Aumenta o número máximo de ratos em 10",
		UpgradeData.Rarity.UNCOMMON,
		3, 9
	)
	
	upgrade_pool["stats_speed"] = create_upgrade_data(
		"stats_speed",
		"Ratos Ágeis",
		"Aumenta velocidade dos ratos e taxa de spawn",
		UpgradeData.Rarity.COMMON,
		1, 9
	)
	
	upgrade_pool["stats_damage"] = create_upgrade_data(
		"stats_damage",
		"Garras Afiadas",
		"Aumenta o dano dos ratos em 30%",
		UpgradeData.Rarity.COMMON,
		1, 9
	)
	
	upgrade_pool["effect_poison"] = create_upgrade_data(
		"effect_poison",
		"Presas Venenosas",
		"Ratos têm 30% de chance de aplicar veneno",
		UpgradeData.Rarity.RARE,
		2, 9
	)
	
	upgrade_pool["effect_poison_upgrade"] = create_upgrade_data(
		"effect_poison_upgrade",
		"Veneno Aprimorado",
		"Aumenta chance de veneno em 20%",
		UpgradeData.Rarity.UNCOMMON,
		4, 9
	)
	
	upgrade_pool["effect_kamikaze"] = create_upgrade_data(
		"effect_kamikaze",
		"Ratos Suicidas",
		"15% dos ratos explodem ao atacar",
		UpgradeData.Rarity.EPIC,
		3, 9
	)
	
	upgrade_pool["effect_kamikaze_upgrade"] = create_upgrade_data(
		"effect_kamikaze_upgrade",
		"Mais Explosões",
		"Aumenta chance de kamikaze em 10%",
		UpgradeData.Rarity.RARE,
		5, 9
	)
	
	upgrade_pool["stats_burst"] = create_upgrade_data(
		"stats_burst",
		"Ninhada Dupla",
		"Spawna +1 rato por vez",
		UpgradeData.Rarity.UNCOMMON,
		2, 9
	)
	
	upgrade_pool["stats_spawn_rate"] = create_upgrade_data(
		"stats_spawn_rate",
		"Reprodução Rápida",
		"Reduz tempo entre spawns em 20%",
		UpgradeData.Rarity.COMMON,
		1, 9
	)
	
	# Evoluções de Nível 10
	upgrade_pool["evo_swarm"] = create_upgrade_data(
		"evo_swarm",
		"Rota do Enxame",
		"Dobra quantidade máxima, reduz dano individual",
		UpgradeData.Rarity.LEGENDARY,
		10, 10,
		"", true
	)
	
	upgrade_pool["evo_beast"] = create_upgrade_data(
		"evo_beast",
		"Rota das Bestas",
		"Menos ratos, mas muito mais fortes e rápidos",
		UpgradeData.Rarity.LEGENDARY,
		10, 10,
		"", true
	)
	
	# Ultimates de Nível 25
	upgrade_pool["ultimate_plague_lord"] = create_upgrade_data(
		"ultimate_plague_lord",
		"Senhor da Praga",
		"Todos os ratos aplicam veneno, spawn em dobro",
		UpgradeData.Rarity.LEGENDARY,
		25, 25,
		"swarm", false, true
	)
	
	upgrade_pool["ultimate_rat_emperor"] = create_upgrade_data(
		"ultimate_rat_emperor",
		"Imperador dos Ratos",
		"Ratos fazem dano dobrado, mais kamikazes",
		UpgradeData.Rarity.LEGENDARY,
		25, 25,
		"beast", false, true
	)

func create_upgrade_data(
	id: String, 
	name: String, 
	description: String, 
	rarity: UpgradeData.Rarity,
	min_level: int = 1,
	max_level: int = 9,
	required_evolution: String = "",
	is_evolution: bool = false,
	is_ultimate: bool = false
) -> UpgradeData:
	var upgrade = UpgradeData.new()
	upgrade.id = id
	upgrade.name = name
	upgrade.description = description
	upgrade.rarity = rarity
	upgrade.min_level = min_level
	upgrade.max_level = max_level
	upgrade.required_evolution = required_evolution
	upgrade.is_evolution = is_evolution
	upgrade.is_ultimate = is_ultimate
	return upgrade

func get_available_upgrades(player_level: int, evolution_route: String, count: int = 3) -> Array[UpgradeData]:
	var available: Array[UpgradeData] = []
	
	# Filtrar upgrades disponíveis
	for upgrade_id in upgrade_pool:
		var upgrade = upgrade_pool[upgrade_id] as UpgradeData
		if upgrade.is_available(player_level, evolution_route):
			available.append(upgrade)
	
	# Embaralhar e retornar quantidade solicitada
	available.shuffle()
	return available.slice(0, min(count, available.size()))

func apply_upgrade_to_player(upgrade_id: String, player):
	if player:
		player.apply_upgrade(upgrade_id)
		upgrade_selected.emit(upgrade_id)

# Função para obter upgrade por ID
func get_upgrade_by_id(upgrade_id: String) -> UpgradeData:
	return upgrade_pool.get(upgrade_id, null)

# Função para verificar se um upgrade específico está disponível
func is_upgrade_available(upgrade_id: String, player_level: int, evolution_route: String) -> bool:
	var upgrade = get_upgrade_by_id(upgrade_id)
	if not upgrade:
		return false
	return upgrade.is_available(player_level, evolution_route)