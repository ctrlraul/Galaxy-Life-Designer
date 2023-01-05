extends Node2D
class_name StructureGhost


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var grid_area_marker: Node2D = $GridAreaMarker


var grid_area: Rect2
var dto: StructureDTO
var grid_position_dragging_started: Vector2

var flipped: bool :
	set(value):
		sprite_2d.flip_h = value
	get:
		return sprite_2d.flip_h

var grid_position: Vector2 :
	set(value):
		grid_area.position = value
		position = Isometry.grid_to_world(value)
	get:
		return grid_area.position



func set_structure_config(config: StructureConfigDTO, level: int) -> void:
	
	dto = Assets.structures.get(config.id)
	
	sprite_2d.texture = Assets.get_structure_level_property(dto, level, "texture")
	sprite_2d.position = Assets.get_structure_level_property(dto, level, "offset")
	sprite_2d.position.y += dto.size.y * Isometry.GRID_TO_WORLD_SCALE * 0.5
	
	grid_area_marker.size = dto.size
	
	grid_area.size = dto.size
	grid_position = config.grid_position


func get_structure_config() -> StructureConfigDTO:
	var config: StructureConfigDTO = StructureConfigDTO.new()
	
	config.id = dto.id
	config.grid_position = grid_area.position
	config.flipped = flipped
	
	return config
