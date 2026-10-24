extends Node

# Headless/CI helpers. Normal play ignores these.
#   godot --path . -- --shot-menu
#   godot --path . -- --shot-play
#   godot --path . -- --smoke


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.has("--shot-menu"):
		call_deferred("_begin", "menu")
	elif args.has("--shot-play"):
		call_deferred("_begin", "play")
	elif args.has("--smoke"):
		call_deferred("_begin", "smoke")


func _begin(kind: String) -> void:
	var options: Dictionary = options_manager.read_options()
	if options.has("locale"):
		TranslationServer.set_locale(str(options.locale))
	if kind == "menu":
		global.load_menu()
		await _capture("menu", false)
	elif kind == "play":
		global.new_game()
		await _capture("play", true)
	else:
		global.new_game()
		await _smoke()


func _capture(shot_name: String, launch: bool) -> void:
	for _i in 10:
		await get_tree().process_frame
	if launch:
		await RenderingServer.frame_post_draw
		_save("ready")
		var board = get_tree().current_scene
		if board and board.has_method("launch_from_shot"):
			board.launch_from_shot()
		await get_tree().create_timer(0.9).timeout
	await RenderingServer.frame_post_draw
	var err := _save(shot_name)
	get_tree().quit(0 if err == OK else 1)


func _save(shot_name: String) -> int:
	var img := get_viewport().get_texture().get_image()
	var dir := OS.get_environment("SHOT_DIR")
	if dir == "":
		dir = "user://"
	if not dir.ends_with("/"):
		dir += "/"
	var path := dir + "shot_%s.png" % shot_name
	var err := img.save_png(path)
	print("SHOT_SAVED ", path, " err=", err, " size=", img.get_size())
	return err


func _smoke() -> void:
	for _i in 25:
		await get_tree().process_frame
	var board = get_tree().current_scene
	if board == null or not board.has_method("launch_from_shot"):
		push_error("SMOKE missing board")
		get_tree().quit(1)
		return
	board.launch_from_shot()
	for _i in 360:
		await get_tree().process_frame
	if int(board.bricks_left) <= 0:
		push_error("SMOKE no bricks")
		get_tree().quit(1)
		return
	if int(board.score) <= 0:
		push_error("SMOKE ball never scored")
		get_tree().quit(1)
		return
	print("SMOKE_OK bricks=", board.bricks_left, " balls=", board.balls_in_game, " score=", board.score)
	get_tree().quit(0)
