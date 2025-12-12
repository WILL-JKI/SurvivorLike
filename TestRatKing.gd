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
	
	print("Rat King carregado com sucesso!")
	print("Use WASD para mover")
	print("Ratos serão spawnados automaticamente a cada 2 segundos")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("Teste: Ganhando experiência...")
		var rat_king = get_children().filter(func(child): return child.name == "RatKing")
		if rat_king.size() > 0:
			rat_king[0].gain_experience(50)