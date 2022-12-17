extends Node2D
class_name Structure


@onready var sprite_2d = $Sprite2D
@onready var footprint = $Footprint
@onready var footprint_graphic = $Footprint/FootprintGraphic
@onready var animation_player = $AnimationPlayer
@onready var label_container = $LabelContainer
@onready var label = $LabelContainer/Label

var grid_position: Vector2
var size: Vector2
var hovered: bool = false : set = set_hovered


func set_config(config: StructureConfigDTO) -> void:

	position = Isometry.grid_to_world(config.position)
	
	var structure_dto: StructureDTO = Assets.structures[config.id]
	
	sprite_2d.texture = structure_dto.texture
	sprite_2d.flip_h = config.flipped
	sprite_2d.position.y = structure_dto.sprite_offset
	sprite_2d.position.y += structure_dto.size.y * Isometry.GRID_TO_WORLD_SCALE * 0.5
	
	footprint.scale = structure_dto.size
	
	label_container.position.y = structure_dto.size.y * 0.8 * Isometry.GRID_TO_WORLD_SCALE
	label.text = structure_dto.display_name
	
	grid_position = config.position
	size = structure_dto.size

func set_hovered(value: bool) -> void:
	
	if hovered == value:
		return
	
	hovered = value
	
	animation_player.play("hover_on" if hovered else "RESET")
