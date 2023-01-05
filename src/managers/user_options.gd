extends Node


class OptionsData:
	var tactical_view: bool


signal options_changed(options: OptionsData)


var options: OptionsData = OptionsData.new()


func change(changer_function: Callable) -> void:
	changer_function.call(options)
	options_changed.emit(options)
