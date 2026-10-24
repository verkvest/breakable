extends MarginContainer

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not get_viewport().size_changed.is_connected(_apply):
		get_viewport().size_changed.connect(_apply)
	_apply()


func _apply() -> void:
	var inset: Vector4 = global.safe_insets()
	var pad := 18
	add_theme_constant_override("margin_left", int(inset.x) + pad)
	add_theme_constant_override("margin_top", int(inset.y) + pad)
	add_theme_constant_override("margin_right", int(inset.z) + pad)
	add_theme_constant_override("margin_bottom", int(inset.w) + pad)
