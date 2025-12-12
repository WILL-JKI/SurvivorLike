extends Resource
class_name UpgradeData

# Estrutura de dados para upgrades do Rat King

# Informações básicas do upgrade
@export var id: String
@export var name: String
@export var description: String
@export var icon: Texture2D
@export var rarity: Rarity = Rarity.COMMON

# Configurações de disponibilidade
@export var min_level: int = 1
@export var max_level: int = 9
@export var required_evolution: String = ""  # "", "swarm", "beast"
@export var is_evolution: bool = false
@export var is_ultimate: bool = false

# Enum para raridade
enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

# Função para verificar se o upgrade está disponível
func is_available(player_level: int, evolution_route: String) -> bool:
	# Verificar nível
	if player_level < min_level or player_level > max_level:
		return false
	
	# Verificar evolução necessária
	if required_evolution != "" and evolution_route != required_evolution:
		return false
	
	# Verificar se é evolução de nível 10
	if is_evolution and player_level != 10:
		return false
	
	# Verificar se é ultimate de nível 25
	if is_ultimate and player_level != 25:
		return false
	
	return true

# Função para obter cor baseada na raridade
func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON:
			return Color.WHITE
		Rarity.UNCOMMON:
			return Color.GREEN
		Rarity.RARE:
			return Color.BLUE
		Rarity.EPIC:
			return Color.PURPLE
		Rarity.LEGENDARY:
			return Color.ORANGE
		_:
			return Color.WHITE