extends Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var body := "[font_size=28]%s[/font_size]\n\n" % tr("CREDITS_INTRO")
	body += """Clinkwell
Portrait brick-breaker for phones.
Bundle id: es.verkvest.clinkwell

[font_size=34]Original game[/font_size]
Breakable © 2015 Didier Vandekerckhove
Code, textures, and sound effects are MIT licensed.
The sounds were made by the author with cfxr.
GodotNotificationCenter © Didier Vandekerckhove, MIT.
https://github.com/didier-v/breakable

[font_size=34]Font[/font_size]
Nunito SemiBold
Copyright 2014 The Nunito Project Authors
(https://github.com/googlefonts/nunito)
SIL Open Font License 1.1
Bundled with fonts/OFL.txt. Nunito replaces Ricasso Regular, which shipped without a license.

[font_size=34]Engine[/font_size]
Godot Engine 4.7
Copyright (c) 2014-present Godot Engine contributors.
Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
MIT License. https://godotengine.org

Full notices are in THIRD_PARTY_LICENSES.txt.
"""
	$Safe/Column/Scroll/Body.text = body


func _on_back_pressed() -> void:
	global.load_menu()
