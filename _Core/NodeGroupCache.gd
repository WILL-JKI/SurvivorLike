extends Node
# Sistema de cache para grupos de nós - otimização de performance

# Cache dos grupos mais usados
var cached_groups: Dictionary = {}
var cache_timers: Dictionary = {}
var cache_duration: float = 0.1  # Cache por 100ms

func _ready():
	# Configurar como singleton
	set_process(true)

func _process(delta):
	# Limpar cache expirado
	for group_name in cache_timers.keys():
		cache_timers[group_name] -= delta
		if cache_timers[group_name] <= 0:
			cached_groups.erase(group_name)
			cache_timers.erase(group_name)

func get_nodes_in_group_cached(group_name: String) -> Array:
	# Retornar cache se válido
	if cached_groups.has(group_name):
		return cached_groups[group_name]
	
	# Buscar e cachear
	var nodes = get_tree().get_nodes_in_group(group_name)
	cached_groups[group_name] = nodes
	cache_timers[group_name] = cache_duration
	
	return nodes

func get_group_size_cached(group_name: String) -> int:
	return get_nodes_in_group_cached(group_name).size()

func invalidate_cache(group_name: String = ""):
	if group_name.is_empty():
		cached_groups.clear()
		cache_timers.clear()
	else:
		cached_groups.erase(group_name)
		cache_timers.erase(group_name)