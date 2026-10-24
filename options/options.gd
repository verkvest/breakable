extends Control

var options: Dictionary = {}
var languages := ["en", "fr"]


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	options = options_manager.read_options()
	var current := TranslationServer.get_locale()
	var picker: OptionButton = $Safe/Center/Column/Language
	for i in languages.size():
		picker.add_item(languages[i].to_upper(), i)
		if current.begins_with(languages[i]):
			picker.select(i)
	var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	$Safe/Center/Column/Fullscreen.button_pressed = fullscreen
	if OS.has_feature("mobile"):
		$Safe/Center/Column/Fullscreen.visible = false


func _on_back_pressed() -> void:
	global.load_menu()


func _on_language_selected(index: int) -> void:
	if index < 0 or index >= languages.size():
		return
	var locale := languages[index]
	TranslationServer.set_locale(locale)
	options["locale"] = locale
	options_manager.write_options(options)
	global.load_options()


func _on_fullscreen_toggled(pressed: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if pressed else DisplayServer.WINDOW_MODE_WINDOWED
	)
	options["full_screen"] = pressed
	options_manager.write_options(options)
