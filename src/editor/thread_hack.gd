extends Node
class_name ThreadHack


signal finished()


var __callable: Callable
var __thread: Thread = Thread.new()


func start(callable: Callable) -> void:
	
	assert(is_inside_tree(), "Append ThreadHack as child")
	
	name = "ThreadHack"
	
	__callable = callable
	__thread.start(self.__start)
	
	await finished
	
	queue_free()


func __start() -> void:
	__callable.call()
	finished.emit()


func _exit_tree() -> void:
	__thread.wait_to_finish()
