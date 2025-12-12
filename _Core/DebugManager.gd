extends Node
# Gerenciador global de debug

# Singleton para gerenciar debug em todo o jogo
# Adicione este script como AutoLoad no projeto

var debug_ui_scene: PackedScene
var debug_ui_instance: DebugUI = null

func _ready():
	print("DebugManager: Iniciando...")
	
	# Aguardar um frame para garantir que tudo está inicializado
	await get_tree().process_frame
	
	# Carregar cena de debug
	debug_ui_scene = load("res://_Core/DebugUI.tscn")
	
	if debug_ui_scene:
		print("DebugManager: Cena carregada com sucesso")
		create_debug_ui()
	else:
		print("DebugManager: ERRO - Falha ao carregar cena de debug")

func create_debug_ui():
	if not debug_ui_instance:
		debug_ui_instance = debug_ui_scene.instantiate()
		print("DebugManager: Debug UI instanciada")
		
		# Adicionar diretamente à árvore principal
		get_tree().root.add_child(debug_ui_instance)
		
		# Configurar propriedades
		debug_ui_instance.z_index = 1000
		debug_ui_instance.visible = false
		
		print("DebugManager: Debug UI adicionada à árvore e configurada")
		print("DebugManager: Sistema de debug pronto (F3 para ativar)")
	else:
		print("DebugManager: Debug UI já existe")

func _input(event):
	# Backup para toggle debug se a UI não capturar
	if event.is_action_pressed("dv_debug"):
		print("DebugManager: F3 pressionado")
		if debug_ui_instance:
			print("DebugManager: Chamando toggle_debug()")
			debug_ui_instance.toggle_debug()
		else:
			print("DebugManager: ERRO - Debug UI não existe!")

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
