extends OkPopup
class_name OkCancelPopup



@onready var __cancel_button: Button = %Cancel



var on_cancel: Callable

var cancel: String :
	set(value):
		__cancel_button.text = value



func _on_cancel_pressed() -> void:
	on_cancel.call()
	__remove()
