class_name StructureDTO


var id: String
var display_name: String
var size: Vector2
var texture: Texture
var sprite_offset: Vector2


static func from(object) -> StructureDTO:
	
	var to: StructureDTO = StructureDTO.new()
	var size_data = Assets.get_or_default(object, "size", Vector2(4, 4)) # Vector2 | Dictionary
	var sprite_offset_data = Assets.get_or_default(object, "sprite_offset", Vector2.ZERO)
	
	to.id = object.get("id")
	to.display_name = Assets.get_or_default(object, "display_name", false)
	to.texture = load(object.get("texture"))
	to.size = Vector2(size_data.x, size_data.y)
	to.sprite_offset = Vector2(sprite_offset_data.x, sprite_offset_data.y)
	
	return to
