class_name StructureConfigDTO


var id: String
var grid_position: Vector2
var flipped: bool


static func from(object) -> StructureConfigDTO:
	
	var to = StructureConfigDTO.new()
	var position_data = Assets.get_or_default(object, "grid_position", Vector2.ZERO) # Vector2 | Dictionary
	
	to.id = object.id
	to.grid_position = Vector2(position_data.x, position_data.y)
	to.flipped = Assets.get_or_default(object, "flipped", false)
	
	return to


func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"grid_position": {
			"x": grid_position.x,
			"y": grid_position.y,
		},
		"flipped": flipped
	}
