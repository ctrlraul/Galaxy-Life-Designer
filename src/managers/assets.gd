extends Node


var layouts: Array[LayoutDTO]

var loadouts: Dictionary
var structures: Dictionary


func _ready() -> void:
	__load_loadouts("res://src/loadouts/")
	__load_structures("res://src/structures/")
	layouts.append(load_layout("res://src/default_layout.txt"))


func __load_loadouts(path: String) -> void:
	for file_name in get_files_in_dir(path):
		var id: String = file_name.get_file().split(".")[0]
		loadouts[id] = LoadoutDTO.from(__load_json(file_name))

func __load_structures(path: String) -> void:
	for file_name in get_files_in_dir(path):
		var id: String = file_name.get_file().split(".")[0]
		structures[id] = StructureDTO.from(__load_json(file_name))

func __load_json(path: String):
	var json_string = FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(json_string)
	return data


func load_layout(path: String) -> LayoutDTO:
	var layout = LayoutDTO.from(__load_json(path))
	layouts.append(layout)
	return layout


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
