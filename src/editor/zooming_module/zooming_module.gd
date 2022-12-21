extends Node2D


@export_node_path(Camera2D) var camera_path: NodePath
@export_node_path(Button) var interaction_hitbox_path: NodePath

@export var zoom_step: float = 0.05
@export var zoom_max: Vector2 = Vector2(0.5, 0.5)
@export var zoom_min: Vector2 = Vector2(3, 3)

@onready var camera: Camera2D = get_node(camera_path)
@onready var interaction_hitbox: Button = get_node(interaction_hitbox_path)

@onready var screen_center: Control = %ScreenCenter


func _ready() -> void:
	set_process_unhandled_input(false)
	interaction_hitbox.mouse_entered.connect(
		func(): set_process_unhandled_input(true)
	)
	interaction_hitbox.mouse_exited.connect(
		func(): set_process_unhandled_input(false)
	)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			__zoom(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			__zoom(-1)


func __zoom(delta: int) -> void:
	
	var mouse: Vector2 = screen_center.get_local_mouse_position()
	var old_zoom: Vector2 = Vector2(1, 1) / camera.zoom
	var new_zoom: Vector2 = clamp(old_zoom - delta * zoom_step * old_zoom, zoom_max, zoom_min)
	var zoom_difference: Vector2 = old_zoom - new_zoom
	
	camera.zoom = Vector2(1, 1) / new_zoom
	camera.position += mouse * zoom_difference
