extends RigidBody2D

var speed := 400.0
var active := false
var relative_pos_x := 0.0
var board
var paddle_position := Vector2.ZERO
var is_starting := false


func _ready() -> void:
	var mat := PhysicsMaterial.new()
	mat.friction = 0.0
	mat.bounce = 1.0
	physics_material_override = mat
	gravity_scale = 0.0
	contact_monitor = true
	max_contacts_reported = 4
	can_sleep = false
	lock_rotation = true
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	var radius := float(global.metrics().ball_r)
	var shape := CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape
	$Sprite2D.queue_redraw()
	set_active(false)
	nc.add_observer(self, "paddle_hit", "paddle_hit")
	nc.add_observer(self, "paddle_moved", "follow_paddle")


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if is_starting:
		state.transform = Transform2D(0.0, paddle_position)
		is_starting = false
	elif board and board.sticky and not active:
		state.transform = Transform2D(0.0, paddle_position)


func _exit_tree() -> void:
	nc.remove_observer(self, "paddle_moved")
	nc.remove_observer(self, "paddle_hit")


func _on_ball_body_entered(body: Node) -> void:
	if body.name == "brick_body":
		var brick = body.get_parent()
		nc.post_notification("brick_hit", {"brick": brick, "ball": self})
	elif "wall" in body.name:
		nc.post_notification("wall_hit", "")


func _on_ball_body_exited(body: Node) -> void:
	linear_velocity = linear_velocity.normalized() * speed
	if body.name == "brick_body":
		adjust_angle()


func adjust_angle() -> void:
	var min_angle := 20.0
	var lv := linear_velocity.normalized() * speed
	if lv.length() < 1.0:
		return
	var angle := rad_to_deg(lv.angle_to(Vector2(1, 0)))
	if angle > 0.0 and angle < min_angle:
		angle = angle - min_angle
	elif angle < 0.0 and angle > -min_angle:
		angle = angle + min_angle
	elif angle > 180.0 - min_angle and angle < 180.0:
		angle = angle - 180.0 + min_angle
	elif angle < -180.0 + min_angle and angle > -180.0:
		angle = angle + 180.0 - min_angle
	else:
		angle = 0.0
	if angle != 0.0:
		linear_velocity = lv.rotated(deg_to_rad(angle))


func start(from_paddle := true) -> void:
	is_starting = from_paddle
	set_active(true)
	var lv := Vector2(randf_range(-0.75, 0.75), -1.0).normalized() * speed
	linear_velocity = lv


func paddle_hit(_object, _action, data) -> void:
	if board and board.sticky:
		active = false
	if active:
		nc.remove_observer(self, "paddle_moved")
	else:
		relative_pos_x = float(data)
		nc.add_observer(self, "paddle_moved", "follow_paddle")


func follow_paddle(_object, _action, data) -> void:
	var pos: Vector2 = data
	var radius := float(global.metrics().ball_r)
	pos.y = pos.y - global.PADDLE_VISUAL_HEIGHT * 0.5 - radius - 3.0
	pos.x = pos.x + relative_pos_x
	var m: Dictionary = global.metrics()
	pos.x = clampf(pos.x, m.left + radius, m.right - radius)
	paddle_position = pos
	global_position = paddle_position


func set_active(is_active: bool) -> void:
	active = is_active


func set_speed(new_speed: float) -> void:
	speed = new_speed
