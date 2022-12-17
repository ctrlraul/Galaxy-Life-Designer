extends Control
class_name StructuresPicker


@export var StructuresListItemScene: PackedScene

@onready var items: VBoxContainer = $Panel/ScrollContainer/Items


var items_map: Dictionary


func set_loadout(loadout: LoadoutDTO) -> void:
	
	NodeUtils.queue_free_children(items)
	
	for structure_id in loadout.structures:
		var item: StructuresListItem = StructuresListItemScene.instantiate()
		var count: int = loadout.structures[structure_id]
		items.add_child(item)
		item.set_structure(structure_id, count)
		items_map[structure_id] = item

func pick(structure_id: String) -> void:
	items_map[structure_id].count -= 1

func put(structure_id: String) -> void:
	items_map[structure_id].count += 1
