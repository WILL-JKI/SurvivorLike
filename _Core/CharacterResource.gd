extends Resource
class_name CharacterResource

# Resource base para definir personagens selecionáveis

@export var character_name: String = ""
@export var character_id: String = ""
@export var portrait_texture: Texture2D
@export var big_portrait_texture: Texture2D
@export var description: String = ""
@export var player_scene_path: String = ""

# Stats iniciais para exibição
@export_group("Base Stats")
@export var base_health: float = 100.0
@export var base_speed: float = 100.0
@export var base_damage: float = 20.0
@export var weapon_type: String = ""

# Informações adicionais
@export_group("Character Info")
@export var character_class: String = ""
@export var difficulty: String = "Medium"
@export var special_ability: String = ""

func get_stats_text() -> String:
	var stats = []
	stats.append("Health: %.0f" % base_health)
	stats.append("Speed: %.0f" % base_speed)
	stats.append("Damage: %.0f" % base_damage)
	stats.append("Weapon: %s" % weapon_type)
	stats.append("Difficulty: %s" % difficulty)
	
	return "\n".join(stats)