extends Node
class_name UITweenTest

# Script para testar se os tweens da UI estão funcionando corretamente

func _ready():
	print("=== TESTE: Tweens da UI ===")
	
	# Aguardar um frame
	await get_tree().process_frame
	
	# Testar tweens
	test_ui_tweens()

func test_ui_tweens():
	print("\n--- TESTE: Animações da UI ---")
	
	# Testar GameHUD
	test_gamehud_tween()
	
	# Testar UIManager
	await get_tree().create_timer(1.0).timeout
	test_uimanager_tween()

func test_gamehud_tween():
	print("\nTestando GameHUD tween...")
	
	# Carregar GameHUD
	var hud_scene = load("res://UI/GameHUD.tscn")
	if not hud_scene:
		print("❌ ERRO: Não foi possível carregar GameHUD.tscn")
		return
	
	var hud = hud_scene.instantiate()
	if not hud:
		print("❌ ERRO: Não foi possível instanciar GameHUD")
		return
	
	add_child(hud)
	print("✅ GameHUD instanciado")
	
	# Testar efeito de level up
	if hud.has_method("create_level_up_effect"):
		print("Testando efeito de level up...")
		hud.create_level_up_effect()
		print("✅ Efeito de level up executado sem erros")
	else:
		print("❌ ERRO: Método create_level_up_effect não encontrado")
	
	# Limpar
	hud.queue_free()

func test_uimanager_tween():
	print("\nTestando UIManager tween...")
	
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
	print("✅ UIManager instanciado")
	
	# Testar efeito de item aplicado
	if ui_manager.has_method("create_item_applied_effect"):
		print("Testando efeito de item aplicado...")
		
		# Criar item de teste
		var test_item = ItemData.new()
		test_item.display_name = "Item de Teste"
		
		ui_manager.create_item_applied_effect(test_item)
		print("✅ Efeito de item aplicado executado sem erros")
	else:
		print("❌ ERRO: Método create_item_applied_effect não encontrado")
	
	# Limpar
	ui_manager.queue_free()

func test_item_selection_tween():
	print("\nTestando ItemSelectionUI tween...")
	
	# Carregar ItemSelectionUI
	var item_ui_scene = load("res://UI/ItemSelectionUI.tscn")
	if not item_ui_scene:
		print("❌ ERRO: Não foi possível carregar ItemSelectionUI.tscn")
		return
	
	var item_ui = item_ui_scene.instantiate()
	if not item_ui:
		print("❌ ERRO: Não foi possível instanciar ItemSelectionUI")
		return
	
	add_child(item_ui)
	print("✅ ItemSelectionUI instanciado")
	
	# Criar botão de teste para testar hover
	var test_button = Button.new()
	test_button.text = "Teste"
	item_ui.add_child(test_button)
	
	# Testar efeito de hover
	if item_ui.has_method("_on_item_hover"):
		print("Testando efeito de hover...")
		item_ui._on_item_hover(test_button, true)  # Hover in
		await get_tree().create_timer(0.2).timeout
		item_ui._on_item_hover(test_button, false) # Hover out
		print("✅ Efeito de hover executado sem erros")
	
	# Limpar
	item_ui.queue_free()

# Função para debug manual
func debug_test_all_tweens():
	print("\n=== DEBUG: Teste Completo de Tweens ===")
	
	test_gamehud_tween()
	await get_tree().create_timer(1.0).timeout
	
	test_uimanager_tween()
	await get_tree().create_timer(1.0).timeout
	
	test_item_selection_tween()
	
	print("\n✅ Todos os testes de tween concluídos!")