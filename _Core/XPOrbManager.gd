extends Node
# Gerenciador global de orbs de XP para otimização

# Singleton para gerenciar orbs de XP
# Adicione este script como AutoLoad se necessário

@export var max_orbs_on_screen: int = 150  # Reduzido para melhor performance
@export var merge_check_interval: float = 3.0  # Mais frequente
@export var cleanup_check_interval: float = 8.0  # Mais frequente
@export var aggressive_merge_distance: float = 60.0  # Área maior para merge agressivo

var merge_timer: float = 0.0
var cleanup_timer: float = 0.0

func _ready():
	print("XPOrbManager: Sistema de otimização de orbs ativo")

func _process(delta):
	merge_timer += delta
	cleanup_timer += delta
	
	# Verificação periódica de merge
	if merge_timer >= merge_check_interval:
		merge_timer = 0.0
		perform_global_merge_check()
	
	# Limpeza periódica se há muitas orbs
	if cleanup_timer >= cleanup_check_interval:
		cleanup_timer = 0.0
		perform_cleanup_check()

func perform_global_merge_check():
	# Verificar todas as orbs para possíveis merges
	var all_orbs = NodeGroupCache.get_nodes_in_group_cached("xp_orbs") if NodeGroupCache else get_tree().get_nodes_in_group("xp_orbs")
	
	if all_orbs.size() < 5:  # Merge mesmo com poucas orbs para otimizar
		return
	
	var merged_count = 0
	var processed_orbs = []
	
	for orb in all_orbs:
		if not is_instance_valid(orb) or orb in processed_orbs:
			continue
		
		var nearby_orbs = find_nearby_orbs(orb, all_orbs)
		if nearby_orbs.size() > 0:
			var total_value = orb.xp_value
			
			# Somar valores de todas as orbs próximas
			for nearby_orb in nearby_orbs:
				if is_instance_valid(nearby_orb):
					total_value += nearby_orb.xp_value
					processed_orbs.append(nearby_orb)
					nearby_orb.queue_free()
			
			# Atualizar orb principal
			var new_type = get_orb_type_by_value(total_value)
			orb.setup_xp_orb(total_value, new_type)
			orb.create_merge_effect()
			
			processed_orbs.append(orb)
			merged_count += nearby_orbs.size()
	
	if merged_count > 0:
		print("XPOrbManager: ", merged_count, " orbs combinadas automaticamente")

func find_nearby_orbs(target_orb: XPOrb, all_orbs: Array) -> Array:
	var nearby = []
	
	# Usar distância agressiva se há muitas orbs
	var merge_distance = aggressive_merge_distance if all_orbs.size() > 50 else 35.0
	
	for orb in all_orbs:
		if orb == target_orb or not is_instance_valid(orb):
			continue
		
		var distance = target_orb.global_position.distance_to(orb.global_position)
		if distance <= merge_distance:
			nearby.append(orb)
			
			# Limitar para evitar lag (máximo 8 orbs por merge)
			if nearby.size() >= 8:
				break
	
	return nearby

func perform_cleanup_check():
	var all_orbs = NodeGroupCache.get_nodes_in_group_cached("xp_orbs") if NodeGroupCache else get_tree().get_nodes_in_group("xp_orbs")
	
	# Primeiro tentar merge agressivo se há muitas orbs
	if all_orbs.size() > max_orbs_on_screen * 0.8:
		perform_aggressive_merge()
	
	if all_orbs.size() <= max_orbs_on_screen:
		return
	
	print("XPOrbManager: Muitas orbs detectadas (", all_orbs.size(), "), iniciando limpeza...")
	
	# Encontrar player para determinar distância
	var players = NodeGroupCache.get_nodes_in_group_cached("players") if NodeGroupCache else get_tree().get_nodes_in_group("players")
	if players.size() == 0:
		return
	
	var player = players[0]
	var orbs_with_distance = []
	
	# Calcular distância de cada orb ao player
	for orb in all_orbs:
		if is_instance_valid(orb):
			var distance = orb.global_position.distance_to(player.global_position)
			orbs_with_distance.append({"orb": orb, "distance": distance})
	
	# Ordenar por distância (mais longe primeiro)
	orbs_with_distance.sort_custom(func(a, b): return a.distance > b.distance)
	
	# Remover orbs mais distantes até atingir o limite
	var orbs_to_remove = all_orbs.size() - max_orbs_on_screen
	for i in range(min(orbs_to_remove, orbs_with_distance.size())):
		var orb_data = orbs_with_distance[i]
		if orb_data.distance > 300:  # Só remover se estiver bem longe
			orb_data.orb.queue_free()

func perform_aggressive_merge():
	# Merge agressivo quando há muitas orbs
	var all_orbs = NodeGroupCache.get_nodes_in_group_cached("xp_orbs") if NodeGroupCache else get_tree().get_nodes_in_group("xp_orbs")
	
	print("XPOrbManager: Iniciando merge agressivo com ", all_orbs.size(), " orbs")
	
	var merged_count = 0
	var processed_orbs = []
	
	# Usar distância maior para merge agressivo
	for orb in all_orbs:
		if not is_instance_valid(orb) or orb in processed_orbs:
			continue
		
		var nearby_orbs = []
		for other_orb in all_orbs:
			if other_orb == orb or not is_instance_valid(other_orb) or other_orb in processed_orbs:
				continue
			
			var distance = orb.global_position.distance_to(other_orb.global_position)
			if distance <= aggressive_merge_distance:
				nearby_orbs.append(other_orb)
				
				# Limitar para evitar lag
				if nearby_orbs.size() >= 12:
					break
		
		if nearby_orbs.size() > 0:
			var total_value = orb.xp_value
			
			# Somar valores de todas as orbs próximas
			for nearby_orb in nearby_orbs:
				if is_instance_valid(nearby_orb):
					total_value += nearby_orb.xp_value
					processed_orbs.append(nearby_orb)
					nearby_orb.queue_free()
			
			# Atualizar orb principal
			var new_type = get_orb_type_by_value(total_value)
			orb.setup_xp_orb(total_value, new_type)
			orb.create_merge_effect()
			
			processed_orbs.append(orb)
			merged_count += nearby_orbs.size()
	
	if merged_count > 0:
		print("XPOrbManager: Merge agressivo completado - ", merged_count, " orbs combinadas")

func get_orb_type_by_value(value: int) -> String:
	# Determinar tipo baseado no valor
	if value >= 100:
		return "boss"
	elif value >= 50:
		return "large"
	elif value >= 20:
		return "normal"
	else:
		return "small"

# Função para forçar merge de todas as orbs próximas
func force_merge_all():
	perform_global_merge_check()

# Função para obter estatísticas
func get_orb_stats() -> Dictionary:
	var all_orbs = get_tree().get_nodes_in_group("xp_orbs")
	var total_value = 0
	
	for orb in all_orbs:
		if is_instance_valid(orb):
			total_value += orb.xp_value
	
	return {
		"count": all_orbs.size(),
		"total_value": total_value,
		"max_allowed": max_orbs_on_screen
	}