extends OkPopup
class_name YesNoPopup


@onready var no: Button = %No


var __on_no: Callable


func set_yes(callback: Callable, text = "Yes") -> void:
	set_ok(callback, text)

func set_no(callback: Callable, text = "No") -> void:
	__on_no = callback
	no.text = text



func show_popup() -> void:
	super.show_popup()
	__on_no = null

func hide_popup() -> void:
	super.hide_popup()
	__on_no = null

func _on_no_pressed() -> void:
	__on_no.call()
	hide()
