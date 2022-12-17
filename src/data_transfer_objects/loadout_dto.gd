class_name LoadoutDTO


var display_name: String
var structures: Dictionary


static func from(object) -> LoadoutDTO:
	
	var to = LoadoutDTO.new()
	
	to.display_name = Assets.get_or_default(object, "display_name", "")
	to.structures = Assets.get_or_default(object, "structures", "")
	
	return to
