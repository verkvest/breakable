extends Node


func read_options() -> Dictionary:
	if not FileAccess.file_exists("user://options.data"):
		return {}
	var f := FileAccess.open("user://options.data", FileAccess.READ)
	if f == null:
		return {}
	var data = f.get_var()
	f.close()
	if data is Dictionary:
		return data
	return {}


func write_options(options: Dictionary) -> void:
	var f := FileAccess.open("user://options.data", FileAccess.WRITE)
	if f == null:
		push_error("Could not write user://options.data")
		return
	f.store_var(options)
	f.close()
