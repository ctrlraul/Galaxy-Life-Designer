extends Node


func get_structure_on_tile(tile: Vector2, structures: Array[Structure]) -> Structure:

	var tile_area: Rect2 = Rect2(tile, Vector2(1, 1))

	for structure in structures:
		if tile_area.intersects(structure.grid_area):
			return structure

	return null


func get_structures_on_area(area: Rect2, structures: Array[Structure]) -> Array[Structure]:

	var structures_on_area: Array[Structure] = []

	for structure in structures:
		if area.intersects(structure.grid_area):
			structures_on_area.append(structure)

	return structures_on_area
