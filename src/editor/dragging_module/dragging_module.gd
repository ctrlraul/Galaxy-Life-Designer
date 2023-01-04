extends Node2D
class_name DraggingModule



signal try_to_chain_place_structures()



@export var StructureGhostScene: PackedScene

@export_node_path(Node) var hover_module_path: NodePath

@onready var __hover_module: HoverModule = get_node(hover_module_path)
@onready var __ghosts_container: Node2D = $GhostsContainer



func _ready() -> void:
	__hover_module.hovered_tile_changed.connect(_on_hover_module_hovered_tile_changed)


func add_structure_ghost(config: StructureConfigDTO, level: int) -> void:
	
	var ghost: StructureGhost = StructureGhostScene.instantiate()
	
	__ghosts_container.add_child(ghost)
	
	ghost.set_structure_config(config, level)
	ghost.grid_position_dragging_started = config.grid_position


func remove_structure_ghost(ghost: StructureGhost) -> void:
	__ghosts_container.remove_child(ghost)
	ghost.queue_free()


func clear() -> void:
	__ghosts_container.get_children().map(remove_structure_ghost)


func get_structure_ghosts() -> Array[StructureGhost]:
	
	var ghosts: Array[StructureGhost] = []
	
	for ghost in __ghosts_container.get_children():
		ghosts.append(ghost)
	
	return ghosts


func is_dragging() -> bool:
	return __ghosts_container.get_child_count() > 0



func __update_structures_dragged(relative: Vector2) -> void:
	for ghost in get_structure_ghosts():
		ghost.grid_position += relative


func _on_hover_module_hovered_tile_changed(relative: Vector2, _hovered_tile: Vector2) -> void:
	if get_structure_ghosts().size() > 0:
		__update_structures_dragged(relative)
		if Input.is_action_pressed("chain_placing"):
			try_to_chain_place_structures.emit()
