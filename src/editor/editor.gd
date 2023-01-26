extends Node2D



@export var StructureScene: PackedScene

#@onready var zooming_module: Node2D = $ZoomingModule
@onready var panning_module: Node2D = $PanningModule
@onready var dragging_module: DraggingModule = $DraggingModule
@onready var multi_selection_module: Node2D = $MultiSelectionModule
@onready var hover_module: HoverModule = $HoverModule

@onready var __import_button: Button = %Import
@onready var __export_button: Button = %Export
@onready var structures_picker: StructuresPicker = %StructuresPicker

@onready var grid_area: Node2D = %GridArea
@onready var structures: Node2D = %Structures
@onready var radius_displayer: Node2D = %RadiusDisplayer
@onready var __grid_highlighter = %GridHighlighter
@onready var rotate_axis_button: Button = %RotateAxis



const STRUCTURES_REQUIRED_TO_ASK_TO_SAVE: int = 10
const GRID_SIZE: Vector2 = Vector2(72, 78)

var thread: Thread = null

var structures_dragged: Array[Structure]
var structure_hovered: Structure

var history: ActionHistory = ActionHistory.new(256)
var history_logger: Logger = Logger.new("ActionHistory")

# Can easily extract grid highlighter into a module
var __grid_highlighter_enabled: bool = false



func _ready() -> void:

	__grid_highlighter.visible = __grid_highlighter_enabled

	grid_area.set_size(GRID_SIZE)
	grid_area.set_checkerboard(false)
	grid_area.set_border_color(Color.TRANSPARENT)

	structures_picker.set_loadout_index(8)


func _unhandled_input(_event: InputEvent) -> void:

	if Input.is_action_just_pressed("delete_selection"):

		if structures_dragged.size():
			__remove_structures_dragged()
		else:
			__clear_dragged_structures()

		get_viewport().set_input_as_handled()

	elif Input.is_action_just_pressed("cancel"):
		__clear_dragged_structures()
		get_viewport().set_input_as_handled()

	elif Input.is_action_just_pressed("select_all"):
		if dragging_module.is_dragging():
			__clear_dragged_structures()
		__drag_structures(__get_all_structures())
		get_viewport().set_input_as_handled()

	elif Input.is_action_pressed("undo"):
		__history_undo()
		get_viewport().set_input_as_handled()


func _exit_tree():
	if thread != null:
		thread.wait_to_finish()



func __place_structure(config: StructureConfigDTO) -> void:

	# Call __update_y_sort() afterwards

	var structure: Structure = StructureScene.instantiate()

	structures.add_child(structure)
	structure.set_structure(config.id, structures_picker.get_level(config.id))

	structure.grid_position = config.grid_position
	structure.flipped = config.flipped


func __drag_structures(structures_to_drag: Array[Structure]) -> void:

	structures_dragged.append_array(structures_to_drag)

	for structure in structures_to_drag:

		structure.set_dragged(true)

		var config: StructureConfigDTO = structure.get_config()

		dragging_module.add_structure_ghost(
			config,
			structures_picker.get_level(config.id)
		)

	__set_left_side_interface_disabled(true)
	multi_selection_module.allow_selection = false

	if structure_hovered:
		structure_hovered.set_hovered(false)
		structure_hovered = null


func __set_left_side_interface_disabled(value: bool) -> void:
	structures_picker.block_picking = value
	__import_button.disabled = value
	__export_button.disabled = value


func __place_dragged_structures() -> void:

	var ghosts: Array[StructureGhost] = dragging_module.get_structure_ghosts()

	if structures_dragged.size() == 0:
		__add_structures_from_ghosts(ghosts)
	else:
		__move_structures_to_ghost_position(ghosts)


func __clear_dragged_structures() -> void:

	for structure in structures_dragged:
		structure.set_dragged(false)

	structures_dragged.clear()
	dragging_module.clear()

	__set_left_side_interface_disabled(false)

	__update_hovered_structure(hover_module.hovered_tile)

	await get_tree().create_timer(0.1).timeout # HACK, FIX LATER.

	multi_selection_module.allow_selection = true


func __can_place_structures_dragged(ghosts: Array[StructureGhost]) -> bool:

	var can_place: bool = true
	var structures_to_check: Array[Structure] = __get_all_structures().filter(__filter_not_dragged)

	for ghost in ghosts:

		var overlapping_structures = GridWizard.get_structures_on_area(
			ghost.grid_area,
			structures_to_check
		)

		for overlapping in overlapping_structures:
			overlapping.overlap_bump()
			can_place = false

	return can_place


func __try_placing_structures_dragged() -> void:
	var ghosts: Array[StructureGhost] = dragging_module.get_structure_ghosts()
	if __can_place_structures_dragged(ghosts):
		__place_dragged_structures()
		__clear_dragged_structures()


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
			var allowed_count: int = loadout.structures[structure_id].count

			if count > allowed_count:
				valid = false
				break

		if valid:
			return loadout

	return null


