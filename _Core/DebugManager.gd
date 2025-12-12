extends Node
# Gerenciador global de debug

# Singleton para gerenciar debug em todo o jogo
# Adicione este script como AutoLoad no projeto

var debug_ui_scene: PackedScene
var debug_ui_instance: DebugUI = null

func _ready():
	# Carregar cena de debug
	debug_ui_scene = load("res://_Core/DebugUI.tscn")
	
	# Criar instância de debug (deferred para evitar conflitos)
	call_deferred("create_debug_ui")
	
	print("DebugManager: Sistema de debug inicializado (F3 para ativar)")

func create_debug_ui():
	if debug_ui_scene and not debug_ui_instance:
		debug_ui_instance = debug_ui_scene.instantiate()
		
		# Adicionar à árvore principal (deferred para evitar conflitos)
		get_tree().root.call_deferred("add_child", debug_ui_instance)
		
		# Configurar z_index após adicionar (deferred)
		call_deferred("setup_debug_ui_properties")

func _input(event):
	# Backup para toggle debug se a UI não capturar
	if event.is_action_pressed("dv_debug"):
		if debug_ui_instance:
			debug_ui_instance.toggle_debug()

# Função para adicionar informações customizadas ao debug
func add_debug_info(title: String, info: String):
	if debug_ui_instance:
		debug_ui_instance.add_custom_info(title, info)

# Função para verificar se debug está ativo
func is_debug_active() -> bool:
	if debug_ui_instance:
		return debug_ui_instance.is_visible
	return false

# Função para forçar ativação/desativação do debug
func set_debug_active(active: bool):
	if debug_ui_instance:
		debug_ui_instance.is_visible = active
		debug_ui_instance.visible = active

func setup_debug_ui_properties():
	if debug_ui_instance:
		# Mover para o topo da hierarquia
		debug_ui_instance.z_index = 1000