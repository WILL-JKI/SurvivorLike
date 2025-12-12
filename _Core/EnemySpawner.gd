extends Node2D
class_name EnemySpawner

# Sistema de spawn de inimigos ao redor do player

@export var spawn_distance_min: float = 200.0
@export var spawn_distance_max: float = 300.0
@export var spawn_rate: float = 3.0  # Segundos entre spawns
@export var max_enemies: int = 50
@export var enemies_per_spawn: int = 1

# Cenas de inimigos disponíveis
@export var enemy_scenes: Array[PackedScene] = []

var target_player: Node2D = null
var spawn_timer: Timer
var current_wave: int = 1
var enemies_spawned_this_wave: int = 0

func _ready():
	# Configurar timer de spawn
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_rate
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.autostart = true
	add_child(spawn_timer)
	
	# Carregar cenas de inimigos se não foram definidas
	if enemy_scenes.is_empty():
		load_default_enemies()
	
	print("EnemySpawner: Configurado com ", enemy_scenes.size(), " tipos de inimigos")

func load_default_enemies():
	# Carregar inimigos padrão
	if ResourceLoader.exists("res://Enemies/SimpleEnemy.tscn"):
		enemy_scenes.append(load("res://Enemies/SimpleEnemy.tscn"))
	
	if ResourceLoader.exists("res://Enemies/TestBoss.tscn"):
		# Boss spawna menos frequentemente
		pass

func _physics_process(delta):
	find_target_player()
	update_spawn_rate()

func find_target_player():
	if target_player and is_instance_valid(target_player):
		return
	
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		target_player = players[0]

func update_spawn_rate():
	# Aumentar dificuldade com o tempo
	var time_elapsed = Time.get_time_dict_from_system()
	var difficulty_multiplier = 1.0 + (current_wave * 0.1)
	
	# Reduzir tempo entre spawns gradualmente
	var new_spawn_rate = max(spawn_rate / difficulty_multiplier, 0.5)
	if spawn_timer.wait_time != new_spawn_rate:
		spawn_timer.wait_time = new_spawn_rate

func _on_spawn_timer_timeout():
	if not target_player:
		return
	
	# Verificar se não há muitos inimigos
	var current_enemies = get_tree().get_nodes_in_group("enemies")
	if current_enemies.size() >= max_enemies:
		return
	
	# Spawnar inimigos
	for i in enemies_per_spawn:
		spawn_enemy()
	
	enemies_spawned_this_wave += enemies_per_spawn
	
	# Verificar se deve aumentar a wave
	if enemies_spawned_this_wave >= 10:
		current_wave += 1
		enemies_spawned_this_wave = 0
		print("Wave ", current_wave, " iniciada!")

func spawn_enemy():
	if enemy_scenes.is_empty() or not target_player:
		return
	
	# Escolher inimigo aleatório
	var enemy_scene = enemy_scenes[randi() % enemy_scenes.size()]
	var enemy = enemy_scene.instantiate()
	
	# Calcular posição de spawn
	var spawn_position = get_spawn_position()
	enemy.global_position = spawn_position
	
	# Adicionar à cena
	get_parent().add_child(enemy)

func get_spawn_position() -> Vector2:
	if not target_player:
		return global_position
	
	# Gerar posição aleatória ao redor do player
	var angle = randf() * TAU
	var distance = randf_range(spawn_distance_min, spawn_distance_max)
	
	var spawn_pos = target_player.global_position + Vector2(
		cos(angle) * distance,
		sin(angle) * distance
	)
	
	return spawn_pos

func spawn_boss():
	# Função especial para spawnar boss
	if not ResourceLoader.exists("res://Enemies/TestBoss.tscn"):
		return
	
	var boss_scene = load("res://Enemies/TestBoss.tscn")
	var boss = boss_scene.instantiate()
	
	# Boss spawna mais longe
	var spawn_position = get_spawn_position()
	spawn_position += Vector2(randf_range(-100, 100), randf_range(-100, 100))
	boss.global_position = spawn_position
	
	get_parent().add_child(boss)
	print("Boss spawnado!")

# Função para ajustar dificuldade
func set_difficulty(level: int):
	current_wave = level
	spawn_rate = max(3.0 - (level * 0.2), 0.5)
	enemies_per_spawn = min(1 + (level / 5), 3)
	max_enemies = min(50 + (level * 5), 100)
	
	spawn_timer.wait_time = spawn_rate
	
	print("Dificuldade ajustada - Wave: ", current_wave, " Spawn Rate: ", spawn_rate)