func __history_undo() -> void:

	var entry = history.last()

	if entry == null:
		history_logger.info("Nothing to undo")
		return

	if entry is ActionHistory.StructuresAdded:
		history_logger.info("Undo structures added: %s" % str(entry.grid_positions))
		for grid_position in entry.grid_positions:

			var structure = GridWizard.get_structure_on_tile(
				grid_position,
				__get_all_structures()
			)

			if structure in structures_dragged:
				structures_dragged.erase(structure)

			structures_picker.put(structure.dto.id)
			structure.queue_free()

	elif entry is ActionHistory.StructuresMoved:
		history_logger.info("Undo structures moved")
		for i in entry.grid_positions_from.size():

			var from_tile: Vector2 = entry.grid_positions_from[i]
			var to_tile: Vector2 = entry.grid_positions_to[i]
			var structure = GridWizard.get_structure_on_tile(
				to_tile,
				__get_all_structures()
			)

			if structure:
				structure.grid_position = from_tile
			else:
				history_logger.error("Undo error: No structure at %s" % to_tile)

		__update_y_sort()

	elif entry is ActionHistory.StructuresRemoved:
		history_logger.info("Undo structures removed")
		for config in entry.structure_configs:
			__place_structure(config)
			structures_picker.decrease_count(config.id)
		__update_y_sort()


func __stop_dragging_structure(ghost: StructureGhost) -> void:

	dragging_module.remove_structure_ghost(ghost)

	var structure: Structure = GridWizard.get_structure_on_tile(ghost.grid_position_dragging_started, __get_all_structures())

	if structure != null:
		structures_dragged.erase(structure)

	if !dragging_module.is_dragging():
		__clear_dragged_structures()


func __try_to_chain_place_structures() -> void:

	var ghosts: Array[StructureGhost] = dragging_module.get_structure_ghosts()

	if !__can_place_structures_dragged(ghosts):
		return

	__place_dragged_structures()

	for ghost in ghosts:
		var config: StructureConfigDTO = ghost.get_structure_config()
		if structures_picker.get_count(config.id) <= 0:
			__stop_dragging_structure(ghost)


func __filter_not_dragged(structure: Structure) -> bool:
	return !structures_dragged.has(structure)


func __update_hovered_structure(hovered_tile: Vector2) -> void:

	var old_structure_hovered: Structure = structure_hovered

	structure_hovered = GridWizard.get_structure_on_tile(
		hovered_tile,
		__get_all_structures()
	)

	if structure_hovered == old_structure_hovered:
		return

	if is_instance_valid(old_structure_hovered):
		old_structure_hovered.set_hovered(false)

	if structure_hovered:
		structure_hovered.set_hovered(true)

	__on_structure_hovered_changed()


func __on_structure_hovered_changed() -> void:
	radius_displayer.set_for(structure_hovered)


func __update_y_sort() -> void:

	var structures_to_sort = __get_all_structures()

	structures_to_sort.sort_custom(
		func(a, b):
			return a.tactical_view.global_position.y < b.tactical_view.global_position.y
	)

	for i in structures_to_sort.size():
		structures.move_child(structures_to_sort[i], i)


func __get_collective_center(structures_or_ghosts: Array) -> Vector2:

	var min_corner: Vector2 = Vector2(INF, INF)
	var max_corner: Vector2 = Vector2(-INF, -INF)

	for structure in structures_or_ghosts:
		min_corner.x = min(min_corner.x, structure.grid_position.x)
		min_corner.y = min(min_corner.y, structure.grid_position.y)
		max_corner.x = max(max_corner.x, structure.grid_position.x + structure.grid_area.size.x)
		max_corner.y = max(max_corner.y, structure.grid_position.y + structure.grid_area.size.y)

	var collective_area: Rect2 = Rect2(min_corner, max_corner)
	var collective_center = collective_area.position + round((collective_area.size - collective_area.position) * 0.5)

	return collective_center



# Layout transfer

func __import_layout(layout: LayoutDTO) -> void:

	# Invalid layout:
	# {"display_name":"Layout","loadout":"star_base_9","structures":{"star_base":[{"flip":false,"x":0,"y":0}, {"flip":true,"x":10,"y":0}]}}

	NodeUtils.queue_free_children(structures)

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

			__place_structure.call_deferred(config)

	__update_y_sort.call_deferred()


func __export_layout() -> LayoutDTO:

	var layout: LayoutDTO = LayoutDTO.new()

	layout.display_name = "Layout"
	layout.loadout = structures_picker.loadout.id

	for structure in __get_all_structures():

		var structure_data: Dictionary = {
			"x": structure.grid_area.position.x,
			"y": structure.grid_area.position.y,
			"flip": structure.flipped
		}

		if structure.dto.id in layout.structures:
			layout.structures[structure.dto.id].append(structure_data)
		else:
			layout.structures[structure.dto.id] = [structure_data]

	return layout



# Actions with history

func __add_structures_from_ghosts(ghosts: Array[StructureGhost]) -> void:

	var history_entry: ActionHistory.StructuresAdded = ActionHistory.StructuresAdded.new()

	for ghost in ghosts:
		var config: StructureConfigDTO = ghost.get_structure_config()
		if structures_picker.decrease_count(config.id):
			history_entry.grid_positions.append(config.grid_position)
			__place_structure(config)

	if history_entry.grid_positions.size() > 0:
		history.add(history_entry)

	__update_y_sort()


