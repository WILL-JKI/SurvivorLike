extends Node
# SummonManager - Sistema otimizado de gerenciamento de invocações
# Disponível globalmente como AutoLoad

# Sistema otimizado de gerenciamento de invocações
# Centraliza lógica, usa object pooling e throttling

# Configurações de performance
@export var max_active_minions: int = 50
@export var target_search_interval: int = 10  # Frames entre buscas de alvo
@export var ai_update_batch_size: int = 5     # Quantos minions atualizar por frame
@export var pool_size: int = 100              # Tamanho do pool de objetos

# Pools de objetos
var minion_pool: Array[RatMinion] = []
var active_minions: Array[RatMinion] = []
var inactive_minions: Array[RatMinion] = []

# Sistema de throttling
var current_frame: int = 0
var ai_update_index: int = 0
var target_search_frame: int = 0

# Cache de inimigos para otimização
var cached_enemies: Array[Node] = []
var enemy_cache_timer: float = 0.0
var enemy_cache_interval: float = 0.5  # Atualizar cache a cada 0.5s

# Referência ao summoner
var summoner: Node2D = null

# MultiMesh para renderização em lote
var multi_mesh_instance: MultiMeshInstance2D = null
var multi_mesh: MultiMesh = null

func _ready():
	print("SummonManager: Sistema de invocações otimizado inicializado")
	
	# Configurar processamento
	set_process(true)
	set_physics_process(true)
	
	# Inicializar pool
	initialize_object_pool()
	
	# Configurar MultiMesh (desabilitado temporariamente)
	# setup_multi_mesh()

func initialize_object_pool():
	print("SummonManager: Inicializando pool de objetos (%d)" % pool_size)
	
	# Pré-carregar cena do minion
	var minion_scene = load("res://Characters/RatKing/RatMinion.tscn")
	
	# Criar pool de minions
	for i in range(pool_size):
		var minion = minion_scene.instantiate()
		minion.set_physics_process(false)  # Desabilitar processamento individual
		minion.set_process(false)
		minion.visible = false
		# Desabilitar colisão (minion é Area2D)
		minion.monitoring = false
		minion.monitorable = false
		
		# VisibilityEnabler2D removido temporariamente para debug
		
		minion_pool.append(minion)
		inactive_minions.append(minion)
		
		# Não adicionar à árvore ainda - será adicionado quando spawnar

func setup_multi_mesh():
	# Configurar MultiMeshInstance2D para renderização em lote
	multi_mesh_instance = MultiMeshInstance2D.new()
	multi_mesh = MultiMesh.new()
	
	# Configurar MultiMesh
	multi_mesh.transform_format = MultiMesh.TRANSFORM_2D
	multi_mesh.instance_count = max_active_minions
	
	# Usar textura do minion (placeholder por enquanto)
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(16, 16)  # Tamanho do sprite do minion
	multi_mesh.mesh = quad_mesh
	
	# Criar material para o MultiMesh (2D)
	var material = CanvasItemMaterial.new()
	
	multi_mesh_instance.multimesh = multi_mesh
	multi_mesh_instance.material = material
	multi_mesh_instance.texture = load("res://icon.svg")
	add_child(multi_mesh_instance)
	
	print("SummonManager: MultiMesh configurado para %d instâncias" % max_active_minions)

func _process(delta):
	current_frame += 1
	
	# Atualizar cache de inimigos periodicamente (mantido para otimização)
	update_enemy_cache(delta)
	
	# Atualizar IA em lotes (desabilitado - cada minion gerencia sua própria IA)
	# update_minion_ai_batch()
	
	# Atualizar renderização em lote (desabilitado temporariamente)
	# update_multi_mesh_rendering()

#func _physics_process(delta):
	# Movimento individual dos minions (desabilitado - cada minion se move sozinho)
	# update_minion_movement(delta)

func update_enemy_cache(delta):
	enemy_cache_timer += delta
	if enemy_cache_timer >= enemy_cache_interval:
		enemy_cache_timer = 0.0
		
		# Usar NodeGroupCache se disponível
		if NodeGroupCache:
			cached_enemies = NodeGroupCache.get_nodes_in_group_cached("enemies")
		else:
			cached_enemies = get_tree().get_nodes_in_group("enemies")
		
		# Filtrar inimigos válidos
		cached_enemies = cached_enemies.filter(func(enemy): return is_instance_valid(enemy))

func update_minion_ai_batch():
	# Atualizar IA apenas de alguns minions por frame (throttling)
	if active_minions.is_empty():
		return
	
	var batch_end = min(ai_update_index + ai_update_batch_size, active_minions.size())
	
	for i in range(ai_update_index, batch_end):
		if i < active_minions.size():
			var minion = active_minions[i]
			if is_instance_valid(minion):
				update_minion_ai(minion)
	
	# Avançar índice para próximo lote
	ai_update_index = batch_end
	if ai_update_index >= active_minions.size():
		ai_update_index = 0

func update_minion_ai(minion: RatMinion):
	# Buscar alvo apenas a cada X frames (throttling)
	if current_frame % target_search_interval == minion.get_instance_id() % target_search_interval:
		find_target_for_minion(minion)
	
	# Atualizar estado baseado no alvo
	update_minion_state(minion)

func find_target_for_minion(minion: RatMinion):
	if not is_instance_valid(minion):
		return
	
	var best_target: Node2D = null
	var best_distance: float = minion.detection_range
	
	# Usar cache de inimigos em vez de buscar na árvore
	for enemy in cached_enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = minion.global_position.distance_to(enemy.global_position)
		if distance < best_distance:
			best_distance = distance
			best_target = enemy
	
	minion.target_enemy = best_target

