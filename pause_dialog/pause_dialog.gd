extends CanvasLayer

var delegate


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_continue_pressed()


func _on_continue_pressed() -> void:
	if delegate and delegate.has_method("close_dialog"):
		delegate.close_dialog(self, {"message": "Continue"})


func _on_abandon_pressed() -> void:
	if delegate and delegate.has_method("close_dialog"):
		delegate.close_dialog(self, {"message": "Cancel"})
