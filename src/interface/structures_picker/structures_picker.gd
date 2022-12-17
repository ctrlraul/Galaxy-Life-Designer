extends Control
class_name StructuresPicker

signal item_picked(structure_id)
signal cover_clicked()


@export var StructuresListItemScene: PackedScene

@onready var items: VBoxContainer = $Panel/ScrollContainer/Items
@onready var cover: Control = $Panel/Cover


var block_picking: bool : set = set_block_picking
var items_map: Dictionary


func _ready() -> void:
	cover.visible = false


func set_loadout(loadout: LoadoutDTO) -> void:
	
	NodeUtils.queue_free_children(items)
	
	for structure_id in loadout.structures:
		var item: StructuresListItem = StructuresListItemScene.instantiate()
		var count: int = loadout.structures[structure_id]
		items.add_child(item)
		item.set_structure(structure_id, count)
		item.pressed.connect(func(): on_pick(structure_id))
		items_map[structure_id] = item

func set_block_picking(value: bool) -> void:
	
	if value == block_picking:
		return
	
	block_picking = value
	cover.visible = value

func on_pick(structure_id: String) -> void:
	
	if block_picking:
		return
	
	item_picked.emit(structure_id)
	items_map[structure_id].count -= 1

func put(structure_id: String) -> void:
	items_map[structure_id].count += 1


func _on_cover_hitbox_pressed() -> void:
	cover_clicked.emit()
