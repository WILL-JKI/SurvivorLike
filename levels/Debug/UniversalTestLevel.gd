extends Node2D
class_name UniversalTestLevel

# Level de teste universal para todos os personagens
# Spawna o personagem selecionado + inimigos + boss

# Referências dos nós
@onready var enemy_spawner: Node2D = $EnemySpawner
@onready var boss_spawn_timer: Timer = $BossSpawnTimer
@onready var ui_layer: CanvasLayer = $UI
@onready var ui_manager: UIManager = $UI/UIManager

# Configurações do level
@export var initial_enemies: int = 5
@export var boss_spawn_delay: float = 30.0  # Boss spawna após 30 segundos
@export var spawn_positions_radius: float = 400.0

# Variáveis internas
var player_instance: Node2D = null
var boss_spawned: bool = false
var level_start_time: float = 0.0

func _ready():
	print("UniversalTestLevel: Inicializando level de teste universal")
	
	# Aguardar um frame para garantir que todos os nós estejam prontos
	await get_tree().process_frame
	
	# Configurar timer do boss
	if boss_spawn_timer:
		boss_spawn_timer.wait_time = boss_spawn_delay
		boss_spawn_timer.one_shot = true
		boss_spawn_timer.timeout.connect(_on_boss_spawn_timer_timeout)
	
	# Spawnar personagem selecionado
	spawn_selected_character()
	
	# Spawnar inimigos iniciais
	spawn_initial_enemies()
	
	# Configurar EnemySpawner se disponível
	if enemy_spawner:
		print("UniversalTestLevel: EnemySpawner encontrado e configurado")
	else:
		print("UniversalTestLevel: AVISO - EnemySpawner não encontrado")
	
	# Iniciar timer do boss
	if boss_spawn_timer:
		boss_spawn_timer.start()
	level_start_time = 0.0
	
	print("UniversalTestLevel: Level iniciado - Boss em %.1f segundos" % boss_spawn_delay)

func spawn_selected_character():
	# Verificar se há personagem selecionado no GameManager
	if not GameManager.selected_character:
		print("UniversalTestLevel: ERRO - Nenhum personagem selecionado!")
		return
	
	var character_resource = GameManager.selected_character
	var scene_path = character_resource.player_scene_path
	
	if scene_path.is_empty():
		print("UniversalTestLevel: ERRO - Caminho da cena do personagem vazio!")
		return
	
	# Verificar se a cena existe antes de carregar
	if not FileAccess.file_exists(scene_path):
		print("UniversalTestLevel: AVISO - Cena não encontrada: ", scene_path)
		print("UniversalTestLevel: Usando fallback para personagem não implementado")
		use_fallback_character(character_resource)
		return
	
	# Carregar e instanciar o personagem
	var player_scene = load(scene_path)
	if not player_scene:
		print("UniversalTestLevel: ERRO - Não foi possível carregar: ", scene_path)
		use_fallback_character(character_resource)
		return
	
	player_instance = player_scene.instantiate()
	if not player_instance:
		print("UniversalTestLevel: ERRO - Não foi possível instanciar personagem!")
		return
	
	# Posicionar no centro
	player_instance.global_position = Vector2.ZERO
	
	# Adicionar à cena
	add_child(player_instance)
	
	# Conectar UI ao player
	if ui_manager:
		ui_manager.connect_to_player(player_instance)
		print("UniversalTestLevel: UI conectada ao player")
	else:
		print("UniversalTestLevel: AVISO - UIManager não encontrado")
	
	print("UniversalTestLevel: Personagem spawnado - %s" % character_resource.character_name)

