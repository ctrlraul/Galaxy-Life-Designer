extends Node



const OkCancelPopupScene: PackedScene = preload("res://src/interface/common/ok_cancel_popup/ok_cancel_popup.tscn")
const OkPopupScene: PackedScene = preload("res://src/interface/common/ok_popup/ok_popup.tscn")



func ok() -> OkPopup:
	var popup: OkPopup = OkPopupScene.instantiate()
	add_child(popup)
	return popup


func ok_cancel() -> OkCancelPopup:
	var popup: OkCancelPopup = OkCancelPopupScene.instantiate()
	add_child(popup)
	return popup
