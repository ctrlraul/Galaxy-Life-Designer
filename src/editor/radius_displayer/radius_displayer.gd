extends Node2D
class_name RadiusDisplayer



@onready var white_circle: Sprite2D = %WhiteCircle


const RADIUS_TO_GRID_SCALE: float = 0.1305



func _ready() -> void:
	white_circle.scale = Vector2.ZERO


func set_for(structure: Structure) -> void:

	var tween: Tween = create_tween()
	var range_radius: float = 0
	var new_scale: Vector2 = Vector2.ZERO
	var new_position: Vector2 = position

	if structure != null:
		range_radius = structure.get_range_radius()

	if range_radius > 0:

		new_position = structure.position
		new_position.y += structure.get_visual_size().y * 0.5

		var texture_size: int = white_circle.texture.get_height()
		new_scale = Vector2.ONE * range_radius
		new_scale *= 1.0 / texture_size
		new_scale *= Isometry.GRID_TO_WORLD_SCALE * RADIUS_TO_GRID_SCALE

	tween.tween_property(white_circle, "scale", new_scale, 0.3)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)

	# Can't check against zero because nodes have a min scale to avoid div by 0
	if white_circle.scale.length() > 0.001:
		tween.parallel().tween_property(self, "position", new_position, 0.3)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_CUBIC)
	else:
		position = new_position

	tween.tween_callback(
		func():
			white_circle.scale = new_scale
	)
