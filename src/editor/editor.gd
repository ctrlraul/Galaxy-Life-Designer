extends Node2D


@export var StructureScene: PackedScene

@onready var structures: Node2D = %Structures
@onready var structures_picker: StructuresPicker = $Interface/StructuresPicker
@onready var drag_control: Button = %DragControl
@onready var camera_2d: Camera2D = $Camera2D
@onready var center: Control = $Interface/Center


const VECTOR2_INF: Vector2 = Vector2(INF, INF)

var hovered_tile: Vector2 = Vector2.ZERO
var hovered_structure: Structure

var drag_offset: Vector2 = Vector2.ZERO
var drag_structure: Structure
var drag_structure_overlaps: Array[Structure]

var zoom_step: float = 0.05
var zoom_min: Vector2 = Vector2(0.5, 0.5)
var zoom_max: Vector2 = Vector2(3, 3)
var panning: bool
var pan_start: Vector2 = VECTOR2_INF
var click_pan_tolerance: float = 10


func _ready() -> void:
	structures_picker.set_loadout(Assets.loadouts.values()[0])

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		__on_mouse_motion()
		if panning:
			camera_2d.position -= event.relative / camera_2d.zoom

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			__zoom(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			__zoom(-1)

func __zoom(delta: int) -> void:
	
	var mouse = center.get_local_mouse_position()
	var old_zoom = Vector2(1, 1) / camera_2d.zoom
	var new_zoom = clamp(old_zoom - delta * zoom_step * old_zoom, zoom_min, zoom_max)
	var zoom_difference = old_zoom - new_zoom
	
	camera_2d.zoom = Vector2(1, 1) / new_zoom
	camera_2d.position += mouse * zoom_difference


func get_tile_on_mouse() -> Vector2:
	return Isometry.world_to_grid(get_global_mouse_position())

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
	drag_control.mouse_default_cursor_shape = Control.CURSOR_MOVE

func stop_drag() -> void:
	drag_offset = Vector2.ZERO
	drag_structure = null
	structures_picker.block_picking = false
	drag_control.mouse_default_cursor_shape = Control.CURSOR_ARROW

func get_overlapping_structures(a: Structure) -> Array[Structure]:
	
	var overlapping_structures: Array[Structure] = []
	
	for b in structures.get_children():
		if a != b && structures_overlap(a, b):
			overlapping_structures.append(b)
	
	return overlapping_structures

func structures_overlap(a: Structure, b: Structure) -> bool:
	
	# Just AABB collision detection
	
	if (a.grid_position.x >= b.grid_position.x + b.size.x ||
		b.grid_position.x >= a.grid_position.x + a.size.x):
		return false
		
	if (a.grid_position.y >= b.grid_position.y + b.size.y ||
		b.grid_position.y >= a.grid_position.y + a.size.y):
		return false

	return true

func __on_mouse_motion() -> void:
	
	var old_hovered_tile = hovered_tile
	var old_hovered_structure = hovered_structure
	
	hovered_tile = get_tile_on_mouse()
	hovered_structure = get_structure_on_tile(hovered_tile)
	
	if hovered_tile != old_hovered_tile:
		if drag_structure:
			__update_dragged_structure()
	
	if drag_structure: # Don't update hover states when dragging a structure
		return
	
	if hovered_structure == old_hovered_structure:
		return
	
	if hovered_structure:
		hovered_structure.set_hovered(true)
	
	if old_hovered_structure:
		old_hovered_structure.set_hovered(false)

func __update_dragged_structure() -> void:
	drag_structure.set_grid_position(hovered_tile + drag_offset)
	drag_structure_overlaps = get_overlapping_structures(drag_structure)

func __on_drag_control_pressed() -> void: # NOT A SIGNAL
	
	if drag_structure:
		if drag_structure_overlaps.size() > 0:
			for overlapping_structure in drag_structure_overlaps:
				overlapping_structure.overlap_bump()
		else:
			stop_drag()
		return
	
	if hovered_structure:
		start_drag(hovered_structure)


func _on_structures_picker_item_picked(structure_id: String) -> void:
	var config: StructureConfigDTO = StructureConfigDTO.new()
	var structure_dto: StructureDTO = Assets.structures[structure_id]
	config.position = hovered_tile - structure_dto.size * 0.5
	config.id = structure_id
	start_drag(add_structure(config))

func _on_structures_picker_cover_clicked() -> void:
	if drag_structure:
		structures_picker.put(drag_structure.structure_id)
		drag_structure.queue_free()
	stop_drag()

func _on_drag_control_button_down() -> void:
	panning = true
	pan_start = drag_control.get_local_mouse_position()

func _on_drag_control_button_up() -> void:
	panning = false
	if pan_start.distance_to(drag_control.get_local_mouse_position()) <= click_pan_tolerance:
		__on_drag_control_pressed()
