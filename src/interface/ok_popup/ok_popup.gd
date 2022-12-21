extends Control
class_name OkPopup


@onready var title: Label = %Title
@onready var message: RichTextLabel = %Message
@onready var ok: Button = %Ok
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var __on_ok: Callable


func _ready() -> void:
	visible = false


func set_title(text: String) -> void:
	title.text = text

func set_message(text: String) -> void:
	message.text = text

func set_ok(callback: Callable, text = "Ok") -> void:
	__on_ok = callback
	ok.text = text

func show_popup() -> void:
	animation_player.play("show")
	__on_ok = null

func hide_popup() -> void:
	animation_player.play("hide")
	__on_ok = null


func _on_outside_hitbox_pressed() -> void:
	hide()

func _on_ok_pressed() -> void:
	__on_ok.call()
	hide()
