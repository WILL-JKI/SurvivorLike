extends Node
class_name BerserkerUpgrades

# Sistema de upgrades para o Berserker
# Define todos os upgrades disponíveis e suas progressões

# Estrutura de dados dos upgrades
static var upgrade_data = {
	# Upgrades de Stats Base (Levels 1-9)
	"stats_aoe": {
		"name": "Vórtice Expandido",
		"description": "Aumenta a área da arma em 20%",
		"icon": "res://icon.svg",
		"max_level": 5,
		"values": [0.2, 0.2, 0.2, 0.2, 0.2],
		"available_levels": [1, 2, 3, 4, 5, 6, 7, 8, 9]
	},
	
	"stats_damage": {
		"name": "Força Bruta",
		"description": "Aumenta o dano base da arma",
		"icon": "res://icon.svg",
		"max_level": 5,
		"values": [10.0, 12.0, 15.0, 18.0, 25.0],
		"available_levels": [1, 2, 3, 4, 5, 6, 7, 8, 9]
	},
	
	"stats_knockback": {
		"name": "Impacto Devastador",
		"description": "Aumenta a força do knockback",
		"icon": "res://icon.svg",
		"max_level": 4,
		"values": [50.0, 75.0, 100.0, 150.0],
		"available_levels": [1, 2, 3, 4, 5, 6, 7, 8, 9]
	},
	
	"stats_cooldown": {
		"name": "Fúria Crescente",
		"description": "Reduz o tempo entre ataques em 10%",
		"icon": "res://icon.svg",
		"max_level": 4,
		"values": [0.9, 0.9, 0.9, 0.9],  # Multiplicadores
		"available_levels": [1, 2, 3, 4, 5, 6, 7, 8, 9]
	},
	
	"stats_health": {
		"name": "Resistência Bárbara",
		"description": "Aumenta a vida máxima",
		"icon": "res://icon.svg",
		"max_level": 3,
		"values": [20.0, 25.0, 30.0],
		"available_levels": [1, 2, 3, 4, 5, 6, 7, 8, 9]
	},
	
	"stats_speed": {
		"name": "Investida Selvagem",
		"description": "Aumenta a velocidade de movimento",
		"icon": "res://icon.svg",
		"max_level": 3,
		"values": [15.0, 20.0, 25.0],
		"available_levels": [1, 2, 3, 4, 5, 6, 7, 8, 9]
	},
	
	# Upgrades Passivos
	"passive_vampirism": {
		"name": "Sede de Sangue",
		"description": "15% chance de curar ao matar inimigos",
		"icon": "res://icon.svg",
		"max_level": 3,
		"values": [0.15, 0.15, 0.20],  # Chance acumulativa
		"available_levels": [3, 5, 7]
	},
	
	"passive_fury_range": {
		"name": "Aura de Guerra",
		"description": "Aumenta o alcance da detecção de fúria",
		"icon": "res://icon.svg",
		"max_level": 2,
		"values": [1.3, 1.5],  # Multiplicadores de escala
		"available_levels": [4, 8]
	},
	
	"passive_berserker_rage": {
		"name": "Fúria Berserker",
		"description": "Aumenta o bônus de velocidade por inimigo próximo",
		"icon": "res://icon.svg",
		"max_level": 2,
		"values": [0.05, 0.05],  # Bônus adicional por inimigo
		"available_levels": [6, 9]
	},
	
	# Evoluções Level 10
	"evo_giant": {
		"name": "Gigante de Guerra",
		"description": "Área +200%, Dano +50%, Velocidade -20%",
		"icon": "res://icon.svg",
		"max_level": 1,
		"values": [1.0],
		"available_levels": [10],
		"evolution": true,
		"route": "giant"
	},
	
	"evo_duelist": {
		"name": "Duelista Sombrio",
		"description": "Duas armas, Área -50%, Velocidade +100%",
		"icon": "res://icon.svg",
		"max_level": 1,
		"values": [1.0],
		"available_levels": [10],
		"evolution": true,
		"route": "duelist"
	},
	
	# Upgrades pós-evolução Giant (Levels 11-24)
	"giant_earthquake": {
		"name": "Terremoto",
		"description": "Ataques criam ondas de choque",
		"icon": "res://icon.svg",
		"max_level": 3,
		"values": [1.0, 1.5, 2.0],
		"available_levels": [12, 16, 20],
		"requires_evolution": "giant"
	},
	
	"giant_armor": {
		"name": "Pele de Ferro",
		"description": "Reduz dano recebido em 15%",
		"icon": "res://icon.svg",
		"max_level": 2,
		"values": [0.15, 0.15],
		"available_levels": [14, 22],
		"requires_evolution": "giant"
	},
	
	# Upgrades pós-evolução Duelist (Levels 11-24)
	"duelist_combo": {
		"name": "Combo Mortal",
		"description": "Cada hit consecutivo aumenta dano em 10%",
		"icon": "res://icon.svg",
		"max_level": 3,
		"values": [0.1, 0.1, 0.1],
		"available_levels": [12, 16, 20],
		"requires_evolution": "duelist"
	},
	
	"duelist_dodge": {
		"name": "Esquiva Sombria",
		"description": "20% chance de evitar dano completamente",
		"icon": "res://icon.svg",
		"max_level": 2,
		"values": [0.2, 0.1],
		"available_levels": [14, 22],
		"requires_evolution": "duelist"
	},
	
	# Ultimates Level 25
	"ultimate_giant_rampage": {
		"name": "DEVASTAÇÃO TOTAL",
		"description": "Ataques destroem tudo em uma área massiva",
		"icon": "res://icon.svg",
		"max_level": 1,
		"values": [1.0],
		"available_levels": [25],
		"requires_evolution": "giant",
		"ultimate": true
	},
	
	"ultimate_duelist_storm": {
		"name": "TEMPESTADE DE LÂMINAS",
		"description": "Cria múltiplas armas que atacam automaticamente",
		"icon": "res://icon.svg",
		"max_level": 1,
		"values": [1.0],
		"available_levels": [25],
		"requires_evolution": "duelist",
		"ultimate": true
	}
}

