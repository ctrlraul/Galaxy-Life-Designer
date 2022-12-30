extends Control
class_name OkPopup



signal removed()



@onready var __message_text_edit: TextEdit = %Message
@onready var __title_label: Label = %Title
@onready var __ok_button: Button = %Ok
@onready var __animation_player: AnimationPlayer = $AnimationPlayer



var on_ok: Callable

var title: String :
	set(value):
		__title_label.text = value

var message: String :
	set(value):
		__message_text_edit.text = value
	get:
		return __message_text_edit.text

var message_editable: bool :
	set(value):
		__message_text_edit.editable = value

var ok: String :
	set(value):
		__ok_button.text = value



func _ready() -> void:
	__animation_player.play("add")


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("cancel"):
		_on_outside_hitbox_pressed()



func __remove() -> void:
	__animation_player.play("remove")
	await __animation_player.animation_finished
	queue_free()
	removed.emit()



func _on_outside_hitbox_pressed() -> void:
	__remove()


func _on_ok_pressed() -> void:
	on_ok.call()
	__remove()
