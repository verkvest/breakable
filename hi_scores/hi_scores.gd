extends Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var pos_text := ""
	var name_text := ""
	var score_text := ""
	for i in hsm.score_names.size():
		pos_text += str(i + 1) + "\n"
		name_text += str(hsm.score_names[i]) + "\n"
		score_text += str(hsm.score_values[i]) + "\n"
	$Safe/Column/List/Pos.text = pos_text
	$Safe/Column/List/Name.text = name_text
	$Safe/Column/List/Score.text = score_text
	$Safe/Column/Empty.visible = hsm.score_names.is_empty()
	$Safe/Column/List.visible = not hsm.score_names.is_empty()


func _on_back_pressed() -> void:
	global.load_menu()
