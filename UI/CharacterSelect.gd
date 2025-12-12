extends Control
class_name CharacterSelect

# Array de personagens disponíveis
@export var available_characters: Array[CharacterResource] = []

# Referências dos nós
@onready var character_grid: GridContainer = $MainLayout/LeftColumn/GridContainer
@onready var character_name_label: Label = $MainLayout/RightInfoPanel/VBoxContainer/CharacterName
@onready var description_label: RichTextLabel = $MainLayout/RightInfoPanel/VBoxContainer/Description
@onready var stats_label: RichTextLabel = $MainLayout/RightInfoPanel/VBoxContainer/Stats/StatsText
@onready var start_button: Button = $MainLayout/RightInfoPanel/VBoxContainer/StartButton

# Personagem atualmente selecionado
var current_character: CharacterResource = null
var character_buttons: Array[TextureButton] = []

func _ready():
	print("CharacterSelect: Inicializando tela de seleção")
	
	# Aguardar um frame para garantir que todos os nós estejam prontos
	await get_tree().process_frame
	
	# Aplicar UiFont aos elementos do painel
	apply_ui_fonts()
	
	# Configurar grid
	character_grid.columns = 3  # 3 colunas para os personagens
	
	# Conectar sinal do botão start
	start_button.pressed.connect(_on_start_button_pressed)
	start_button.disabled = true  # Desabilitado até selecionar personagem
	
	# Criar personagens padrão se array estiver vazio
	if available_characters.is_empty():
		create_default_characters()
	
	# Popular grid com personagens
	populate_character_grid()
	
	# Selecionar primeiro personagem por padrão
	if available_characters.size() > 0:
		call_deferred("select_character", available_characters[0])

func apply_ui_fonts():
	# Aplicar UiFont aos elementos do painel direito
	if FontManager:
		FontManager.apply_ui_font(character_name_label, 24)
		FontManager.apply_ui_font(description_label, 14)
		FontManager.apply_ui_font(stats_label, 12)
		FontManager.apply_ui_font(start_button, 20)
		print("CharacterSelect: UiFont aplicada aos elementos")
	else:
		print("CharacterSelect: FontManager não encontrado")

func create_default_characters():
	# Criar recursos padrão dos personagens
	print("CharacterSelect: Criando personagens padrão")
	
	# Berserker
	var berserker = CharacterResource.new()
	berserker.character_name = "Berserker"
	berserker.character_id = "berserker"
	berserker.description = "[color=red][b]GUERREIRO FURIOSO[/b][/color]\n\nEspecialista em combate corpo a corpo com área de efeito. Quanto mais inimigos próximos, mais rápido ataca.\n\n[color=yellow]Mecânica Única:[/color] Sistema de Fúria - velocidade de ataque aumenta com densidade de inimigos.\n\n[color=cyan]Evoluções:[/color]\n• Gigante: Área massiva, mais lento\n• Duelista: Duas armas, muito rápido"
	berserker.player_scene_path = "res://Characters/Berserker/BerserkerPlayer.tscn"
	berserker.base_health = 120.0
	berserker.base_speed = 100.0
	berserker.base_damage = 25.0
	berserker.weapon_type = "Vórtice de Lâminas"
	berserker.character_class = "Melee DPS"
	berserker.difficulty = "Medium"
	berserker.special_ability = "Fúria Crescente"
	berserker.portrait_texture = preload("res://icon.svg")  # Placeholder
	berserker.big_portrait_texture = preload("res://icon.svg")  # Placeholder
	
	# Rei dos Ratos
	var rat_king = CharacterResource.new()
	rat_king.character_name = "Rei dos Ratos"
	rat_king.character_id = "rat_king"
	rat_king.description = "[color=purple][b]INVOCADOR SOMBRIO[/b][/color]\n\nComanda uma horda de ratos minions que lutam por você. Estratégia baseada em números e controle.\n\n[color=yellow]Mecânica Única:[/color] Invocação automática de minions com diferentes comportamentos.\n\n[color=cyan]Evoluções:[/color]\n• Enxame: Muitos ratos fracos\n• Fera: Poucos ratos gigantes"
	rat_king.player_scene_path = "res://Characters/RatKing/RatKing.tscn"
	rat_king.base_health = 100.0
	rat_king.base_speed = 120.0
	rat_king.base_damage = 10.0
	rat_king.weapon_type = "Horda de Minions"
	rat_king.character_class = "Summoner"
	rat_king.difficulty = "Easy"
	rat_king.special_ability = "Invocação Automática"
	rat_king.portrait_texture = preload("res://icon.svg")  # Placeholder
	rat_king.big_portrait_texture = preload("res://icon.svg")  # Placeholder
	
	# Maga (placeholder para futuro)
	var mage = CharacterResource.new()
	mage.character_name = "Maga Elemental"
	mage.character_id = "mage"
	mage.description = "[color=blue][b]MESTRA DOS ELEMENTOS[/b][/color]\n\n[color=red]EM DESENVOLVIMENTO[/color]\n\nEspecialista em magia elemental com projéteis e áreas de efeito devastadoras.\n\n[color=yellow]Mecânica Única:[/color] Combinação de elementos para efeitos especiais.\n\n[color=cyan]Evoluções:[/color]\n• Fogo: Dano massivo\n• Gelo: Controle e lentidão"
	mage.player_scene_path = ""  # Ainda não implementado
	mage.base_health = 80.0
	mage.base_speed = 90.0
	mage.base_damage = 35.0
	mage.weapon_type = "Projéteis Mágicos"
	mage.character_class = "Ranged DPS"
	mage.difficulty = "Hard"
	mage.special_ability = "Combinação Elemental"
	mage.portrait_texture = preload("res://icon.svg")  # Placeholder
	mage.big_portrait_texture = preload("res://icon.svg")  # Placeholder
	
	available_characters = [berserker, rat_king, mage]

