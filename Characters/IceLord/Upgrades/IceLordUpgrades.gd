extends Node
class_name IceLordUpgrades

# Sistema de upgrades para o Ice Lord
# Define todos os upgrades disponíveis e suas progressões

# Estrutura de dados dos upgrades
static var upgrade_data = {
	# Upgrades de Stats Base (Levels 1-9)
	"stats_damage": {
		"name": "Cristal Afiado",
		"description": "Aumenta o dano dos projéteis de gelo",
		"icon": "res://icon.svg",
		"max_level": 5,
		"values": [5.0, 6.0, 7.0, 8.0, 10.0],
		"available_levels": [1, 2, 3, 4, 5, 6, 7, 8, 9]
	},
	
	"stats_speed": {
		"name": "Vento Ártico",
		"description": "Aumenta a velocidade dos projéteis",
		"icon": "res://icon.svg",
		"max_level": 4,
		"values": [30.0, 40.0, 50.0, 70.0],
		"available_levels": [1, 2, 3, 4, 5, 6, 7, 8, 9]
	},
	
	"stats_cooldown": {
		"name": "Foco Glacial",
		"description": "Reduz o tempo entre ataques em 10%",
		"icon": "res://icon.svg",
		"max_level": 4,
		"values": [0.9, 0.9, 0.9, 0.9],  # Multiplicadores
		"available_levels": [1, 2, 3, 4, 5, 6, 7, 8, 9]
	},
	
	"stats_pierce": {
		"name": "Lança de Gelo",
		"description": "Projétil atravessa +1 inimigo",
		"icon": "res://icon.svg",
		"max_level": 3,
		"values": [1, 1, 1],  # +1 piercing por level
		"available_levels": [2, 5, 8]
	},
	
	"stats_frost": {
		"name": "Frio Intenso",
		"description": "Cada projétil aplica +1 stack de frost",
		"icon": "res://icon.svg",
		"max_level": 2,
		"values": [1, 1],  # +1 frost stack por level
		"available_levels": [3, 7]
	},
	
	"stats_health": {
		"name": "Armadura de Gelo",
		"description": "Aumenta a vida máxima",
		"icon": "res://icon.svg",
		"max_level": 3,
		"values": [15.0, 20.0, 25.0],
		"available_levels": [1, 4, 8]
	},
	
	"stats_movement": {
		"name": "Deslizar no Gelo",
		"description": "Aumenta a velocidade de movimento",
		"icon": "res://icon.svg",
		"max_level": 3,
		"values": [15.0, 20.0, 25.0],
		"available_levels": [2, 6, 9]
	},
	
	# Upgrades Passivos
	"passive_shatter": {
		"name": "Quebra-Gelo",
		"description": "+50% dano contra inimigos congelados",
		"icon": "res://icon.svg",
		"max_level": 3,
		"values": [10.0, 15.0, 25.0],  # Bônus de dano
		"available_levels": [4, 6, 9]
	},
	
	"passive_freeze_duration": {
		"name": "Gelo Eterno",
		"description": "Inimigos ficam congelados por mais tempo",
		"icon": "res://icon.svg",
		"max_level": 2,
		"values": [1.0, 1.5],  # +1s e +1.5s de duração
		"available_levels": [5, 8]
	},
	
	"passive_frost_aura": {
		"name": "Aura Congelante",
		"description": "Inimigos próximos recebem frost gradualmente",
		"icon": "res://icon.svg",
		"max_level": 2,
		"values": [1.0, 1.0],  # Ativação da aura
		"available_levels": [6, 9]
	},
	
	# Evoluções Level 10
	"evo_blizzard": {
		"name": "Senhor da Nevasca",
		"description": "Substitui projéteis por aura que congela inimigos próximos",
		"icon": "res://icon.svg",
		"max_level": 1,
		"values": [1.0],
		"available_levels": [10],
		"evolution": true,
		"route": "blizzard"
	},
	
	"evo_lance": {
		"name": "Lança Perfurante",
		"description": "Projétil +50% velocidade, piercing infinito, -30% taxa de ataque",
		"icon": "res://icon.svg",
		"max_level": 1,
		"values": [1.0],
		"available_levels": [10],
		"evolution": true,
		"route": "lance"
	},
	
	# Upgrades pós-evolução Blizzard (Levels 11-24)
	"blizzard_range": {
		"name": "Tempestade Expandida",
		"description": "Aumenta o alcance da nevasca",
		"icon": "res://icon.svg",
		"max_level": 3,
		"values": [1.3, 1.5, 2.0],  # Multiplicadores de alcance
		"available_levels": [12, 16, 20],
		"requires_evolution": "blizzard"
	},
	
	"blizzard_intensity": {
		"name": "Nevasca Furiosa",
		"description": "Aplica frost mais rapidamente",
		"icon": "res://icon.svg",
		"max_level": 3,
		"values": [0.4, 0.3, 0.2],  # Redução no intervalo (0.5s -> 0.1s)
		"available_levels": [14, 18, 22],
		"requires_evolution": "blizzard"
	},
	
	# Upgrades pós-evolução Lance (Levels 11-24)
	"lance_damage": {
		"name": "Lança Devastadora",
		"description": "Cada inimigo atravessado aumenta o dano em 20%",
		"icon": "res://icon.svg",
		"max_level": 3,
		"values": [0.2, 0.2, 0.3],  # Multiplicador de dano por pierce
		"available_levels": [12, 16, 20],
		"requires_evolution": "lance"
	},
	
	"lance_frost_trail": {
		"name": "Rastro Congelante",
		"description": "Lança deixa rastro que aplica frost",
		"icon": "res://icon.svg",
		"max_level": 2,
		"values": [1.0, 2.0],  # Duração do rastro
		"available_levels": [14, 22],
		"requires_evolution": "lance"
	},
	
	# Ultimates Level 25
	"ultimate_blizzard_lord": {
		"name": "SENHOR DO INVERNO",
		"description": "Nevasca congela instantaneamente e se espalha",
		"icon": "res://icon.svg",
		"max_level": 1,
		"values": [1.0],
		"available_levels": [25],
		"requires_evolution": "blizzard",
		"ultimate": true
	},
	
	"ultimate_lance_storm": {
		"name": "TEMPESTADE DE LANÇAS",
		"description": "Dispara múltiplas lanças em todas as direções",
		"icon": "res://icon.svg",
		"max_level": 1,
		"values": [1.0],
		"available_levels": [25],
		"requires_evolution": "lance",
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