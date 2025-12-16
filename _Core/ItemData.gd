extends Resource
class_name ItemData

# Resource para definir itens passivos do jogo
# Cada item modifica um stat global específico

@export var display_name: String = ""
@export var icon: Texture2D = null
@export var stat_key: String = ""  # Deve corresponder às chaves do GameManager.global_stats
@export var value: float = 0.0     # Valor a ser adicionado ao stat
@export var description: String = ""

# Função para aplicar o efeito do item
func apply_item_effect():
	if GameManager:
		GameManager.apply_stat_upgrade(stat_key, value)
		print("ItemData: Item '%s' aplicado - %s +%.2f" % [display_name, stat_key, value])
	else:
		print("ItemData: ERRO - GameManager não encontrado!")

# Função para obter descrição formatada
func get_formatted_description() -> String:
	var formatted_desc = description
	
	# Substituir placeholders na descrição
	if value > 0:
		var percentage = value * 100
		formatted_desc = formatted_desc.replace("{value}", str(int(percentage)))
	
	return formatted_desc

# Função para validar se o item está configurado corretamente
func is_valid() -> bool:
	if display_name.is_empty():
		print("ItemData: ERRO - display_name vazio")
		return false
	
	if stat_key.is_empty():
		print("ItemData: ERRO - stat_key vazio")
		return false
	
	if not GameManager.global_stats.has(stat_key):
		print("ItemData: ERRO - stat_key '%s' não existe no GameManager" % stat_key)
		return false
	
	return true