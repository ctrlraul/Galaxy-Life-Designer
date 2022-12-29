extends Node2D
class_name StructureGhost


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var footprint: Node2D = $StructureFootprint


var grid_area: Rect2
var dto: StructureDTO
var grid_position_dragging_started: Vector2
var flipped: bool :
	set(value):
		sprite_2d.flip_h = value
	get:
		return sprite_2d.flip_h


func set_structure_config(config: StructureConfigDTO) -> void:
	
	dto = Assets.structures.get(config.id)
	
	sprite_2d.texture = dto.texture
	sprite_2d.position = dto.sprite_offset
	sprite_2d.position.y += dto.size.y * Isometry.GRID_TO_WORLD_SCALE * 0.5
	
	footprint.size = dto.size
	
	grid_area.size = dto.size
	
	set_grid_position(config.grid_position)


func set_grid_position(grid_position: Vector2) -> void:
	grid_area.position = grid_position
	position = Isometry.grid_to_world(grid_position)


func get_structure_config() -> StructureConfigDTO:
	var config: StructureConfigDTO = StructureConfigDTO.new()
	
	config.id = dto.id
	config.grid_position = grid_area.position
	config.flipped = flipped
	
	return config
