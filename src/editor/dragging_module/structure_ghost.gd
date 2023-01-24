extends Node2D
class_name StructureGhost


@onready var tactical_view: Sprite2D = $TacticalView
@onready var sprite: Sprite2D = $Sprite2D
@onready var grid_area_marker: Node2D = $GridAreaMarker


var grid_area: Rect2
var dto: StructureDTO
var grid_position_dragging_started: Vector2

var flipped: bool :
	set(value):
		sprite.flip_h = value
	get:
		return sprite.flip_h

var grid_position: Vector2 :
	set(value):
		grid_area.position = value
		position = Isometry.grid_to_world(value)
	get:
		return grid_area.position


func _ready() -> void:
	grid_area_marker.set_color(Color(1, 1, 1, 0.1))
	UserOptions.options_changed.connect(_on_options_changed)
	_on_options_changed(UserOptions.options)



func set_structure_config(config: StructureConfigDTO, level: int) -> void:

	dto = Assets.structures.get(config.id)

	sprite.texture = Assets.get_structure_level_property(dto, level, "texture")
	sprite.position = Assets.get_structure_level_property(dto, level, "offset")
	sprite.position.y += dto.size.y * Isometry.GRID_TO_WORLD_SCALE * 0.5

	grid_area_marker.size = dto.size

	set_tactical_view()

	grid_area.size = dto.size
	grid_position = config.grid_position


func set_tactical_view() -> void:

	tactical_view.texture = dto.tactical_view
	tactical_view.scale = dto.size * Isometry.GRID_TO_WORLD_SCALE / tactical_view.texture.get_size()
	tactical_view.scale.x *= 2
	tactical_view.position.y = get_visual_size().y * 0.5

	# Maybe try make some sense out of this to write it better
	tactical_view.scale -= Vector2.ONE * Isometry.GRID_TO_WORLD_SCALE / tactical_view.texture.get_size() * 0.2


func get_visual_size() -> Vector2:
	return dto.size * Isometry.GRID_TO_WORLD_SCALE


func get_structure_config() -> StructureConfigDTO:
	var config: StructureConfigDTO = StructureConfigDTO.new()

	config.id = dto.id
	config.grid_position = grid_area.position
	config.flipped = flipped

	return config


func _on_options_changed(options: UserOptions.OptionsData) -> void:
	if options.tactical_view:
		tactical_view.visible = true
		grid_area_marker.set_checkerboard(false)
		sprite.visible = false
	else:
		tactical_view.visible = false
		grid_area_marker.set_checkerboard(true)
		sprite.visible = true
