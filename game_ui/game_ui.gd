extends CanvasLayer

@onready var lives_label: Label = $Safe/Column/Top/Lives
@onready var message_label: Label = $Safe/Column/Top/Message
@onready var score_label: Label = $Safe/Column/Top/Score
@onready var multiplier_label: Label = $Safe/Column/Top/Multiplier
@onready var hint_label: Label = $Safe/Column/Hint
@onready var level_clear: Label = $LevelClear

var _message_tween: Tween
var _mult_tween: Tween


func _ready() -> void:
	nc.add_observer(self, "show_bonus_message", "show_bonus_message")
	level_clear.visible = false
	message_label.text = ""


func _exit_tree() -> void:
	nc.remove_observer(self, "show_bonus_message")


func set_score(value: int) -> void:
	score_label.text = str(value)


func set_multiplier(multiplier: int) -> void:
	multiplier_label.visible = multiplier > 0
	multiplier_label.text = "x%02d" % multiplier
	if multiplier > 1:
		if _mult_tween:
			_mult_tween.kill()
		multiplier_label.modulate = Color(1, 1, 1)
		_mult_tween = create_tween()
		_mult_tween.tween_property(multiplier_label, "modulate", Color(1, 0.45, 0.35), 0.12)
		_mult_tween.tween_property(multiplier_label, "modulate", Color(1, 0.85, 0.75), 0.28)


func set_lifes(lives: int) -> void:
	lives_label.text = "● %d" % maxi(lives, 0)


func set_running(running: bool) -> void:
	hint_label.visible = not running


func show_level_clear(on: bool) -> void:
	level_clear.visible = on


func show_bonus_message(_observer, _notification_name, effect) -> void:
	var key := str(global.bonus_message.get(str(effect), effect))
	message_label.text = key
	message_label.modulate.a = 1.0
	if _message_tween:
		_message_tween.kill()
	_message_tween = create_tween()
	_message_tween.tween_interval(1.5)
	_message_tween.tween_property(message_label, "modulate:a", 0.0, 0.35)


func _on_pause_pressed() -> void:
	var board = get_parent()
	if board and board.has_method("show_pause_dialog"):
		board.show_pause_dialog()
