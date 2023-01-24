class_name LoadoutDTO


var id: String
var display_name: String
var structures: Dictionary


static func from(object, _id: String) -> LoadoutDTO:

	var to = LoadoutDTO.new()

	to.id = _id
	to.display_name = Assets.get_or_default(object, "display_name", "")
	to.structures = Assets.get_or_default(object, "structures", "")

	return to
