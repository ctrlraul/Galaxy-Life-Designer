class_name StructureConfigDTO


var id: String
var position: Vector2
var flipped: bool


static func from(object) -> StructureConfigDTO:
	
	var to = StructureConfigDTO.new()
	var position_data = Assets.get_or_default(object, "position", Vector2.ZERO) # Vector2 | Dictionary
	
	to.id = object.id
	to.position = Vector2(position_data.x, position_data.y)
	to.flipped = Assets.get_or_default(object, "flipped", false)
	
	return to
