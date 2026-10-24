extends Node

var score_names: Array = []
var score_values: Array = []
var HI_SCORE_SIZE := 10
const _PASS := "foo"


func _ready() -> void:
	read_scores()


func get_lowest_hi_score() -> int:
	if score_values.size() < HI_SCORE_SIZE:
		return 0
	return int(score_values[score_values.size() - 1])


func add_hi_score(playername: String, value: int) -> void:
	var name := playername.strip_edges()
	if name == "":
		name = "Player"
	if name.length() > 16:
		name = name.substr(0, 16)
	if score_values.is_empty():
		score_values.append(value)
		score_names.append(name)
	else:
		var i := 0
		while i < score_values.size():
			if value > int(score_values[i]):
				score_values.insert(i, value)
				score_names.insert(i, name)
				i = score_values.size()
			elif i == score_values.size() - 1:
				score_values.append(value)
				score_names.append(name)
				i = score_values.size()
			i += 1
	if score_values.size() > HI_SCORE_SIZE:
		score_values.resize(HI_SCORE_SIZE)
		score_names.resize(HI_SCORE_SIZE)
	write_scores()


func read_scores() -> void:
	if not FileAccess.file_exists("user://hiscores.data"):
		return
	var f := FileAccess.open_encrypted_with_pass("user://hiscores.data", FileAccess.READ, _PASS)
	if f == null:
		return
	var names = f.get_var()
	var values = f.get_var()
	f.close()
	if names is Array and values is Array and names.size() == values.size():
		score_names = names
		score_values = values


func write_scores() -> void:
	var f := FileAccess.open_encrypted_with_pass("user://hiscores.data", FileAccess.WRITE, _PASS)
	if f == null:
		push_error("Could not write user://hiscores.data")
		return
	f.store_var(score_names)
	f.store_var(score_values)
	f.close()
