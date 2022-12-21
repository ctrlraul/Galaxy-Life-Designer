extends Node2D
class_name StructureFootprint


@onready var squisher: Node2D = %Squisher
@onready var polygon: Polygon2D = %Polygon2D
@onready var checkerboard: Sprite2D = %Checkerboard
@onready var line: Line2D = %Line2D

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
	line.scale = size
	line.width = 0.2 / size.length() 
	
	checkerboard.material.set_shader_parameter("scale", size / 2)

func hide_checkerboard() -> void:
	polygon.visible = true
	checkerboard.visible = false
