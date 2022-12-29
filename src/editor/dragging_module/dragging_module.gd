extends Node2D
class_name DraggingModule



@export var StructureGhostScene: PackedScene

@export_node_path(StructuresPicker) var structures_picker_path: NodePath
@export_node_path(Node) var hover_module_path: NodePath

@onready var __structures_picker: StructuresPicker = get_node(structures_picker_path)
@onready var __hover_module: HoverModule = get_node(hover_module_path)
@onready var __ghosts_container: Node2D = $GhostsContainer



func _ready() -> void:
	__hover_module.hovered_tile_changed.connect(_on_hover_module_hovered_tile_changed)


func start_dragging_structure(config: StructureConfigDTO) -> void:
	
	var ghost: StructureGhost = StructureGhostScene.instantiate()
	
	__ghosts_container.add_child(ghost)
	
	ghost.set_structure_config(config)
	ghost.grid_position_dragging_started = config.grid_position


func clear() -> void:
	NodeUtils.queue_free_children(__ghosts_container)


func get_structure_ghosts() -> Array[StructureGhost]:
	
	var ghosts: Array[StructureGhost] = []
	
	for ghost in __ghosts_container.get_children():
		ghosts.append(ghost)
	
	return ghosts



func __update_structures_dragged(hovered_tile: Vector2) -> void:
	for ghost in get_structure_ghosts():
		ghost.set_grid_position(hovered_tile)


func __chain_place_structures() -> void:
	var structure_id: String = get_structure_ghosts().front().dto.id
	__try_placing_structures_dragged()
	__structures_picker.pick(structure_id)


func __try_placing_structures_dragged() -> void:
	pass


func _on_hover_module_hovered_tile_changed(hovered_tile: Vector2) -> void:
	
	var dragging_structures_count: int = get_structure_ghosts().size()
	
	if dragging_structures_count > 0:
		__update_structures_dragged(hovered_tile)
		if Input.is_action_pressed("chain_placing_or_multi_select"):
			__chain_place_structures()
