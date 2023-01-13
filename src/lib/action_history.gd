extends Node
class_name ActionHistory


class StructuresAdded:
	var grid_positions: Array[Vector2]

class StructuresMoved:
	var grid_positions_from: Array[Vector2]
	var grid_positions_to: Array[Vector2]

class StructuresRemoved:
	var structure_configs: Array[StructureConfigDTO]


var __stack: Array = []
var __max_length: int = 0


func _init(max_length: int) -> void:
	__max_length = max_length


func add(entry) -> void:
	__stack.append(entry)
	if __stack.size() > __max_length:
		__stack.pop_front()


func last():
	return __stack.pop_back()


func clear() -> void:
	__stack.clear()
