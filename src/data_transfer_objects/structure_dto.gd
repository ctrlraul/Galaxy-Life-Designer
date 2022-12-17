class_name StructureDTO


var display_name: String
var size: Vector2
var texture: Texture
var sprite_offset: int


static func from(object) -> StructureDTO:
	
	var to = StructureDTO.new()
	var size_data = Assets.get_or_default(object, "size", Vector2(4, 4)) # Vector2 | Dictionary
	var texture_path: String = Assets.get_or_default(object, "texture", false)
	
	to.display_name = Assets.get_or_default(object, "display_name", false)
	to.texture = load(texture_path)
	to.size = Vector2(size_data.x, size_data.y)
	to.sprite_offset = Assets.get_or_default(object, "sprite_offset", 0)
	
	return to
