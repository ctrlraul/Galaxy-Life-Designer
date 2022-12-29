class_name LayoutDTO


var display_name: String
var loadout: String
var structures: Dictionary


static func from(object) -> LayoutDTO:
	
	var to = LayoutDTO.new()
	
	to.display_name = Assets.get_or_default(object, "display_name", "Layout")
	to.loadout = object.loadout
	to.structures = object.structures
	
	return to


func to_dictionary() -> Dictionary:
	return {
		"display_name": display_name,
		"loadout": loadout,
		"structures": structures
	}
