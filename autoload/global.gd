extends Node

# Playfield is laid out from the live viewport so portrait phones of
# different aspect ratios (and the notch / home indicator) all fit.

const COLUMNS := 11
const MAX_LEVEL := 2
const PADDLE_VISUAL_HEIGHT := 40.0

var score := 0
var brick_texture: Array = []
var bonus_texture := {}
var bonus_effect := {}
var bonus_message := {}


func _ready() -> void:
	_install_translations()
	score = 0
	bonus_texture = {
		"score": preload("res://textures/bonus_score.png"),
		"sticky": preload("res://textures/bonus_sticky.png"),
		"three_balls": preload("res://textures/bonus_three_balls.png"),
		"extra_life": preload("res://textures/bonus_extra_life.png"),
		"small_paddle": preload("res://textures/bonus_small_paddle.png"),
		"big_paddle": preload("res://textures/bonus_big_paddle.png"),
	}
	bonus_effect = {
		"score": 15,
		"sticky": 15,
		"three_balls": 10,
		"extra_life": 5,
		"small_paddle": 15,
		"big_paddle": 15,
	}
	bonus_message = {
		"score": "BONUS_SCORE",
		"sticky": "BONUS_STICKY",
		"three_balls": "BONUS_THREE_BALLS",
		"extra_life": "BONUS_EXTRA_LIFE",
		"small_paddle": "BONUS_SMALL_PADDLE",
		"big_paddle": "BONUS_BIG_PADDLE",
	}
	brick_texture = [
		null,
		preload("res://textures/brick01.png"),
		preload("res://textures/brick11.png"),
	]
	randomize()


func safe_insets() -> Vector4:
	var vp := get_viewport().get_visible_rect().size
	if vp.x < 2.0 or vp.y < 2.0:
		return Vector4.ZERO
	var screen := Vector2(DisplayServer.window_get_size())
	if screen.x < 2.0 or screen.y < 2.0:
		return Vector4.ZERO
	var safe := DisplayServer.get_display_safe_area()
	if safe.size.x < 2 or safe.size.y < 2:
		return Vector4.ZERO
	var sx := vp.x / screen.x
	var sy := vp.y / screen.y
	var left := safe.position.x * sx
	var top := safe.position.y * sy
	var right := (screen.x - (safe.position.x + safe.size.x)) * sx
	var bottom := (screen.y - (safe.position.y + safe.size.y)) * sy
	return Vector4(
		clampf(left, 0.0, vp.x * 0.25),
		clampf(top, 0.0, vp.y * 0.3),
		clampf(right, 0.0, vp.x * 0.25),
		clampf(bottom, 0.0, vp.y * 0.3)
	)


func metrics() -> Dictionary:
	var vp := get_viewport().get_visible_rect().size
	if vp.x < 2.0 or vp.y < 2.0:
		vp = Vector2(720, 1280)
	var inset := safe_insets()
	var wall := clampf(vp.x * 0.022, 12.0, 22.0)
	# Room for the top bar and the two-line touch hint, so bricks start below them.
	var hud := clampf(vp.y * 0.15, 188.0, 240.0)
	var left := inset.x + wall
	var right := vp.x - inset.z - wall
	var top := inset.y + hud
	var bottom := vp.y - inset.w - 18.0
	var width := maxf(right - left, 120.0)
	var height := maxf(bottom - top, 200.0)
	var sep := maxf(3.0, width * 0.006)
	var brick_w := (width - sep * float(COLUMNS - 1)) / float(COLUMNS)
	var brick_h := brick_w * (37.0 / 86.0)
	var paddle_w := clampf(width * 0.26, 96.0, width * 0.46)
	return {
		"vp": vp,
		"inset": inset,
		"wall": wall,
		"hud": hud,
		"left": left,
		"right": right,
		"top": top,
		"bottom": bottom,
		"width": width,
		"height": height,
		"brick_w": brick_w,
		"brick_h": brick_h,
		"sep": sep,
		"cols": COLUMNS,
		"paddle_w": paddle_w,
		"paddle_y": bottom - clampf(height * 0.075, 64.0, 110.0),
		"ball_r": clampf(brick_h * 0.5, 12.0, 16.0),
	}


func base_ball_speed() -> float:
	return metrics().height * 0.42


func new_game() -> void:
	score = 0
	get_tree().change_scene_to_file("res://board/board.tscn")


func load_menu() -> void:
	get_tree().change_scene_to_file("res://menu/menu.tscn")


func load_hi_scores() -> void:
	get_tree().change_scene_to_file("res://hi_scores/hi_scores.tscn")


func load_options() -> void:
	get_tree().change_scene_to_file("res://options/options.tscn")


func load_credits() -> void:
	get_tree().change_scene_to_file("res://credits/credits.tscn")


func load_game_over(_score: int) -> void:
	get_tree().change_scene_to_file("res://game_over/game_over.tscn")


func quit() -> void:
	get_tree().quit()


func _install_translations() -> void:
	var file := FileAccess.open("res://translations/translation.csv", FileAccess.READ)
	if file == null:
		push_error("Missing translations/translation.csv")
		return
	var header := file.get_csv_line()
	if header.size() < 2:
		return
	var tables := {}
	for i in range(1, header.size()):
		var loc := str(header[i]).strip_edges()
		if loc == "":
			continue
		var translation := Translation.new()
		translation.locale = loc
		tables[loc] = translation
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.is_empty() or str(row[0]).strip_edges() == "":
			continue
		var key := str(row[0])
		for loc in tables.keys():
			var idx := header.find(loc)
			if idx > 0 and idx < row.size():
				tables[loc].add_message(key, str(row[idx]))
	file.close()
	for loc in tables.keys():
		TranslationServer.add_translation(tables[loc])
