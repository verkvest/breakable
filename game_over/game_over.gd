extends Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Safe/Center/Column/Score.text = tr("SCORE") + "   " + str(global.score)
	if global.score > hsm.get_lowest_hi_score():
		$HiScore.show_for(global.score, self)


func _on_play_again_pressed() -> void:
	global.new_game()


func _on_main_menu_pressed() -> void:
	global.load_menu()


func close_hi_score_dialog(dialog, playername: String) -> void:
	dialog.hide()
	hsm.add_hi_score(playername, global.score)