func __move_structures_to_ghost_position(ghosts: Array[StructureGhost]) -> void:

	var entry: ActionHistory.StructuresMoved = ActionHistory.StructuresMoved.new()

	for i in structures_dragged.size():

		var structure = structures_dragged[i]
		var ghost = ghosts[i]

		if structure.grid_position != ghost.grid_area.position:
			entry.grid_positions_from.append(structure.grid_position)
			entry.grid_positions_to.append(ghost.grid_area.position)
			structure.grid_position = ghost.grid_area.position

		structure.set_dragged(false)

	structures_dragged.clear()

	if entry.grid_positions_from.size() > 0:
		history.add(entry)
		__update_y_sort()


func __remove_structures_dragged() -> void:

	var entry: ActionHistory.StructuresRemoved = ActionHistory.StructuresRemoved.new()

	for ghost in dragging_module.get_structure_ghosts():

		var structure: Structure = GridWizard.get_structure_on_tile(
			ghost.grid_position_dragging_started,
			__get_all_structures()
		)

		#if structure && !structure.is_queued_for_deletion():
		if structure && structure.dto.id == ghost.dto.id:
			entry.structure_configs.append(structure.get_config())
			structures_picker.put(structure.dto.id)
			structure.queue_free()

	__clear_dragged_structures()

	if entry.structure_configs.size() > 0:
		history.add(entry)



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

	dragging_module.add_structure_ghost(config, structures_picker.get_level(config.id))

	__set_left_side_interface_disabled(true)
	multi_selection_module.allow_selection = false


func _on_structures_picker_cover_clicked() -> void:
	__remove_structures_dragged()


func _on_structures_picker_loadout_changed(old_loadout: LoadoutDTO) -> void:

	history.clear()

	var new_loadout: LoadoutDTO = structures_picker.loadout
	var all_structures: Array[Structure] = __get_all_structures()

	if old_loadout == null:
		return

	for structure_id in old_loadout.structures:

		# Room for optimization using a map
		var structures_with_id: Array[Structure] = all_structures.filter(
			func(structure: Structure):
				return structure.dto.id == structure_id
		)

		if !(structure_id in new_loadout.structures):
			for structure in structures_with_id:
				structure.queue_free()
			continue

		var structure_setting: Dictionary = new_loadout.structures.get(structure_id)

		while structures_with_id.size() > structure_setting.count:
			var extra_structure = structures_with_id.pop_back()
			extra_structure.queue_free()

		for structure in structures_with_id:
			structure.set_level(structure_setting.level)

		structures_picker.set_count(
			structure_id,
			structure_setting.count - structures_with_id.size()
		)


func _on_interaction_hitbox_pressed() -> void:

	if panning_module.panning:
		return

	if dragging_module.is_dragging():
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
			var layout = LayoutDTO.from(json.data)
			__import_layout(layout)

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


func _on_hover_module_hovered_tile_changed(_relative: Vector2, hovered_tile: Vector2) -> void:

	if !Input.is_action_pressed("chain_placing"):
		__update_hovered_structure(hovered_tile)

	if __grid_highlighter_enabled:
		if dragging_module.is_dragging():
			__grid_highlighter.visible = true
			__grid_highlighter.position = Isometry.grid_to_world(hovered_tile)
		else:
			__grid_highlighter.visible = false


func _on_dragging_module_try_to_chain_place_structures() -> void:
	__try_to_chain_place_structures()


func _on_interaction_hitbox_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("chain_placing"):
		get_viewport().set_input_as_handled()
		__try_to_chain_place_structures()


func _on_help_pressed() -> void:

	var popup: OkPopup = Popups.ok()

	popup.title = "Help"
	popup.min_width = 512
	popup.message_min_height = 148
	popup.message = (
		"Ctrl + A = Select All\n" +
		"Ctrl + Z = Undo\n" +
		"Esc = Cancel moving or placing\n" +
		"Delete = Remove things being moved\n" +
		"Shift / Right Mouse Button = Multi-Selection or Chain-Placing\n" +
		"\n" +
		"ctrl-raul#9419"
	)


func _on_tactical_view_toggle_toggled(button_pressed: bool) -> void:

	UserOptions.change(
		func(options: UserOptions.OptionsData):
			options.tactical_view = button_pressed
	)

	grid_area.set_checkerboard(button_pressed)


func _on_rotate_axis_pressed() -> void:

	var structures_or_ghosts: Array

	if dragging_module.is_dragging():
		structures_or_ghosts = dragging_module.get_structure_ghosts()
	else:
		structures_or_ghosts = __get_all_structures()

	if structures_or_ghosts.size() <= 1:
		return

	var collective_center: Vector2 = __get_collective_center(structures_or_ghosts)

	for structure in structures_or_ghosts:
		var x: int = structure.grid_position.x
		structure.grid_position.x = structure.grid_position.y
		structure.grid_position.y = x

	var offset: Vector2 = collective_center - __get_collective_center(structures_or_ghosts)

	for structure in structures_or_ghosts:
		structure.grid_position += offset
