extends Node2D

var board
var paddle_width := 120.0


func _ready() -> void:
	set_paddle_width(global.metrics().paddle_w)


func move_to_x(x: float) -> void:
	var m: Dictionary = global.metrics()
	var half := paddle_width * 0.5
	position.x = clampf(x, m.left + half, m.right - half)
	position.y = m.paddle_y
	_notify_moved()


func sync() -> void:
	var m: Dictionary = global.metrics()
	position.y = m.paddle_y
	var half := paddle_width * 0.5
	position.x = clampf(position.x, m.left + half, m.right - half)
	_notify_moved()


func _notify_moved() -> void:
	if board and (board.sticky or not board.playing):
		nc.post_notification("paddle_moved", position)


func set_paddle_width(pw: float) -> void:
	var m: Dictionary = global.metrics()
	paddle_width = clampf(pw, m.paddle_w * 0.55, m.width * 0.78)
	_update_visual()
	_update_shape()
	if is_inside_tree() and board:
		move_to_x(position.x)


func _update_shape() -> void:
	var col := get_node_or_null("paddle_area/CollisionShape2D") as CollisionShape2D
	if col == null:
		return
	var shape := RectangleShape2D.new()
	shape.size = Vector2(paddle_width, global.PADDLE_VISUAL_HEIGHT)
	col.shape = shape


func _update_visual() -> void:
	var scale_y := global.PADDLE_VISUAL_HEIGHT / 15.0
	var cap_w := 16.0 * scale_y
	if has_node("left"):
		$left.centered = false
		$left.scale = Vector2(scale_y, scale_y)
		$left.position = Vector2(-paddle_width * 0.5, -global.PADDLE_VISUAL_HEIGHT * 0.5)
	if has_node("right"):
		$right.centered = false
		$right.scale = Vector2(scale_y, scale_y)
		$right.position = Vector2(paddle_width * 0.5 - cap_w, -global.PADDLE_VISUAL_HEIGHT * 0.5)
	if has_node("middle"):
		var mid_w := maxf(paddle_width - cap_w * 2.0, 4.0)
		$middle.scale = Vector2(mid_w / 20.0, scale_y)
		$middle.position = Vector2(0, 0)


func _on_area_body_entered(body: Node) -> void:
	if not body.has_meta("type"):
		return
	if body.get_meta("type") == "ball":
		var ball := body as RigidBody2D
		if ball == null:
			return
		var velocity: Vector2 = ball.linear_velocity
		velocity.y = -absf(velocity.y)
		var relative: float = ball.position.x - position.x
		nc.post_notification("paddle_hit", relative)
		var coeff: float = relative / maxf(paddle_width, 1.0)
		var angle: float = coeff * PI / 2.4
		velocity = velocity.rotated(angle)
		if velocity.length() > 1.0:
			var spd: float = float(ball.get("speed"))
			ball.linear_velocity = velocity.normalized() * spd
		if ball.has_method("adjust_angle"):
			ball.adjust_angle()
	elif body.get_meta("type") == "bonus":
		nc.post_notification("bonus_hit", body)
