extends Node



var loadouts: Dictionary
var structures: Dictionary



func _ready() -> void:
	__load_loadouts("res://src/loadouts/")
	__load_structures("res://src/structures/")



func __load_loadouts(path: String) -> void:
	for file_name in get_files_in_dir(path):
		var id: String = file_name.get_file().split(".")[0]
		loadouts[id] = LoadoutDTO.from(__load_json(file_name), id)


func __load_structures(path: String) -> void:
	for file_name in get_files_in_dir(path):
		var json: Dictionary = __load_json(file_name)
		json["id"] = file_name.get_file().split(".")[0]
		structures[json.id] = StructureDTO.from(json)


func __load_json(path: String):
	var json_string = FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(json_string)
	return data



func get_or_default(target, key: String, default):
	var value = target.get(key)
	if value == null:
		return default
	return value


func get_files_in_dir(path: String) -> Array[String]:
	var files: Array[String] = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				files.append(path.path_join(file_name))
			file_name = dir.get_next()
	return files


func get_structure_level_property(dto: StructureDTO, level: int, data_key: String):

	var value = null

	while level > 0:

		var level_info = dto.levels.get(str(level))

		if level_info != null:
			value = level_info.get(data_key)

			if value == null:
				level -= 1
				continue
		else:
			level -= 1
			continue

		value = level_info.get(data_key)
		break

	return value