func populate_character_grid():
	print("CharacterSelect: Populando grid com %d personagens" % available_characters.size())
	
	# Limpar grid existente
	for child in character_grid.get_children():
		child.queue_free()
	
	character_buttons.clear()
	
	# Criar botão para cada personagem
	for i in range(available_characters.size()):
		var character = available_characters[i]
		print("CharacterSelect: Criando botão para ", character.character_name)
		var button = create_character_button(character, i)
		character_grid.add_child(button)
		character_buttons.append(button)
		print("CharacterSelect: Botão adicionado ao grid")
	
	print("CharacterSelect: Grid populado com %d botões" % character_buttons.size())

func create_character_button(character: CharacterResource, index: int) -> TextureButton:
	var button = TextureButton.new()
	
	# Configurar textura
	button.texture_normal = character.portrait_texture
	button.custom_minimum_size = Vector2(120, 120)
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	# Estilo simples para evitar problemas
	button.modulate = Color.WHITE
	
	# Conectar sinais com logs
	print("CharacterSelect: Conectando sinais para ", character.character_name)
	button.pressed.connect(_on_character_button_pressed.bind(character))
	button.mouse_entered.connect(_on_character_button_hover.bind(character))
	button.focus_entered.connect(_on_character_button_hover.bind(character))
	
	# Tooltip
	button.tooltip_text = character.character_name
	
	# Adicionar um Label como filho para mostrar o nome
	var label = Label.new()
	label.text = character.character_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label.anchors_preset = Control.PRESET_BOTTOM_WIDE
	label.offset_top = -20
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	button.add_child(label)
	
	print("CharacterSelect: Botão criado para ", character.character_name)
	return button

func _on_character_button_pressed(character: CharacterResource):
	print("CharacterSelect: Botão pressionado - ", character.character_name)
	select_character(character)

func _on_character_button_hover(character: CharacterResource):
	print("CharacterSelect: Hover sobre - ", character.character_name)
	# Não atualizar painel no hover, apenas na seleção

func select_character(character: CharacterResource):
	print("CharacterSelect: Selecionando personagem - ", character.character_name)
	current_character = character
	update_info_panel(character)
	start_button.disabled = false
	
	# Atualizar estilo dos botões para mostrar seleção
	update_button_selection()
	
	print("CharacterSelect: Personagem selecionado com sucesso!")

func update_button_selection():
	print("CharacterSelect: Atualizando seleção visual")
	for i in range(character_buttons.size()):
		var button = character_buttons[i]
		var character = available_characters[i]
		
		if character == current_character:
			# Selecionado - modulate verde
			button.modulate = Color.GREEN
			print("CharacterSelect: Botão ", character.character_name, " marcado como selecionado")
		else:
			# Normal - modulate branco
			button.modulate = Color.WHITE

func update_info_panel(character: CharacterResource):
	if not character:
		return
	
	# Atualizar informações do painel (apenas do personagem selecionado)
	character_name_label.text = character.character_name
	description_label.text = character.description
	stats_label.text = character.get_stats_text()
	
	print("CharacterSelect: Painel atualizado para ", character.character_name)

func _on_start_button_pressed():
	if not current_character:
		print("CharacterSelect: ERRO - Nenhum personagem selecionado!")
		return
	
	# Verificar se personagem está implementado
	if current_character.player_scene_path.is_empty():
		print("CharacterSelect: Personagem ainda não implementado!")
		# Mostrar mensagem de "Em desenvolvimento"
		show_development_message()
		return
	
	# Salvar seleção no GameManager
	GameManager.select_character(current_character)
	
	# Iniciar jogo
	GameManager.start_game()

func show_development_message():
	# Criar popup simples para personagens não implementados
	var popup = AcceptDialog.new()
	popup.dialog_text = "Este personagem ainda está em desenvolvimento!\n\nEm breve estará disponível."
	popup.title = "Em Desenvolvimento"
	add_child(popup)
	popup.popup_centered()
	popup.confirmed.connect(popup.queue_free)

# Input handling para navegação com teclado
func _input(event):
	if event.is_action_pressed("ui_accept") and current_character:
		_on_start_button_pressed()
	elif event.is_action_pressed("ui_cancel"):
		# Voltar ao menu principal (se existir)
		get_tree().quit()