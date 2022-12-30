extends Node2D
class_name HoverModule



signal hovered_tile_changed(relative: Vector2, hovered_tile: Vector2)



@export_node_path(Control) var interaction_hitbox_path: NodePath


@onready var __interaction_hitbox: Control = get_node(interaction_hitbox_path)


var hovered_tile: Vector2 = Vector2.ZERO



func _ready() -> void:
	__interaction_hitbox.gui_input.connect(_on_interaction_hitbox_gui_input)



func _on_interaction_hitbox_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		
		var old_hovered_tile = hovered_tile
		
		hovered_tile = Isometry.world_to_grid(get_global_mouse_position())
		
		if hovered_tile != old_hovered_tile:
			var relative: Vector2 = hovered_tile - old_hovered_tile
			hovered_tile_changed.emit(relative, hovered_tile)