func spawn_initial_enemies():
	# Spawnar inimigos iniciais ao redor do centro
	var enemy_scene = load("res://Enemies/SimpleEnemy.tscn")
	if not enemy_scene:
		print("UniversalTestLevel: ERRO - Não foi possível carregar SimpleEnemy.tscn")
		return
	
	for i in initial_enemies:
		var enemy = enemy_scene.instantiate()
		
		# Posição aleatória ao redor do centro
		var angle = (TAU / initial_enemies) * i + randf_range(-0.5, 0.5)
		var distance = randf_range(150, 250)
		var spawn_pos = Vector2(cos(angle), sin(angle)) * distance
		
		enemy.global_position = spawn_pos
		add_child(enemy)
	
	print("UniversalTestLevel: %d inimigos iniciais spawnados" % initial_enemies)

func _on_boss_spawn_timer_timeout():
	spawn_boss()

func spawn_boss():
	if boss_spawned:
		return
	
	# Carregar cena do boss
	var boss_scene = load("res://Enemies/SimpleBoss.tscn")
	if not boss_scene:
		print("UniversalTestLevel: ERRO - Não foi possível carregar SimpleBoss.tscn")
		return
	
	var boss = boss_scene.instantiate()
	
	# Posicionar o boss longe do player
	var spawn_distance = 300.0
	var angle = randf() * TAU
	var spawn_pos = Vector2(cos(angle), sin(angle)) * spawn_distance
	
	boss.global_position = spawn_pos
	add_child(boss)
	
	boss_spawned = true
	
	# Mostrar aviso de boss
	show_boss_warning()
	
	print("UniversalTestLevel: BOSS SPAWNADO!")

func show_boss_warning():
	# Criar aviso visual de boss
	var warning_label = Label.new()
	warning_label.text = "⚠️ BOSS APPEARED! ⚠️"
	warning_label.add_theme_font_size_override("font_size", 32)
	warning_label.add_theme_color_override("font_color", Color.RED)
	warning_label.anchors_preset = Control.PRESET_CENTER
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Aplicar fonte UI se disponível
	if FontManager:
		FontManager.apply_ui_font(warning_label, 32)
	
	ui_layer.add_child(warning_label)
	
	# Animação de aviso
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade in
	warning_label.modulate = Color.TRANSPARENT
	tween.tween_property(warning_label, "modulate", Color.RED, 0.5)
	
	# Piscar
	for i in 3:
		tween.tween_property(warning_label, "modulate", Color.YELLOW, 0.3).set_delay(0.5 + i * 0.6)
		tween.tween_property(warning_label, "modulate", Color.RED, 0.3).set_delay(0.8 + i * 0.6)
	
	# Fade out
	tween.tween_property(warning_label, "modulate", Color.TRANSPARENT, 1.0).set_delay(3.0)
	tween.tween_callback(warning_label.queue_free).set_delay(4.0)

func _input(event):
	# Atalhos de teste
	if event.is_action_pressed("ui_accept"):  # ENTER
		print("UniversalTestLevel: Spawnando inimigos extras...")
		spawn_extra_enemies(3)
	
	if event.is_action_pressed("ui_select"):  # SPACE
		if not boss_spawned:
			print("UniversalTestLevel: Forçando spawn do boss...")
			boss_spawn_timer.stop()
			spawn_boss()
		else:
			print("UniversalTestLevel: Boss já foi spawnado!")
	
	if Input.is_action_just_pressed("ui_cancel"):  # ESC
		print("UniversalTestLevel: Voltando ao menu de seleção...")
		get_tree().change_scene_to_file("res://UI/CharacterSelection.tscn")
	
	# Testes da UI de itens
	if event.is_action_pressed("dv_debug"):  # F3
		if ui_manager:
			print("UniversalTestLevel: Forçando seleção de itens...")
			if ui_manager.has_method("debug_force_item_selection"):
				ui_manager.debug_force_item_selection()
			elif ui_manager.has_method("debug_show_item_selection"):
				ui_manager.debug_show_item_selection()
			else:
				print("UniversalTestLevel: ERRO - Método de debug não encontrado no UIManager")
	
	# Teste de XP (tecla L para Level up)
	if Input.is_action_just_pressed("ui_right"):  # Seta direita como teste
		if player_instance and player_instance.has_method("gain_experience"):
			print("UniversalTestLevel: Dando XP para teste...")
			player_instance.gain_experience(50)  # Dar XP suficiente para subir de level

