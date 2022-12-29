extends Node2D
class_name Structure


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var footprint: Node2D = $StructureFootprint
@onready var animation_player = $AnimationPlayer
@onready var label_container = $LabelContainer
@onready var label = $LabelContainer/Label


var hovered: bool = false : set = set_hovered
var grid_area: Rect2

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

var dto: StructureDTO
var structure_id: String :
	set(value):
		dto = Assets.structures[value]
		
		sprite_2d.texture = dto.texture
		sprite_2d.position = dto.sprite_offset
		sprite_2d.position.y += dto.size.y * Isometry.GRID_TO_WORLD_SCALE * 0.5
		
		footprint.size = dto.size
		
		label_container.position.y = dto.size.y * Isometry.GRID_TO_WORLD_SCALE * 0.75
		label.text = dto.display_name
		
		grid_area.size = dto.size
	get:
		return dto.id



func _ready() -> void:
	label_container.visible = false



func set_hovered(value: bool) -> void:
	
	if hovered == value:
		return
	
	hovered = value
	
	animation_player.play("hover_on" if hovered else "hover_off")


func overlap_bump() -> void:
	animation_player.play("overlap_bump")


func get_structure_config() -> StructureConfigDTO:
	var config: StructureConfigDTO = StructureConfigDTO.new()
	
	config.id = dto.id
	config.grid_position = grid_area.position
	config.flipped = flipped
	
	return config
