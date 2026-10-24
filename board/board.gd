extends Node

const TAP_SLOP := 36.0

var pause_scene: PackedScene = preload("res://pause_dialog/pause_dialog.tscn")
var ball_scene: PackedScene = preload("res://ball/ball.tscn")
var bonus_scene: PackedScene = preload("res://bonus/bonus.tscn")

var current_level := 1
var playing := false
var lifes := 3
var score := 0
var current_speed := 400.0
var multiplier := 0
var bricks_left := 0
var bricks_since_last_bonus := 0
var balls_in_game := 0
var sticky := false

var _finger := -1
var _touch_start := Vector2.ZERO
var _touch_moved := false
var _pause_open := false
var _clearing := false


func _ready() -> void:
	nc.add_observer(self, "brick_hit", "brick_hit")
	nc.add_observer(self, "paddle_hit", "paddle_hit")
	nc.add_observer(self, "wall_hit", "wall_hit")
	nc.add_observer(self, "bonus_hit", "bonus_hit")
	score = 0
	global.score = 0
	balls_in_game = 0
	set_lifes(3)
	bricks_since_last_bonus = 0
	current_level = 1
	$paddle.board = self
	if not get_viewport().size_changed.is_connected(_on_size_changed):
		get_viewport().size_changed.connect(_on_size_changed)
	init_level()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _exit_tree() -> void:
	nc.remove_observer(self, "brick_hit")
	nc.remove_observer(self, "paddle_hit")
	nc.remove_observer(self, "wall_hit")
	nc.remove_observer(self, "bonus_hit")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_size_changed() -> void:
	_layout_frame(false)
	if not playing:
		_rebuild_pieces()


func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and _finger == -1:
			_finger = touch.index
			_touch_start = touch.position
			_touch_moved = false
			$paddle.move_to_x(touch.position.x)
		elif not touch.pressed and touch.index == _finger:
			var tapped := not _touch_moved and touch.position.distance_to(_touch_start) <= TAP_SLOP
			_finger = -1
			if tapped:
				_on_tap()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index != _finger:
			return
		if drag.position.distance_to(_touch_start) > TAP_SLOP:
			_touch_moved = true
		$paddle.move_to_x(drag.position.x)
	elif event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_ESCAPE:
			show_pause_dialog()
		elif key.keycode == KEY_SPACE or key.keycode == KEY_ENTER:
			_on_tap()
		elif key.keycode == KEY_LEFT or key.keycode == KEY_A:
			$paddle.move_to_x($paddle.position.x - 48.0)
		elif key.keycode == KEY_RIGHT or key.keycode == KEY_D:
			$paddle.move_to_x($paddle.position.x + 48.0)


func _on_tap() -> void:
	if playing:
		$bonus_effect_manager.fire_effect()
	else:
		launch_ball()


func launch_from_shot() -> void:
	var m: Dictionary = global.metrics()
	$paddle.move_to_x((m.left + m.right) * 0.5)
	launch_ball()


func launch_ball() -> void:
	if playing or get_tree().paused:
		return
	playing = true
	multiplier = 0
	$game_ui.set_multiplier(0)
	$game_ui.set_running(true)
	start_ball()


func show_pause_dialog() -> void:
	if _pause_open:
		return
	_pause_open = true
	var dialog := pause_scene.instantiate()
	dialog.delegate = self
	add_child(dialog)
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func close_dialog(dialog, response: Dictionary) -> void:
	_pause_open = false
	dialog.queue_free()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if str(response.get("message", "")) != "Continue":
		global.load_menu()


func init_level() -> void:
	playing = false
	sticky = false
	multiplier = 0
	_clearing = false
	current_speed = global.base_ball_speed()
	_layout_frame(true)
	_rebuild_pieces()
	$game_ui.show_level_clear(false)
	$game_ui.set_running(false)
	$game_ui.set_score(score)
	$game_ui.set_multiplier(0)
	$game_ui.set_lifes(lifes - 1)
	$bonus_effect_manager.current_effect = ""


func _rebuild_pieces() -> void:
	_sweep_play_pieces()
	$level.load_level(current_level)
	bricks_left = $level.total_bricks
	create_ball(current_speed)
	$paddle.sync()


