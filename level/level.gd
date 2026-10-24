extends Node2D

var total_bricks := 0


func load_level(level: int) -> void:
	var doomed: Array = []
	for child in get_children():
		doomed.append(child)
	for child in doomed:
		remove_child(child)
		child.queue_free()
	var builder_script = load("res://level/%d.gd" % level)
	var builder = builder_script.new()
	total_bricks = int(builder.init_level(self))


func get_total_bricks() -> int:
	return total_bricks
