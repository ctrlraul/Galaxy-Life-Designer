extends Node2D


@export var StructureScene: PackedScene

@onready var structures: Node2D = $Structures
@onready var structures_picker: StructuresPicker = $Interface/StructuresPicker

var hovered_tile: Vector2
var hovered_structure: Structure


func _ready() -> void:
	Assets.initialize()
	import_layout(Assets.layouts[0])

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		__update_hover()


func __update_hover() -> void:
	
	var world_coords = (get_global_mouse_position() - structures.position)
	hovered_tile = Isometry.world_to_grid(world_coords)
	var new_hovered_structure = get_structure_on_tile(hovered_tile)
	
	if hovered_structure == new_hovered_structure:
		return
	
	if hovered_structure != null:
		hovered_structure.set_hovered(false)
	
	if new_hovered_structure != null:
		new_hovered_structure.set_hovered(true)
	
	hovered_structure = new_hovered_structure


func get_structure_on_tile(tile: Vector2) -> Structure:
	for structure in structures.get_children():
		
		var structure_tile_min = structure.grid_position
		var structure_tile_max = structure_tile_min + structure.size
		
		if (tile.x >= structure_tile_min.x &&
			tile.x <= structure_tile_max.x &&
			tile.y >= structure_tile_min.y &&
			tile.y <= structure_tile_max.y):
			return structure
	
	return null

func get_structure_next_to_mouse() -> Structure:
	
	var mouse = get_global_mouse_position()
	var nearest: Structure = null
	var nearest_distance: float  = INF
	
	for structure in structures.get_children():
		var distance = mouse.distance_to(structure.get_global_footprint_center())
		if distance < nearest_distance:
			nearest = structure
			nearest_distance = distance
	
	return nearest

func import_layout(layout: LayoutDTO) -> void:
	var loadout = Assets.loadouts[layout.loadout]
	structures_picker.set_loadout(loadout)
	for config in layout.structure_configs:
		add_structure(config)

func add_structure(config: StructureConfigDTO) -> void:
	var structure: Structure = StructureScene.instantiate()
	structures.add_child(structure)
	structure.set_config(config)
	structures_picker.pick(config.id)
