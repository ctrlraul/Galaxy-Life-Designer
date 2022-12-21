extends Node2D


@export_node_path(Camera2D) var camera_path: NodePath
@export_node_path(Button) var interaction_hitbox_path: NodePath

@onready var camera: Camera2D = get_node(camera_path)
@onready var interaction_hitbox: Button = get_node(interaction_hitbox_path)

var panning: bool
var button_down: bool
var button_down_position: Vector2 = Vector2.ZERO
var enabled: bool = true


func _ready() -> void:
	interaction_hitbox.button_down.connect(_on_interaction_hitbox_button_down)
	interaction_hitbox.button_up.connect(_on_interaction_hitbox_button_up)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && enabled:
		if button_down:
			panning = true
			camera.position -= event.relative / camera.zoom
			get_viewport().set_input_as_handled()

func set_enabled(value: bool) -> void:
	enabled = value


func _on_interaction_hitbox_button_down() -> void:
	button_down = true

func _on_interaction_hitbox_button_up() -> void:
	button_down = false
	panning = false