# Função para obter upgrades disponíveis para um level específico
static func get_available_upgrades(level: int, evolution_route: String = "", current_upgrades: Dictionary = {}) -> Array:
	var available = []
	
	for upgrade_id in upgrade_data.keys():
		var upgrade = upgrade_data[upgrade_id]
		
		# Verificar se o upgrade está disponível neste level
		if level not in upgrade.available_levels:
			continue
		
		# Verificar se requer evolução específica
		if upgrade.has("requires_evolution") and upgrade.requires_evolution != evolution_route:
			continue
		
		# Verificar se já atingiu o nível máximo
		var current_level = current_upgrades.get(upgrade_id, 0)
		if current_level >= upgrade.max_level:
			continue
		
		# Verificar se é evolução e já tem uma
		if upgrade.has("evolution") and evolution_route != "":
			continue
		
		available.append({
			"id": upgrade_id,
			"name": upgrade.name,
			"description": upgrade.description,
			"icon": upgrade.icon,
			"current_level": current_level,
			"max_level": upgrade.max_level,
			"value": upgrade.values[current_level] if current_level < upgrade.values.size() else 0.0,
			"is_evolution": upgrade.has("evolution"),
			"is_ultimate": upgrade.has("ultimate")
		})
	
	return available

# Função para obter informações de um upgrade específico
static func get_upgrade_info(upgrade_id: String) -> Dictionary:
	if upgrade_id in upgrade_data:
		return upgrade_data[upgrade_id].duplicate()
	return {}

# Função para validar se um upgrade pode ser aplicado
static func can_apply_upgrade(upgrade_id: String, level: int, evolution_route: String, current_upgrades: Dictionary) -> bool:
	if upgrade_id not in upgrade_data:
		return false
	
	var upgrade = upgrade_data[upgrade_id]
	
	# Verificar level
	if level not in upgrade.available_levels:
		return false
	
	# Verificar evolução
	if upgrade.has("requires_evolution") and upgrade.requires_evolution != evolution_route:
		return false
	
	# Verificar nível máximo
	var current_level = current_upgrades.get(upgrade_id, 0)
	if current_level >= upgrade.max_level:
		return false
	
	return true