extends Node


const ISOMETRIC_TRANSFORMATION = [Vector2(1, 0.5), Vector2(-1, 0.5)]
const GRID_TO_WORLD_SCALE = 14


func world_to_grid(world_position: Vector2) -> Vector2:
	world_position /= GRID_TO_WORLD_SCALE
	var xx = Vector2(world_position.x, world_position.x)
	var yy = Vector2(world_position.y, world_position.y)
	var xxTransform = Vector2(ISOMETRIC_TRANSFORMATION[1].y, -ISOMETRIC_TRANSFORMATION[0].y)
	var yyTransform = Vector2(ISOMETRIC_TRANSFORMATION[0].x, -ISOMETRIC_TRANSFORMATION[1].x)
	return (xx * xxTransform + yy * yyTransform).snapped(Vector2(1, 1))

func grid_to_world(grid_coord: Vector2) -> Vector2:
	return (
		Vector2(grid_coord.x, grid_coord.x) * ISOMETRIC_TRANSFORMATION[0] +
		Vector2(grid_coord.y, grid_coord.y) * ISOMETRIC_TRANSFORMATION[1]
	) * GRID_TO_WORLD_SCALE
