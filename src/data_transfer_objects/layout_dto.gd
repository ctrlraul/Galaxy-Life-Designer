class_name LayoutDTO


var display_name: String
var loadout: String
var structure_configs: Array[StructureConfigDTO] = []


static func from(object) -> LayoutDTO:
	
	var to = LayoutDTO.new()
	
	to.display_name = Assets.get_or_default(object, "display_name", "")
	to.loadout = Assets.get_or_default(object, "loadout", "")
	
	for config in Assets.get_or_default(object, "structure_configs", []):
		to.structure_configs.append(StructureConfigDTO.from(config))
	
	return to
