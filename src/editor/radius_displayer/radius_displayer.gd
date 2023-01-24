extends Node2D
class_name RadiusDisplayer



@onready var white_circle: Sprite2D = %WhiteCircle
@onready var line: Line2D = %Line2D


const LINE_DETAIL: int = 80
const RADIUS_TO_GRID_SCALE: float = 0.1305
const RANGE_COLORS: Array[Color] = [
	Color(0, 1, 1, 0.2),
	Color(1, 0, 0, 0.2),
]


var tween: Tween


func _ready() -> void:
	white_circle.scale = Vector2.ZERO
	line.clear_points()



func set_for(structure: Structure) -> void:

	if is_instance_valid(tween):
		tween.stop()

	tween = create_tween()

	var range_radius: float = 0
	var new_scale: Vector2 = Vector2.ZERO
	var new_position: Vector2 = position
	var new_line_scale: Vector2 = Vector2.ZERO
	var new_color: Color = white_circle.self_modulate

	if structure != null:
		range_radius = structure.get_range_radius()

	if range_radius > 0:

		new_color = RANGE_COLORS[structure.dto.range_color]

		new_position = structure.position
		new_position.y += structure.get_visual_size().y * 0.5

		var texture_size: int = white_circle.texture.get_height()
		new_scale = Vector2.ONE * range_radius
		new_scale *= 1.0 / texture_size
		new_scale *= Isometry.GRID_TO_WORLD_SCALE * RADIUS_TO_GRID_SCALE

		new_line_scale = Vector2.ONE

		line.clear_points()

		for i in LINE_DETAIL + 1:
			var radii: float = i / float(LINE_DETAIL) * PI * 2
			var point: Vector2 = Vector2(cos(radii), sin(radii) * 0.5)
			point *= white_circle.texture.get_height() * new_scale * 0.5
			line.add_point(point)

	line.scale = Vector2.ONE * white_circle.scale.x / new_scale.x

	tween.tween_property(white_circle, "scale", new_scale, 0.3)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)

	tween.parallel().tween_property(white_circle, "self_modulate", new_color, 0.3)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)

	tween.parallel().tween_property(line, "scale", new_line_scale, 0.3)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)

	# Can't check against zero because nodes have a min scale to avoid div by 0
	if white_circle.scale.length() > 0.001:
		tween.parallel().tween_property(self, "position", new_position, 0.3)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_CUBIC)
	else:
		position = new_position
