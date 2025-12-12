extends Node
class_name PerformanceMonitor

# Monitor de performance para o debug

var frame_times: Array[float] = []
var max_frame_history: int = 60  # Manter histórico de 60 frames
var cpu_usage_history: Array[float] = []
var memory_usage_history: Array[int] = []

func _ready():
	# Configurar processo
	set_process(true)

func _process(delta):
	# Registrar tempo do frame
	record_frame_time(delta)
	
	# Registrar uso de memória periodicamente
	if Engine.get_process_frames() % 30 == 0:  # A cada 30 frames
		record_memory_usage()

func record_frame_time(delta: float):
	frame_times.append(delta)
	
	# Manter apenas o histórico necessário
	if frame_times.size() > max_frame_history:
		frame_times.pop_front()

func record_memory_usage():
	var memory = OS.get_static_memory_peak_usage()
	memory_usage_history.append(memory)
	
	# Manter apenas o histórico necessário
	if memory_usage_history.size() > max_frame_history:
		memory_usage_history.pop_front()

func get_average_fps() -> float:
	if frame_times.is_empty():
		return 0.0
	
	var total_time = 0.0
	for time in frame_times:
		total_time += time
	
	return frame_times.size() / total_time

func get_min_fps() -> float:
	if frame_times.is_empty():
		return 0.0
	
	var max_time = frame_times.max()
	return 1.0 / max_time if max_time > 0 else 0.0

func get_max_fps() -> float:
	if frame_times.is_empty():
		return 0.0
	
	var min_time = frame_times.min()
	return 1.0 / min_time if min_time > 0 else 0.0

func get_frame_time_ms() -> float:
	if frame_times.is_empty():
		return 0.0
	
	return frame_times[-1] * 1000.0

func get_average_frame_time_ms() -> float:
	if frame_times.is_empty():
		return 0.0
	
	var total_time = 0.0
	for time in frame_times:
		total_time += time
	
	return (total_time / frame_times.size()) * 1000.0

func get_memory_usage_mb() -> float:
	if memory_usage_history.is_empty():
		return 0.0
	
	return memory_usage_history[-1] / (1024.0 * 1024.0)

func get_performance_summary() -> Dictionary:
	return {
		"current_fps": Engine.get_frames_per_second(),
		"average_fps": get_average_fps(),
		"min_fps": get_min_fps(),
		"max_fps": get_max_fps(),
		"frame_time_ms": get_frame_time_ms(),
		"avg_frame_time_ms": get_average_frame_time_ms(),
		"memory_mb": get_memory_usage_mb(),
		"total_frames": Engine.get_process_frames()
	}