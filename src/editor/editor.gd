extends Node2D


@export var StructureScene: PackedScene

@onready var panning_module: Node2D = $PanningModule

@onready var structures_picker: StructuresPicker = $Interface/StructuresPicker
@onready var popup: YesNoPopup = %YesNoPopup

@onready var grid_area: Node2D = %GridArea
@onready var structures: Node2D = %Structures
@onready var multi_selection_rectangle: Node2D = %MultiSelectionRectangle


const STRUCTURES_REQUIRED_TO_ASK_TO_SAVE: int = 10
const GRID_SIZE: Vector2 = Vector2(72, 78)

var hovered_tile: Vector2 = Vector2.ZERO
var hovered_structure: Structure

var multi_selecting: bool = false
var multi_selecting_start: Vector2 = Vector2.ZERO

var dragging_structures: Array[Structure] = []
var dragging_structures_offsets: Dictionary = {}


func _ready() -> void:
	grid_area.set_size(GRID_SIZE)
	grid_area.hide_checkerboard()
	structures_picker.set_loadout(Assets.loadouts.values().back())
	multi_selection_rectangle.visible = false

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		__on_mouse_motion()
	
	elif Input.is_action_just_pressed("delete_selection"):
		__try_putting_selected_structures_in_picker()
	
	elif Input.is_action_just_pressed("select_all"):
		var all_structures: Array[Structure] = []
		for structure in structures.get_children():
			all_structures.append(structure)
		start_drag(all_structures)
	
	elif Input.is_action_just_pressed("chain_placing_or_multi_select"):
		if dragging_structures.size():
			__update_chain_placing()
			return
		multi_selecting_start = hovered_tile
		multi_selecting = true
		multi_selection_rectangle.visible = true
		multi_selection_rectangle.position = Isometry.grid_to_world(hovered_tile)
	
	elif Input.is_action_just_released("chain_placing_or_multi_select"):
		
		if dragging_structures.size():
			return
		
		var selection_rectangle = get_rekt(multi_selecting_start, multi_selecting_start + multi_selection_rectangle.size)
		var selected_structures = GridWizard.get_structures_on_area(
			selection_rectangle, __get_all_structures()
		)
			
		if selected_structures.size():
			start_drag(selected_structures)
		multi_selecting = false
		multi_selection_rectangle.visible = false
		multi_selection_rectangle.size = Vector2.ZERO


func get_rekt(a: Vector2, b: Vector2) -> Rect2:
	var x = min(a.x, b.x)
	var y = min(a.y, b.y)
	var w = abs(a.x - b.x)
	var h = abs(a.y - b.y)
	return Rect2(x, y, w, h)


func get_tile_on_mouse() -> Vector2:
	return Isometry.world_to_grid(get_global_mouse_position())

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

func start_drag(structures_to_drag: Array[Structure]) -> void:
	
	dragging_structures.clear()
	dragging_structures_offsets.clear()
	
	for structure in structures_to_drag:
		var offset: Vector2 = structure.grid_position - hovered_tile
		dragging_structures.append(structure)
		dragging_structures_offsets[structure.get_instance_id()] = offset
	
	structures_picker.block_picking = true

func stop_drag() -> void:
	dragging_structures.clear()
	dragging_structures_offsets.clear()
	structures_picker.block_picking = false

func structures_overlap(a: Structure, b: Structure) -> bool:
	
	# Just AABB collision detection
	
	if (a.grid_position.x >= b.grid_position.x + b.size.x ||
		b.grid_position.x >= a.grid_position.x + a.size.x):
		return false
		
	if (a.grid_position.y >= b.grid_position.y + b.size.y ||
		b.grid_position.y >= a.grid_position.y + a.size.y):
		return false

	return true

func get_current_layout() -> LayoutDTO:
	
	var layout: LayoutDTO = LayoutDTO.new()
	
	layout.display_name = "Layout"
	layout.loadout = structures_picker.loadout_id
	
	for structure in structures.get_children():
		layout.structure_configs.append(structure.get_config())
	
	return layout

func try_placing_dragging_structures() -> void:
	
	var can_place: bool = true
	var structures_to_check: Array[Structure] = __get_all_structures().filter(
		func(structure):
			return !dragging_structures.has(structure)
	)
	
	for structure in dragging_structures:
		
		var overlapping_structures = GridWizard.get_structures_on_area(
			structure.grid_area,
			structures_to_check
		)
		
		for overlapping in overlapping_structures:
			overlapping.overlap_bump()
			can_place = false
	
	if can_place:
		stop_drag()

