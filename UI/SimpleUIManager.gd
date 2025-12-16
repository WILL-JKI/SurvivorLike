extends Node
class_name SimpleUIManager

# Versão simplificada do UIManager para teste

@onready var hud: Control = $SimpleHUD
@onready var item_selection: Control = $SimpleItemSelection

var current_player: Node2D = null

func _ready():
	print("SimpleUIManager: Inicializado")
	
	# Conectar sinais se disponíveis
	if item_selection and item_selection.has_signal("item_selected"):
		item_selection.item_selected.connect(_on_item_selected)

func connect_to_player(player: Node2D):
	current_player = player
	print("SimpleUIManager: Conectado ao player %s" % player.name)
	
	# Conectar sinal de level up
	if player.has_signal("level_changed"):
		player.level_changed.connect(_on_player_level_up)

func _on_player_level_up(new_level: int):
	print("SimpleUIManager: Player subiu para level %d" % new_level)
	
	# Mostrar seleção de itens
	if item_selection and item_selection.has_method("show_selection"):
		item_selection.show_selection()

func _on_item_selected(item: ItemData):
	print("SimpleUIManager: Item selecionado - %s" % item.display_name)

# Função para debug
func debug_show_item_selection():
	if item_selection and item_selection.has_method("show_selection"):
		item_selection.show_selection()
	else:
		print("SimpleUIManager: ERRO - ItemSelection não disponível")