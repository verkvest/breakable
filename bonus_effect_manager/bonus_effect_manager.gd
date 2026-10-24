extends Node

var board
var current_effect := ""


func _ready() -> void:
	board = get_parent()


func apply_effect(effect: String) -> void:
	if effect == "":
		return
	if current_effect != "":
		fire_effect()
	current_effect = effect
	var func_name := "apply_" + effect
	if has_method(func_name):
		nc.post_notification("show_bonus_message", effect)
		call(func_name)


func fire_effect() -> void:
	if current_effect == "":
		return
	var func_name := "fire_" + current_effect
	if has_method(func_name):
		call(func_name)


func apply_score() -> void:
	board.set_score(board.score + 1000)
	current_effect = ""


func apply_extra_life() -> void:
	board.set_lifes(board.lifes + 1)
	current_effect = ""


func apply_sticky() -> void:
	board.sticky = true


func fire_sticky() -> void:
	for child in board.get_children():
		if child.has_meta("type") and child.get_meta("type") == "ball":
			child.set_active(true)
	board.sticky = false
	board.unstick()
	current_effect = ""


func apply_small_paddle() -> void:
	var paddle = board.get_node("paddle")
	var base: float = global.metrics().paddle_w
	if paddle.paddle_width > base + 1.0:
		paddle.set_paddle_width(base)
	else:
		paddle.set_paddle_width(base * 0.62)
	current_effect = ""


func apply_big_paddle() -> void:
	var paddle = board.get_node("paddle")
	var base: float = global.metrics().paddle_w
	if paddle.paddle_width < base - 1.0:
		paddle.set_paddle_width(base)
	else:
		paddle.set_paddle_width(base * 1.42)
	current_effect = ""


func apply_three_balls() -> void:
	if board.balls_in_game <= 1:
		for child in board.get_children():
			if child.has_meta("type") and child.get_meta("type") == "ball":
				board.clone_ball(child, 2)
				break
	current_effect = ""
