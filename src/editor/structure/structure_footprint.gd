extends Node2D


@onready var polygon_2d: Polygon2D = $Transform/Polygon2D

@export var size: Vector2 : set = set_size


func _ready() -> void:
	
	set_size(size)
	
	var x = Isometry.GRID_TO_WORLD_SCALE
	polygon_2d.polygon = [
		Vector2(x, 0),
		Vector2(x, x),
		Vector2(0, x),
		Vector2(0, 0),
	]

func set_size(value: Vector2) -> void:
	size = value
	if is_inside_tree():
		polygon_2d.scale = value * sqrt(2)
