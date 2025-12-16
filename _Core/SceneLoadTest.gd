extends Node
class_name SceneLoadTest

# Script para testar se as cenas da UI podem ser carregadas

func _ready():
	print("=== TESTE: Carregamento de Cenas da UI ===")
	
	# Aguardar um frame
	await get_tree().process_frame
	
	# Testar carregamento das cenas
	test_scene_loading()

func test_scene_loading():
	print("\n--- TESTE: Carregamento de Cenas ---")
	
	var scenes_to_test = [
		"res://UI/GameHUD.tscn",
		"res://UI/ItemSelectionUI.tscn",
		"res://UI/UIManager.tscn"
	]
	
	for scene_path in scenes_to_test:
		test_single_scene(scene_path)

func test_single_scene(scene_path: String):
	print("\nTestando: %s" % scene_path)
	
	# Verificar se o arquivo existe
	if not FileAccess.file_exists(scene_path):
		print("❌ ERRO: Arquivo não encontrado")
		return
	
	print("✅ Arquivo existe")
	
	# Tentar carregar a cena
	var scene = load(scene_path)
	if not scene:
		print("❌ ERRO: Falha ao carregar cena")
		return
	
	print("✅ Cena carregada com sucesso")
	
	# Tentar instanciar
	var instance = scene.instantiate()
	if not instance:
		print("❌ ERRO: Falha ao instanciar cena")
		return
	
	print("✅ Cena instanciada com sucesso")
	
	# Verificar tipo do nó
	print("   Tipo: %s" % instance.get_class())
	print("   Nome: %s" % instance.name)
	
	# Limpar instância
	instance.queue_free()
	
	print("✅ Teste completo para %s" % scene_path.get_file())

# Função para testar no console
func debug_test_ui_scenes():
	print("\n=== DEBUG: Teste Manual de Cenas ===")
	
	# Testar GameHUD
	var hud_scene = load("res://UI/GameHUD.tscn")
	if hud_scene:
		var hud = hud_scene.instantiate()
		add_child(hud)
		print("✅ GameHUD adicionado à cena")
		
		# Remover após 2 segundos
		await get_tree().create_timer(2.0).timeout
		hud.queue_free()
		print("✅ GameHUD removido")
	
	# Testar ItemSelectionUI
	var item_scene = load("res://UI/ItemSelectionUI.tscn")
	if item_scene:
		var item_ui = item_scene.instantiate()
		add_child(item_ui)
		print("✅ ItemSelectionUI adicionado à cena")
		
		# Remover após 2 segundos
		await get_tree().create_timer(2.0).timeout
		item_ui.queue_free()
		print("✅ ItemSelectionUI removido")
	
	print("✅ Teste manual concluído!")

func test_ui_manager_integration():
	print("\n--- TESTE: Integração UIManager ---")
	
	# Carregar UIManager
	var ui_manager_scene = load("res://UI/UIManager.tscn")
	if not ui_manager_scene:
		print("❌ ERRO: Não foi possível carregar UIManager.tscn")
		return
	
	var ui_manager = ui_manager_scene.instantiate()
	if not ui_manager:
		print("❌ ERRO: Não foi possível instanciar UIManager")
		return
	
	add_child(ui_manager)
	print("✅ UIManager adicionado à cena")
	
	# Verificar componentes
	var game_hud = ui_manager.get_node_or_null("GameHUD")
	var item_selection = ui_manager.get_node_or_null("ItemSelectionUI")
	
	if game_hud:
		print("✅ GameHUD encontrado no UIManager")
	else:
		print("❌ GameHUD não encontrado no UIManager")
	
	if item_selection:
		print("✅ ItemSelectionUI encontrado no UIManager")
	else:
		print("❌ ItemSelectionUI não encontrado no UIManager")
	
	# Limpar
	ui_manager.queue_free()
	print("✅ Teste de integração concluído")