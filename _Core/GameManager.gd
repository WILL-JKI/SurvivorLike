extends Node
# Singleton para gerenciar estado global do jogo

# Personagem selecionado
var selected_character: CharacterResource = null

# Configurações de jogo
var current_level: String = ""
var game_paused: bool = false

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
