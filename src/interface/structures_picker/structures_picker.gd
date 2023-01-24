extends Control
class_name StructuresPicker



signal item_picked(structure_id)
signal cover_clicked()
signal loadout_changed(old_loadout: LoadoutDTO)



@export var StructuresListItemScene: PackedScene

@onready var items: GridContainer = %Items
@onready var cover: Control = %Cover
@onready var loadouts: OptionButton = %Loadouts
@onready var animation_player: AnimationPlayer = $AnimationPlayer



var block_picking: bool : set = set_block_picking
var items_map: Dictionary
var loadout: LoadoutDTO



func _ready() -> void:
	cover.visible = false
	for _loadout in Assets.loadouts.values():
		loadouts.add_item(_loadout.display_name)



func set_loadout_index(index: int) -> void:
	set_loadout(Assets.loadouts.values()[index])


func set_loadout(_loadout: LoadoutDTO) -> void:
	
	var old_loadout: LoadoutDTO = loadout
	
	loadout = _loadout
	
	NodeUtils.queue_free_children(items)
	
	for structure_id in loadout.structures:
		
		var item: StructuresListItem = StructuresListItemScene.instantiate()
		var data: Dictionary = loadout.structures[structure_id]
		
		items.add_child(item)
		item.set_structure(structure_id, data.count, data.level)
		item.pressed.connect(func(): pick(structure_id))
		items_map[structure_id] = item
	
	loadouts.selected = Assets.loadouts.values().find(loadout)
	
	loadout_changed.emit(old_loadout)


func set_block_picking(value: bool) -> void:
	
	if value == block_picking:
		return
	
	block_picking = value
	cover.visible = block_picking
	cover.modulate.a = 0
	items.modulate.a = 0.5 if block_picking else 1.0


func pick(structure_id: String) -> void:
	
	if block_picking || get_count(structure_id) <= 0:
		return
	
	item_picked.emit(structure_id)


func decrease_count(structure_id: String) -> bool:
	if items_map[structure_id].count > 0:
		items_map[structure_id].count -= 1
		return true
	return false


func set_count(structure_id: String, count: int) -> void:
	
	if !items_map.has(structure_id):
		push_error("Loadout '%s' does not allow '%s' structures" % [loadout.id, structure_id])
		return
	
	items_map[structure_id].count = count


func get_count(structure_id: String) -> int:
	return items_map[structure_id].count


func put(structure_id: String) -> void:
	
	if loadout.structures[structure_id].count < items_map[structure_id].count:
		push_error("Trying to store more %ss than allowed!" % structure_id)
		return
	
	items_map[structure_id].count += 1


func get_level(structure_id: String) -> int:
	return loadout.structures.get(structure_id).level



func _on_cover_hitbox_pressed() -> void:
	cover_clicked.emit()


func _on_loadouts_item_selected(index: int) -> void:
	set_loadout_index(index)


func _on_cover_hitbox_mouse_entered() -> void:
	animation_player.play("cover_show")


func _on_cover_hitbox_mouse_exited() -> void:
	animation_player.play("cover_hide")