func update_minion_state(minion: RatMinion):
	if not is_instance_valid(minion):
		return
	
	# Lógica de estado simplificada e otimizada
	if minion.target_enemy and is_instance_valid(minion.target_enemy):
		var distance_to_target = minion.global_position.distance_to(minion.target_enemy.global_position)
		
		if distance_to_target <= minion.attack_range:
			minion.current_state = RatMinion.State.ATTACK
		else:
			minion.current_state = RatMinion.State.CHASE
	else:
		minion.current_state = RatMinion.State.FOLLOW_KING

func update_minion_movement(delta):
	# Atualizar movimento de todos os minions ativos em um loop otimizado
	for minion in active_minions:
		if not is_instance_valid(minion):
			continue
		
		var target_position: Vector2
		var move_speed = minion.speed
		
		match minion.current_state:
			RatMinion.State.CHASE:
				if minion.target_enemy and is_instance_valid(minion.target_enemy):
					target_position = minion.target_enemy.global_position
				else:
					target_position = get_follow_position(minion)
			
			RatMinion.State.ATTACK:
				# Parar para atacar
				target_position = minion.global_position
				handle_minion_attack(minion)
			
			_:  # FOLLOW_KING, ORGANIZE
				target_position = get_follow_position(minion)
		
		# Aplicar movimento suavizado
		var direction = (target_position - minion.global_position).normalized()
		minion.velocity = minion.velocity.lerp(direction * move_speed, 5.0 * delta)
		minion.global_position += minion.velocity * delta

func get_follow_position(minion: RatMinion) -> Vector2:
	if not summoner:
		return minion.global_position
	
	# Posição de formação ao redor do summoner
	var angle = minion.formation_angle
	var distance = minion.formation_distance
	
	return summoner.global_position + Vector2(cos(angle), sin(angle)) * distance

func handle_minion_attack(minion: RatMinion):
	# Lógica de ataque simplificada
	if minion.attack_cooldown <= 0 and minion.target_enemy and is_instance_valid(minion.target_enemy):
		# Aplicar dano
		if minion.target_enemy.has_method("take_damage"):
			minion.target_enemy.take_damage(minion.damage)
		
		minion.attack_cooldown = 1.0  # Cooldown de 1 segundo
		
		# Kamikaze
		if minion.is_kamikaze:
			despawn_minion(minion)
	else:
		minion.attack_cooldown -= get_physics_process_delta_time()

func update_multi_mesh_rendering():
	# Atualizar posições no MultiMesh para renderização em lote
	if not multi_mesh or active_minions.is_empty():
		return
	
	var instance_count = min(active_minions.size(), max_active_minions)
	multi_mesh.instance_count = instance_count
	
	for i in range(instance_count):
		if i < active_minions.size():
			var minion = active_minions[i]
			if is_instance_valid(minion):
				var transform = Transform2D()
				transform.origin = minion.global_position
				multi_mesh.set_instance_transform_2d(i, transform)

# Funções públicas para spawnar/despawnar minions
func spawn_minion(position: Vector2, summoner_ref: Node2D) -> RatMinion:
	if inactive_minions.is_empty():
		print("SummonManager: Pool esgotado! Não é possível spawnar mais minions.")
		return null
	
	if active_minions.size() >= max_active_minions:
		print("SummonManager: Limite de minions ativos atingido!")
		return null
	
	# Pegar minion do pool
	var minion = inactive_minions.pop_back()
	active_minions.append(minion)
	
	# Adicionar à cena se não estiver já
	if not minion.get_parent():
		summoner_ref.get_parent().add_child(minion)
	
	# Configurar minion
	minion.global_position = position
	minion.summoner = summoner_ref
	summoner = summoner_ref
	minion.visible = true
	# Reabilitar colisão (minion é Area2D)
	minion.monitoring = true
	minion.monitorable = true
	
	# Parar o timer de lifetime (minions só morrem em combate)
	if minion.has_method("get") and minion.get("lifetime_timer"):
		minion.lifetime_timer.stop()
	
	# Configurar formação
	setup_minion_formation(minion)
	
	print("SummonManager: Minion spawnado. Ativos: %d/%d" % [active_minions.size(), max_active_minions])
	return minion

func despawn_minion(minion: RatMinion):
	if not minion in active_minions:
		return
	
	# Remover da lista ativa
	active_minions.erase(minion)
	inactive_minions.append(minion)
	
	# Desativar minion
	minion.visible = false
	minion.monitoring = false
	minion.monitorable = false
	minion.target_enemy = null
	minion.velocity = Vector2.ZERO
	
	# Parar timer de lifetime
	if minion.has_method("get") and minion.get("lifetime_timer"):
		minion.lifetime_timer.stop()
	
	print("SummonManager: Minion despawnado. Ativos: %d" % active_minions.size())

func setup_minion_formation(minion: RatMinion):
	# Configurar posição na formação
	var index = active_minions.find(minion)
	var total_minions = active_minions.size()
	
	minion.formation_angle = (TAU / max(total_minions, 1)) * index
	minion.formation_distance = 50.0 + (index / 8) * 20.0  # Círculos concêntricos

# Função para limpar todos os minions
func clear_all_minions():
	for minion in active_minions.duplicate():
		despawn_minion(minion)

# Função para obter estatísticas
func get_stats() -> Dictionary:
	return {
		"active_minions": active_minions.size(),
		"inactive_minions": inactive_minions.size(),
		"pool_size": minion_pool.size(),
		"cached_enemies": cached_enemies.size()
	}
