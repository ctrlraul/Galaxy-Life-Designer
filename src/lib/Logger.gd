extends Node
class_name Logger



var _label: String



func _init(label: String) -> void:
	_label = label


func info(message: String) -> void:
	print("[%s] %s" % [_label, message])


func error(message: String) -> void:
	push_error("[%s] %s" % [_label, message])
