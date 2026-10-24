extends Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if OS.has_feature("mobile"):
		$Safe/Center/Column/Quit.visible = false


func _on_new_game_pressed() -> void:
	global.new_game()


func _on_hi_scores_pressed() -> void:
	global.load_hi_scores()


func _on_options_pressed() -> void:
	global.load_options()


func _on_credits_pressed() -> void:
	global.load_credits()


func _on_quit_pressed() -> void:
	global.quit()
