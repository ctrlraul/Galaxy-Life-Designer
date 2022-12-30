extends Node2D



@onready var white_circle: Sprite2D = %WhiteCircle



func set_radius(value: float) -> void:
	var texture_size: int = white_circle.texture.get_height()
	var some_arbitrary_value_idk: float = 0.1305
	white_circle.scale = Vector2.ONE * value * (1.0 / texture_size) * Isometry.GRID_TO_WORLD_SCALE * some_arbitrary_value_idk