func _layout_frame(reset_paddle: bool) -> void:
	var m: Dictionary = global.metrics()
	var wall_color := Color(0.18, 0.7, 0.6, 1)
	var span_h: float = (m.bottom - m.top) + m.wall
	$left_wall.position = Vector2(m.left - m.wall * 0.5, (m.top + m.bottom) * 0.5)
	$left_wall.set_orientation("vertical")
	$left_wall.set_width(m.wall)
	$left_wall.set_length(span_h)
	$left_wall.set_color(wall_color)
	$right_wall.position = Vector2(m.right + m.wall * 0.5, (m.top + m.bottom) * 0.5)
	$right_wall.set_orientation("vertical")
	$right_wall.set_width(m.wall)
	$right_wall.set_length(span_h)
	$right_wall.set_color(wall_color)
	$top_wall.position = Vector2((m.left + m.right) * 0.5, m.top - m.wall * 0.5)
	$top_wall.set_orientation("horizontal")
	$top_wall.set_width(m.wall)
	$top_wall.set_length(m.width + m.wall * 2.0)
	$top_wall.set_color(wall_color)
	var lost_shape := RectangleShape2D.new()
	lost_shape.size = Vector2(m.width + m.wall * 4.0, 28.0)
	$area_lost.position = Vector2((m.left + m.right) * 0.5, m.bottom + 6.0)
	$area_lost/CollisionShape2D.shape = lost_shape
	if reset_paddle:
		$paddle.set_paddle_width(m.paddle_w)
		$paddle.position = Vector2((m.left + m.right) * 0.5, m.paddle_y)
	else:
		$paddle.sync()


func _sweep_play_pieces() -> void:
	var doomed: Array = []
	for child in get_children():
		if child.has_meta("type"):
			var kind := str(child.get_meta("type"))
			if kind == "ball" or kind == "bonus":
				doomed.append(child)
	for child in doomed:
		remove_child(child)
		child.queue_free()
	balls_in_game = 0


func create_ball(speed: float):
	var ball := ball_scene.instantiate()
	ball.board = self
	ball.set_meta("type", "ball")
	ball.set_speed(speed)
	add_child(ball)
	balls_in_game += 1
	return ball


func start_ball() -> void:
	for child in get_children():
		if child.has_meta("type") and child.get_meta("type") == "ball":
			child.start()
			return


func brick_hit(_observer, _notification_name, data) -> void:
	var brick = data.brick
	var ball = data.ball
	$brick_sound.play()
	multiplier += 1
	set_score(score + (10 * multiplier))
	current_speed += global.base_ball_speed() * 0.018
	ball.set_speed(current_speed)
	brick.set_current_hp(brick.current_hp - 1)
	if brick.current_hp == 0:
		generate_bonus(brick.position)
		brick.queue_free()
		bricks_left -= 1
		if bricks_left <= 0 and not _clearing:
			_clearing = true
			playing = false
			_level_cleared()


func _level_cleared() -> void:
	_sweep_play_pieces()
	$game_ui.show_level_clear(true)
	$game_ui.set_running(true)
	await get_tree().create_timer(1.15).timeout
	if not is_inside_tree():
		return
	current_level += 1
	if current_level > global.MAX_LEVEL:
		current_level = 1
	init_level()


func paddle_hit(_observer, _notification_name, _data) -> void:
	if playing:
		$pad_sound.play()
		multiplier = 0
		$game_ui.set_multiplier(0)


func wall_hit(_observer, _notification_name, _data) -> void:
	if playing:
		$wall_sound.play()


func bonus_hit(_observer, _notification_name, bonus) -> void:
	if is_instance_valid(bonus):
		bonus.queue_free()
	if playing:
		$bonus_effect_manager.apply_effect(bonus.effect)


func _on_area_lost_body_entered(body: Node) -> void:
	if not body.has_meta("type"):
		return
	var kind := str(body.get_meta("type"))
	if kind == "ball":
		if balls_in_game == 1:
			set_lifes(lifes - 1)
			$bonus_effect_manager.current_effect = ""
			sticky = false
			for child in get_children():
				if child.has_meta("type") and child.get_meta("type") == "bonus":
					child.queue_free()
			$paddle.set_paddle_width(global.metrics().paddle_w)
			if lifes <= 0:
				global.score = score
				global.load_game_over(score)
			else:
				playing = false
				$game_ui.set_running(false)
				create_ball(current_speed)
				$paddle.sync()
		if is_instance_valid(body):
			body.queue_free()
		balls_in_game = maxi(balls_in_game - 1, 0)
	elif kind == "bonus":
		body.queue_free()


func generate_bonus(pos: Vector2) -> void:
	if sticky:
		return
	var chance := bricks_since_last_bonus * bricks_since_last_bonus / 320.0
	var roll := randf()
	bricks_since_last_bonus += 1
	if roll < chance:
		bricks_since_last_bonus = 0
		var bonus := bonus_scene.instantiate()
		bonus.position = pos
		bonus.set_meta("type", "bonus")
		add_child(bonus)
		bonus.start()


func set_lifes(value: int) -> void:
	lifes = value
	$game_ui.set_lifes(lifes - 1)


func set_score(value: int) -> void:
	score = value
	global.score = value
	$game_ui.set_score(score)
	$game_ui.set_multiplier(multiplier)


func clone_ball(current_ball, count: int) -> void:
	for _i in count:
		var ball = create_ball(current_speed)
		ball.position = current_ball.position
		ball.start(false)


func unstick() -> void:
	sticky = false
	$game_ui/Safe/Column/Top/Message.text = ""
