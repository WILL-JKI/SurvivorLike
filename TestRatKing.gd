extends Node2D

# Script de teste simples para o Rat King

func _ready():
	# Carregar e instanciar o Rat King
	var rat_king_scene = load("res://Characters/RatKing/RatKing.tscn")
	var rat_king = rat_king_scene.instantiate()
	
	# Posicionar no centro da tela
	rat_king.global_position = Vector2(400, 300)
	
	# Adicionar à cena
	add_child(rat_king)
	
	# Spawnar alguns inimigos para teste
	spawn_test_enemies()
	
	print("Rat King carregado com sucesso!")
	print("Use WASD para mover")
	print("Ratos seguirão você e atacarão inimigos vermelhos")
	print("Pressione ENTER para ganhar experiência")
	print("Pressione ESPAÇO para spawnar mais inimigos")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("Teste: Ganhando experiência...")
		var rat_king = get_children().filter(func(child): return child.name == "RatKing")
		if rat_king.size() > 0:
			rat_king[0].gain_experience(50)
	
	if event.is_action_pressed("ui_select"):  # Espaço
		print("Spawnando mais inimigos...")
		spawn_test_enemies()

func spawn_test_enemies():
	var enemy_scene = load("res://Enemies/SimpleEnemy.tscn")
	
	# Spawnar 3-5 inimigos em posições aleatórias
	var enemy_count = randi_range(3, 5)
	for i in enemy_count:
		var enemy = enemy_scene.instantiate()
		
		# Posição aleatória ao redor do centro
		var angle = randf() * TAU
		var distance = randf_range(200, 400)
		var spawn_pos = Vector2(400, 300) + Vector2(cos(angle), sin(angle)) * distance
		
		enemy.global_position = spawn_pos
		add_child(enemy)
	
	print("Spawnados ", enemy_count, " inimigos!")