func spawn_extra_enemies(count: int):
	# Spawnar inimigos extras para teste
	var enemy_scene = load("res://Enemies/SimpleEnemy.tscn")
	if not enemy_scene:
		return
	
	for i in count:
		var enemy = enemy_scene.instantiate()
		
		# Posição aleatória ao redor do player
		var angle = randf() * TAU
		var distance = randf_range(200, 350)
		var spawn_pos = Vector2(cos(angle), sin(angle)) * distance
		
		if player_instance:
			spawn_pos += player_instance.global_position
		
		enemy.global_position = spawn_pos
		add_child(enemy)
	
	print("UniversalTestLevel: %d inimigos extras spawnados" % count)

func _process(delta):
	level_start_time += delta

func get_level_info() -> Dictionary:
	# Informações do level para debug UI
	
	return {
		"level_name": "Universal Test Level",
		"character": GameManager.selected_character.character_name if GameManager.selected_character else "None",
		"boss_spawned": boss_spawned,
		"elapsed_time": level_start_time,
		"enemies_count": get_tree().get_nodes_in_group("enemies").size(),
		"boss_timer": boss_spawn_timer.time_left if boss_spawn_timer and not boss_spawned else 0.0
	}
func use_fallback_character(original_character: CharacterResource):
	# Usar Berserker como fallback (sempre disponível)
	var fallback_scene_path = "res://Characters/Berserker/BerserkerPlayer.tscn"
	
	if not FileAccess.file_exists(fallback_scene_path):
		# Se nem o Berserker existe, usar RatKing
		fallback_scene_path = "res://Characters/RatKing/RatKing.tscn"
	
	if not FileAccess.file_exists(fallback_scene_path):
		print("UniversalTestLevel: ERRO CRÍTICO - Nenhum personagem disponível!")
		return
	
	print("UniversalTestLevel: Usando %s como fallback para %s" % [fallback_scene_path, original_character.character_name])
	
	# Carregar personagem de fallback
	var fallback_scene = load(fallback_scene_path)
	if not fallback_scene:
		print("UniversalTestLevel: ERRO - Falha ao carregar fallback!")
		return
	
	player_instance = fallback_scene.instantiate()
	if not player_instance:
		print("UniversalTestLevel: ERRO - Falha ao instanciar fallback!")
		return
	
	# Posicionar no centro
	player_instance.global_position = Vector2.ZERO
	
	# Adicionar à cena
	add_child(player_instance)
	
	# Mostrar aviso visual
	show_fallback_warning(original_character.character_name)
	
	print("UniversalTestLevel: Fallback spawnado com sucesso")

func show_fallback_warning(original_character_name: String):
	# Criar aviso de fallback
	var warning_label = Label.new()
	warning_label.text = "⚠️ %s not implemented yet!\nUsing fallback character for testing." % original_character_name
	warning_label.add_theme_font_size_override("font_size", 24)
	warning_label.add_theme_color_override("font_color", Color.ORANGE)
	warning_label.anchors_preset = Control.PRESET_CENTER_TOP
	warning_label.position.y = 50
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Aplicar fonte UI se disponível
	if FontManager:
		FontManager.apply_ui_font(warning_label, 24)
	
	ui_layer.add_child(warning_label)
	
	# Animação de aviso
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade in
	warning_label.modulate = Color.TRANSPARENT
	tween.tween_property(warning_label, "modulate", Color.ORANGE, 0.5)
	
	# Fade out após 5 segundos
	tween.tween_property(warning_label, "modulate", Color.TRANSPARENT, 1.0).set_delay(4.0)
	tween.tween_callback(warning_label.queue_free).set_delay(5.0)
