extends Button
class_name StructuresListItem


@onready var texture_rect: TextureRect = $TextureRect
@onready var count_label: Label = $Count

var count: int = 0 : set = set_count 


func set_structure(id: String, structure_count: int) -> void:
	var structure: StructureDTO = Assets.structures[id]
	texture_rect.texture = structure.texture
	set_count(structure_count)

func set_count(value: int) -> void:
	count = value
	count_label.text = str(value)