func __import_layout(layout: LayoutDTO) -> void:
	
	structures_picker.set_loadout(Assets.loadouts[layout.loadout])
	
	for config in layout.structure_configs:
		add_structure(config)

func __try_showing_save_last_layout_popup() -> void:
	
	if structures.get_child_count() < STRUCTURES_REQUIRED_TO_ASK_TO_SAVE:
		return
	
	var current_layout: Dictionary = get_current_layout().to_dictionary()
	var current_layout_json: String = JSON.stringify(current_layout)
	
	popup.set_title("Wait a second!")
	popup.set_message("Copy previous layout to clipboard?")
	popup.set_yes(func(): DisplayServer.clipboard_set(current_layout_json))
	popup.show()

func __try_putting_selected_structures_in_picker() -> void:
	
	if dragging_structures.size() == 0:
		return
	
	for structure in dragging_structures:
		structures_picker.put(structure.structure_id)
		structure.queue_free()
	
	stop_drag()

func __on_mouse_motion() -> void:
	
	var old_hovered_tile = hovered_tile
	hovered_tile = get_tile_on_mouse()
	
	if multi_selecting:
		__update_multi_selection()
		return
	
	if hovered_tile != old_hovered_tile:
		__on_hovered_tile_changed()

func __on_hovered_tile_changed() -> void:
	
	var dragging_structures_count: int = dragging_structures.size()
	
	if dragging_structures_count > 0:
		__update_dragging_structures()
		if (dragging_structures_count == 1 &&
			Input.is_action_pressed("chain_placing_or_multi_select")):
			__update_chain_placing()
	
	var old_hovered_structure = hovered_structure
	
	hovered_structure = GridWizard.get_structure_on_tile(
		hovered_tile, __get_all_structures()
	)
	
	if hovered_structure == old_hovered_structure:
		return
		
	if hovered_structure:
		hovered_structure.set_hovered(true)
	
	if old_hovered_structure:
		old_hovered_structure.set_hovered(false)

func __get_all_structures() -> Array[Structure]:
	var all_structures: Array[Structure] = []
	for structure in structures.get_children():
		all_structures.append(structure)
	return all_structures

func __update_chain_placing() -> void:
	var structure_id: String = dragging_structures[0].structure_id
	try_placing_dragging_structures()
	structures_picker.pick(structure_id)

func __update_multi_selection() -> void:
	var difference: Vector2 = multi_selecting_start - hovered_tile
	var size: Vector2 = difference * -1
	if !size.x: size.x = 1
	if !size.y: size.y = 1
	multi_selection_rectangle.size = size
	multi_selection_rectangle.position = Isometry.grid_to_world(hovered_tile + difference)

func __update_dragging_structures() -> void:
	for structure in dragging_structures:
		var offset: Vector2 = dragging_structures_offsets[structure.get_instance_id()]
		structure.set_grid_position(hovered_tile + offset)

func __on_drag_control_pressed() -> void: # NOT A SIGNAL
	
	if dragging_structures.size():
		try_placing_dragging_structures()
		return
	
	if hovered_structure:
		start_drag([hovered_structure])


func _on_structures_picker_item_picked(structure_id: String) -> void:
	
	var config: StructureConfigDTO = StructureConfigDTO.new()
	var structure_dto: StructureDTO = Assets.structures[structure_id]
	
	config.position = hovered_tile
	config.id = structure_id
	
	if int(structure_dto.size.x) % 2 == 0:
		config.position.x -= structure_dto.size.x * 0.5
	if int(structure_dto.size.y) % 2 == 0:
		config.position.y -= structure_dto.size.y * 0.5
	
	start_drag([add_structure(config)])

func _on_structures_picker_cover_clicked() -> void:
	__try_putting_selected_structures_in_picker()

func _on_structures_picker_before_loadout_change() -> void:
	__try_showing_save_last_layout_popup()
	NodeUtils.queue_free_children(structures)

func _on_interaction_hitbox_pressed() -> void:
	
	if dragging_structures.size():
		try_placing_dragging_structures()
		return
	
	if hovered_structure && !panning_module.panning:
		start_drag([hovered_structure])
