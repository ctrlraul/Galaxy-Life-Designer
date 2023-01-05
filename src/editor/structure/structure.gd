extends Node2D
class_name Structure


@onready var tactical_view: Sprite2D = $TacticalView
@onready var sprite: Sprite2D = $Sprite2D
@onready var grid_area_marker: Node2D = $GridAreaMarker
@onready var radius: Node2D = $Radius
@onready var animation_player = $AnimationPlayer


const AREA_BORDER_COLOR: Color = Color(0.25, 0.75, 0.5, 0.5)
const AREA_BORDER_COLOR_TACTICAL: Color = Color(1, 1, 1, 0.15)

var hovered: bool = false : set = set_hovered
var grid_area: Rect2

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

var dto: StructureDTO



func _ready() -> void:
	
	radius.scale = Vector2.ZERO
	
	grid_area_marker.set_border_color(AREA_BORDER_COLOR)
	grid_area_marker.set_color(Color.TRANSPARENT)
	
	UserOptions.options_changed.connect(_on_options_changed)
	_on_options_changed(UserOptions.options)



func set_structure(structure_id: String, level: int) -> void:
	
	dto = Assets.structures.get(structure_id)
	
	var visual_size: Vector2 = dto.size * Isometry.GRID_TO_WORLD_SCALE
	
	sprite.texture = Assets.get_structure_level_property(dto, level, "texture")
	sprite.position = Assets.get_structure_level_property(dto, level, "offset")
	sprite.position.y += visual_size.y * 0.5
	
	tactical_view.texture = dto.tactical_view
	tactical_view.scale = dto.size * Isometry.GRID_TO_WORLD_SCALE / tactical_view.texture.get_size()
	tactical_view.scale.x *= 2
	tactical_view.position.y = visual_size.y * 0.5
	
	# Maybe try make some sense out of this to write it better
	tactical_view.scale -= Vector2.ONE * Isometry.GRID_TO_WORLD_SCALE / tactical_view.texture.get_size() * 0.2
	
	grid_area_marker.size = dto.size
	
	var level_range = Assets.get_structure_level_property(dto, level, "range")
	
	if level_range != null:
		radius.set_radius(level_range)
		radius.position.y = visual_size.y * 0.5
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



func _on_options_changed(options: UserOptions.OptionsData) -> void:
	if options.tactical_view:
		tactical_view.visible = true
		grid_area_marker.set_checkerboard(false)
		grid_area_marker.set_border_color(AREA_BORDER_COLOR_TACTICAL)
		sprite.visible = false
	else:
		tactical_view.visible = false
		grid_area_marker.set_checkerboard(true)
		grid_area_marker.set_border_color(AREA_BORDER_COLOR)
		sprite.visible = true
