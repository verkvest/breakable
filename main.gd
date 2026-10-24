extends Node


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.has("--shot-menu") or args.has("--shot-play") or args.has("--smoke"):
		return
	var options: Dictionary = options_manager.read_options()
	if bool(options.get("full_screen", false)):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if options.has("locale"):
		TranslationServer.set_locale(str(options.locale))
	elif OS.get_locale().begins_with("fr"):
		TranslationServer.set_locale("fr")
	global.load_menu()
