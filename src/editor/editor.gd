extends Node2D


class HistoryEntryStructuresAdded:
	var grid_positions: Array[Vector2]


@export var StructureScene: PackedScene

#@onready var zooming_module: Node2D = $ZoomingModule
@onready var panning_module: Node2D = $PanningModule
@onready var dragging_module: DraggingModule = $DraggingModule
@onready var multi_selection_module: Node2D = $MultiSelectionModule
@onready var hover_module: HoverModule = $HoverModule

@onready var structures_picker: StructuresPicker = %StructuresPicker

@onready var grid_area: Node2D = %GridArea
@onready var structures: Node2D = %Structures



const STRUCTURES_REQUIRED_TO_ASK_TO_SAVE: int = 10
const GRID_SIZE: Vector2 = Vector2(72, 78)


var structures_selected: Array[Structure]
var structure_hovered: Structure

var history: Array = []



func _ready() -> void:
	grid_area.set_size(GRID_SIZE)
	grid_area.hide_checkerboard()
	structures_picker.set_loadout_index(1)


func _unhandled_input(_event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("delete_selection"):
		__put_selected_structures_in_picker()
		get_viewport().set_input_as_handled()
	
	elif Input.is_action_just_pressed("select_all"):
		__drag_structures(__get_all_structures())
		get_viewport().set_input_as_handled()
	
	if Input.is_action_pressed("undo"):
		__on_undo()
		get_viewport().set_input_as_handled()


func __add_structures(configs: Array[StructureConfigDTO]) -> void:
	
	var history_entry: HistoryEntryStructuresAdded = HistoryEntryStructuresAdded.new()
	
	history.append(history_entry)
	
	for config in configs:
		history_entry.grid_positions.append(config.grid_position)
		__add_structure_no_history(config)


func __add_structure_no_history(config: StructureConfigDTO) -> void:
	var structure: Structure = StructureScene.instantiate()
	structures.add_child(structure)
	structure.structure_id = config.id
	structure.grid_position = config.grid_position
	structure.flipped = config.flipped


func __drag_structures(structures_to_drag: Array[Structure]) -> void:
	
	multi_selection_module.allow_selection = false
	
	structures_selected = structures_to_drag
	
	for structure in structures_to_drag:
		dragging_module.start_dragging_structure(structure.get_config())
	
	structures_picker.block_picking = true


func __stop_dragging() -> void:
	
	var ghosts: Array[StructureGhost] = dragging_module.get_structure_ghosts()
	
	if structures_selected.size() == 0:
		
		# Placing new structures
		
		for ghost in ghosts:
			__add_structures([ghost.get_structure_config()])
		
	else:
		
		for i in structures_selected.size():
			structures_selected[i].grid_position = ghosts[i].grid_area.position
		
		structures_selected = []
	
	dragging_module.clear()
	
	structures_picker.block_picking = false
	multi_selection_module.allow_selection = true


func __try_placing_structures_dragged() -> void:
	
	var ghosts: Array[StructureGhost] = dragging_module.get_structure_ghosts()
	
	var can_place: bool = true
	var structures_to_check: Array[Structure] = __get_all_structures().filter(
		func(structure: Structure):
			return !ghosts.any(
				func(ghost: StructureGhost):
					return structure.grid_area.position == ghost.grid_position_dragging_started
			)
	)
	
	for ghost in ghosts:
		
		var overlapping_structures = GridWizard.get_structures_on_area(
			ghost.grid_area,
			structures_to_check
		)
		
		for overlapping in overlapping_structures:
			overlapping.overlap_bump()
			can_place = false
	
	if can_place:
		__stop_dragging()


func __put_selected_structures_in_picker() -> void:
	
	for structure in structures_selected:
		structures_picker.put(structure.dto.id)
		structure.queue_free()
	
	structures_selected = []
	dragging_module.clear()
	structures_picker.block_picking = false


func __get_all_structures() -> Array[Structure]:
	var all_structures: Array[Structure] = []
	for structure in structures.get_children():
		all_structures.append(structure)
	return all_structures


func __get_loadout_for_layout(layout: LayoutDTO) -> LoadoutDTO:
	
	for loadout_id in Assets.loadouts:
		
		var loadout: LoadoutDTO = Assets.loadouts[loadout_id]
		var valid: bool = true
		
		for structure_id in layout.structures:
			
			if !loadout.structures.has(structure_id):
				valid = false
				break
			
			var count: int = layout.structures[structure_id].size()
			var allowed_count: int = loadout.structures[structure_id]
			
			if count > allowed_count:
				valid = false
				break
		
		if valid:
			return loadout
	
	return null


func __on_undo() -> void:
	
	var entry = history.pop_back()
	
	if entry == null:
		print("nothing to undo")
		return
	
	if entry is HistoryEntryStructuresAdded:
		for grid_position in entry.grid_positions:
			
			var structure = GridWizard.get_structure_on_tile(
				grid_position,
				__get_all_structures()
			)
			
			structures_picker.put(structure.dto.id)
			structure.queue_free()



# Layout transfer

func __import_layout(layout: LayoutDTO) -> void:
	
	# Invalid layout: {"display_name":"Layout","loadout":"star_base_9","structures":{"star_base":[{"flip":false,"x":0,"y":0}, {"flip":true,"x":10,"y":0}]}}
	
	var loadout: LoadoutDTO = __get_loadout_for_layout(layout)
	
	if loadout == null:
		
		var hack = { "cancel_import": true }
		var popup: OkCancelPopup = Popups.ok_cancel()
		
		popup.title = "Invalid Layout"
		popup.message = "Trying to import this layout may cause the application to break"
		popup.ok = "Import Anyway"
		popup.on_ok = func():
			hack.cancel_import = false
		
		await popup.removed
		
		if hack.cancel_import:
			return
		
		loadout = Assets.loadouts.values().back()
	
	structures_picker.set_loadout(loadout)
	
	for structure_id in layout.structures:
		for partial_config in layout.structures[structure_id]:
			structures_picker.decrease_count(structure_id)
			
			var config: StructureConfigDTO = StructureConfigDTO.new()
			
			config.id = structure_id
			config.grid_position = Vector2(partial_config.x, partial_config.y)
			config.flipped = partial_config.flip
			
			__add_structures([config])


func __export_layout() -> LayoutDTO:
	
	var layout: LayoutDTO = LayoutDTO.new()
	
	layout.display_name = "Layout"
	layout.loadout = structures_picker.loadout_id
	
	for structure in __get_all_structures():
		
		var structure_data: Dictionary = {
			"x": structure.grid_area.position.x,
			"y": structure.grid_area.position.y,
			"flip": structure.flipped
		}
		
		if structure.structure_id in layout.structures:
			layout.structures[structure.structure_id].append(structure_data)
		else:
			layout.structures[structure.structure_id] = [structure_data]
	
	return layout


func _on_structures_picker_item_picked(structure_id: String) -> void:
	
	var structure_dto: StructureDTO = Assets.structures[structure_id]
	var tile: Vector2 = hover_module.hovered_tile
	
	if int(structure_dto.size.x) % 2 == 0:
		tile.x -= structure_dto.size.x * 0.5
	if int(structure_dto.size.y) % 2 == 0:
		tile.y -= structure_dto.size.y * 0.5
	
	var config: StructureConfigDTO = StructureConfigDTO.new()
	
	config.id = structure_id
	config.grid_position = tile
	config.flipped = false
	
	dragging_module.start_dragging_structure(config)


func _on_structures_picker_cover_clicked() -> void:
	__put_selected_structures_in_picker()


func _on_structures_picker_loadout_changed() -> void:
	NodeUtils.queue_free_children(structures)


func _on_interaction_hitbox_pressed() -> void:
	
	if panning_module.panning:
		return
	
	if dragging_module.get_structure_ghosts().size() > 0:
		__try_placing_structures_dragged()
	
	elif structure_hovered:
		__drag_structures([structure_hovered])


func _on_import_pressed() -> void:
	
	var popup: OkCancelPopup = Popups.ok_cancel()
	
	var import_layout = func() -> void:
		
		# If the json string it's empty, json error message is empty
		if popup.message == "":
			return
		
		var json = JSON.new()
		var error = json.parse(popup.message)
		
		if error:
			
			var error_popup: OkPopup = Popups.ok()
			error_popup.title = "Failed to import!"
			error_popup.message = "Error at line %s:\n%s" % [json.get_error_line(), json.get_error_message()]
			
		else:
			__import_layout(LayoutDTO.from(json.data))
	
	popup.title = "Paste layout code"
	popup.ok = "Import"
	popup.on_ok = import_layout
	popup.message = ""
	popup.message_editable = true


func _on_export_pressed() -> void:
	
	var layout_code: String = JSON.stringify(__export_layout().to_dictionary())
	var popup: OkCancelPopup = Popups.ok_cancel()
	
	popup.title = "Copy layout code"
	popup.message = layout_code
	popup.ok = "Copy"
	popup.on_ok = func(): DisplayServer.clipboard_set(layout_code)


func _on_multi_selection_module_selecting() -> void:
	pass


func _on_multi_selection_module_selected(selection_rectangle: Rect2) -> void:
	
	var selected_structures = GridWizard.get_structures_on_area(
		selection_rectangle,
		__get_all_structures()
	)
	
	if selected_structures.size():
		__drag_structures(selected_structures)


func _on_hover_module_hovered_tile_changed(hovered_tile: Vector2) -> void:
	structure_hovered = GridWizard.get_structure_on_tile(
		hovered_tile,
		__get_all_structures()
	)
