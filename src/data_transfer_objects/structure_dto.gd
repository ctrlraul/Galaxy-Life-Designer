class_name StructureDTO


var id: String
var display_name: String
var tactical_view: Texture2D
var size: Vector2
var levels: Dictionary


static func from(object) -> StructureDTO:
	
	var to: StructureDTO = StructureDTO.new()
	var size_data = Assets.get_or_default(object, "size", Vector2(4, 4)) # Vector2 | Dictionary
	
	to.id = object.get("id")
	to.display_name = Assets.get_or_default(object, "display_name", false)
	to.levels = object.get("levels")
	to.size = Vector2(size_data.x, size_data.y)
	
	if object.get("tactical_view") != null:
		to.tactical_view = load(object.tactical_view)
	
	for level in to.levels:
		
		var level_info = to.levels[level]
		
		if level_info.get("offset") != null:
			level_info.offset = Vector2(level_info.offset.x, level_info.offset.y)
			
		if level_info.get("texture") != null:
			level_info.texture = load(level_info.texture)
		
	
	return to
