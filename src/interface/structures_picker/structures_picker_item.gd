extends Button
class_name StructuresListItem



@onready var texture_rect: TextureRect = $TextureRect
@onready var count_label: Label = %Count
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var count: int = 0 : set = set_count
var structure: StructureDTO



func set_structure(id: String, structure_count: int, level: int) -> void:
	structure = Assets.structures.get(id)
	texture_rect.texture = Assets.get_structure_level_property(structure, level, "texture")
	set_count(structure_count)


func set_count(value: int) -> void:
	
	if value == count:
		return
	
	if bool(value) != bool(count):
		animation_player.play("show" if value > 0 else "hide")
	
	count = value
	count_label.text = "%sx" % count
