extends Node2D



signal selecting()
signal selected(selection_rectangle: Rect2)


@export_node_path(Control) var interaction_hitbox_path: NodePath
@export_node_path(Node) var hover_module_path: NodePath

@onready var __multi_selection_rectangle: GridAreaMarker = %MultiSelectionRectangle
@onready var __interaction_hitbox: Control = get_node(interaction_hitbox_path)
@onready var __hover_module: HoverModule = get_node(hover_module_path)


var __logger: Logger = Logger.new("MultiSelectionModule")
var __multi_selection_start_tile: Vector2
var __multi_selecting: bool = false

var allow_selection: bool = true



func _ready() -> void:
	__interaction_hitbox.gui_input.connect(_on_interaction_hitbox_gui_input)
	__multi_selection_rectangle.visible = false
	__multi_selection_rectangle.set_color(Color.TRANSPARENT)



func __multi_selection_start() -> void:

	__logger.info("Selecting...")

	__multi_selection_start_tile = __hover_module.hovered_tile
	__multi_selecting = true
	__multi_selection_rectangle.visible = true
	__multi_selection_rectangle.size = Vector2.ONE
	__multi_selection_rectangle.position = Isometry.grid_to_world(__hover_module.hovered_tile)

	selecting.emit()


func __multi_selection_stop() -> void:

	var selection_rectangle = Rect2(
		__multi_selection_start_tile,
		__multi_selection_rectangle.size
	).abs()

	__multi_selecting = false
	__multi_selection_rectangle.visible = false
	__multi_selection_rectangle.size = Vector2.ZERO

	__logger.info("Selected rect: %s" % selection_rectangle)

	selected.emit(selection_rectangle)


func __update_multi_selection() -> void:

	var difference: Vector2 = __multi_selection_start_tile - __hover_module.hovered_tile
	var size: Vector2 = difference * -1

	if !size.x:
		size.x = 1

	if !size.y:
		size.y = 1

	__multi_selection_rectangle.size = size
	__multi_selection_rectangle.position = Isometry.grid_to_world(__hover_module.hovered_tile + difference)


func _on_interaction_hitbox_gui_input(event: InputEvent) -> void:

	if !allow_selection:
		return

	if event is InputEventMouseMotion:
		if __multi_selecting:
			__update_multi_selection()
			get_viewport().set_input_as_handled()

	elif Input.is_action_just_pressed("multi_selection"):
		__multi_selection_start()
		get_viewport().set_input_as_handled()

	elif Input.is_action_just_released("multi_selection"):
		if __multi_selecting:
			__multi_selection_stop()
			get_viewport().set_input_as_handled()
