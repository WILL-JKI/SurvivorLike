extends Node
# Singleton para gerenciar estado global do jogo

# Personagem selecionado
var selected_character: CharacterResource = null

# Configurações de jogo
var current_level: String = ""
var game_paused: bool = false

# Sistema de Status Globais (Itens Passivos)
var global_stats: Dictionary = {
	"area_size": 1.0,           # Multiplicador de tamanho de área
	"luck": 1.0,                # Multiplicador de sorte
	"cooldown_reduction": 0.0,  # Redução de cooldown (0.0 a 1.0)
	"move_speed": 1.0,          # Multiplicador de velocidade
	"projectile_speed": 1.0,    # Multiplicador de velocidade de projétil
	"knockback": 1.0,           # Multiplicador de knockback
	"pickup_range": 1.0,        # Multiplicador de alcance de coleta
	"max_health_mult": 1.0,     # Multiplicador de vida máxima
	"thorns_damage": 0.0,       # Dano de retaliação base
	"xp_gain": 1.0              # Multiplicador de ganho de XP
}

# Estatísticas da sessão
var session_stats: Dictionary = {
	"enemies_killed": 0,
	"xp_gained": 0,
	"time_played": 0.0,
	"level_reached": 1
}

func _ready():
	print("GameManager: Sistema inicializado")

# Função para selecionar personagem
func select_character(character: CharacterResource):
	selected_character = character
	print("GameManager: Personagem selecionado - ", character.character_name)

# Função para iniciar jogo com personagem selecionado
func start_game(level_scene: String = ""):
	if not selected_character:
		print("GameManager: ERRO - Nenhum personagem selecionado!")
		return false
	
	# Definir cena do level
	if level_scene.is_empty():
		# Tentar usar level universal, com fallback para DebugLevel
		if FileAccess.file_exists("res://levels/Debug/UniversalTestLevel.tscn"):
			level_scene = "res://levels/Debug/UniversalTestLevel.tscn"
		else:
			print("GameManager: UniversalTestLevel.tscn não encontrado, usando DebugLevel como fallback")
			level_scene = "res://levels/Debug/DebugLevel.tscn"
	
	current_level = level_scene
	
	# Resetar estatísticas da sessão
	reset_session_stats()
	
	# Mudar para a cena do jogo
	get_tree().change_scene_to_file(level_scene)
	
	print("GameManager: Jogo iniciado com ", selected_character.character_name)
	return true

# Função para voltar ao menu de seleção
func return_to_character_select():
	get_tree().change_scene_to_file("res://UI/CharacterSelection.tscn")

# Resetar estatísticas da sessão
func reset_session_stats():
	session_stats = {
		"enemies_killed": 0,
		"xp_gained": 0,
		"time_played": 0.0,
		"level_reached": 1
	}

# Atualizar estatísticas
func add_enemy_killed():
	session_stats.enemies_killed += 1

func add_xp_gained(amount: int):
	session_stats.xp_gained += amount

func update_level_reached(level: int):
	session_stats.level_reached = max(session_stats.level_reached, level)

func update_time_played(delta: float):
	session_stats.time_played += delta
# Sistema de Status Globais
func apply_stat_upgrade(stat_key: String, value: float):
	if stat_key in global_stats:
		global_stats[stat_key] += value
		print("GameManager: Stat upgrade aplicado - %s: +%.2f (Total: %.2f)" % [stat_key, value, global_stats[stat_key]])
		
		# Emitir sinal para notificar personagens sobre mudança de stats
		stat_changed.emit(stat_key, global_stats[stat_key])
	else:
		print("GameManager: ERRO - Stat key inválida: ", stat_key)

func get_stat(stat_key: String) -> float:
	return global_stats.get(stat_key, 1.0)

func reset_global_stats():
	# Resetar stats para valores padrão (útil para novo jogo)
	global_stats = {
		"area_size": 1.0,
		"luck": 1.0,
		"cooldown_reduction": 0.0,
		"move_speed": 1.0,
		"projectile_speed": 1.0,
		"knockback": 1.0,
		"pickup_range": 1.0,
		"max_health_mult": 1.0,
		"thorns_damage": 0.0,
		"xp_gain": 1.0
	}
	print("GameManager: Stats globais resetados")

# Sinal para notificar mudanças de stats
signal stat_changed(stat_key: String, new_value: float)