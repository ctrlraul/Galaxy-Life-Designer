extends Node2D
class_name StructureFootprint


@onready var squisher: Node2D = %Squisher
@onready var polygon: Polygon2D = %Polygon2D
@onready var checkerboard: Sprite2D = %Checkerboard
@onready var horizontal_lines: Node2D = %HorizontalLines
@onready var vertical_lines: Node2D = %VerticalLines

const SCALE: float = Isometry.GRID_TO_WORLD_SCALE * sqrt(2)
const SQUISH: Vector2 = Vector2(1, 0.5)

var size: Vector2 = Vector2.ZERO : set = set_size


func _ready() -> void:
	polygon.visible = false
	checkerboard.visible = true
	squisher.scale = SQUISH * SCALE


func set_size(value: Vector2) -> void:
	
	size = value
	
	polygon.scale = size
	checkerboard.scale = size / 2
	
	horizontal_lines.scale = size
	horizontal_lines.get_child(0).width = 0.2 / abs(size.y)
	horizontal_lines.get_child(1).width = horizontal_lines.get_child(0).width
	
	vertical_lines.scale = size
	vertical_lines.get_child(0).width = 0.2 / abs(size.x)
	vertical_lines.get_child(1).width = vertical_lines.get_child(0).width
	
	checkerboard.material.set_shader_parameter("scale", size / 2)

func hide_checkerboard() -> void:
	polygon.visible = true
	checkerboard.visible = false
