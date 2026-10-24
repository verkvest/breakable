extends Control

var delegate


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func show_for(value: int, new_delegate) -> void:
	delegate = new_delegate
	$Card/Column/Value.text = str(value)
	$Card/Column/Name.text = ""
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	$Card/Column/Name.grab_focus()


func _submit() -> void:
	var playername := $Card/Column/Name.text
	if delegate and delegate.has_method("close_hi_score_dialog"):
		delegate.close_hi_score_dialog(self, playername)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_ok_pressed() -> void:
	_submit()


func _on_name_submitted(_new_text: String) -> void:
	_submit()
