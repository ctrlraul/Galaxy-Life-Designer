extends Node2D


@export var StructureScene: PackedScene

@onready var structures: Node2D = %Structures
@onready var structures_picker: StructuresPicker = $Interface/StructuresPicker

var hovered_tile: Vector2 = Vector2.ZERO
var hovered_structure: Structure
var drag_offset: Vector2 = Vector2.ZERO
var drag_structure: Structure
var clicking_structure: Structure


func _ready() -> void:
	Assets.initialize()
	structures_picker.set_loadout(Assets.loadouts.values()[0])

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		__update_hover()
		if drag_structure:
			drag_structure.set_grid_position(hovered_tile + drag_offset)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			if event.pressed:
				if !drag_structure:
					clicking_structure = hovered_structure
				elif !hovered_structure:
					stop_drag()
			
			else:
				if hovered_structure && hovered_structure == clicking_structure:
					start_drag(hovered_structure)
					hovered_structure = null
				clicking_structure = null


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

func add_structure(config: StructureConfigDTO) -> Structure:
	var structure: Structure = StructureScene.instantiate()
	structures.add_child(structure)
	structure.set_config(config)
	return structure

func start_drag(structure: Structure) -> void:
	drag_offset = structure.grid_position - hovered_tile
	drag_structure = structure
	structures_picker.block_picking = true

func stop_drag() -> void:
	drag_offset = Vector2.ZERO
	drag_structure = null
	structures_picker.block_picking = false


func __update_hover() -> void:
	
	var world_coords = (get_global_mouse_position() - structures.position)
	hovered_tile = Isometry.world_to_grid(world_coords)
	
	if drag_structure:
		return
	
	var new_hovered_structure = get_structure_on_tile(hovered_tile)
	
	if hovered_structure == new_hovered_structure:
		return
	
	if hovered_structure != null:
		hovered_structure.set_hovered(false)
	
	if new_hovered_structure != null:
		new_hovered_structure.set_hovered(true)
	
	hovered_structure = new_hovered_structure


func _on_structures_picker_item_picked(structure_id: String) -> void:
	var config: StructureConfigDTO = StructureConfigDTO.new()
	config.position = hovered_tile
	config.id = structure_id
	start_drag(add_structure(config))

func _on_structures_picker_cover_clicked() -> void:
	if drag_structure:
		structures_picker.put(drag_structure.structure_id)
		drag_structure.queue_free()
	stop_drag()
