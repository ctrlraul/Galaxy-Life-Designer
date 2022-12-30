extends Node2D
class_name Structure


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var footprint: Node2D = $StructureFootprint
@onready var radius: Node2D = $Radius
@onready var animation_player = $AnimationPlayer


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



func _ready() -> void:
	radius.scale = Vector2.ZERO



func set_structure(structure_id: String, level: int) -> void:
	
	dto = Assets.structures.get(structure_id)
	
	sprite_2d.texture = Assets.get_structure_level_property(dto, level, "texture")
	sprite_2d.position = Assets.get_structure_level_property(dto, level, "offset")
	sprite_2d.position.y += dto.size.y * Isometry.GRID_TO_WORLD_SCALE * 0.5
	
	footprint.size = dto.size
	
	radius.position.y = dto.size.y * Isometry.GRID_TO_WORLD_SCALE * 0.5
	
	var level_range = Assets.get_structure_level_property(dto, level, "range")
	
	if level_range != null:
		radius.set_radius(level_range)
	else:
		radius.visible = false
	
	grid_area.size = dto.size


func set_hovered(value: bool) -> void:
	
	if hovered == value:
		return
	
	hovered = value
	
	animation_player.play("hover_on" if hovered else "hover_off")


func overlap_bump() -> void:
	if animation_player.is_playing():
		return
	animation_player.play("overlap_bump")


func get_config() -> StructureConfigDTO:
	var config: StructureConfigDTO = StructureConfigDTO.new()
	
	config.id = dto.id
	config.grid_position = grid_area.position
	config.flipped = flipped
	
	return config


func set_dragged(value: bool) -> void:
	modulate.a = 0.3 if value else 1.0
