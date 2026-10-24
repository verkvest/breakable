extends Sprite2D


func _draw() -> void:
	var radius := 9.0
	if is_instance_valid(global):
		radius = float(global.metrics().ball_r)
	draw_circle(Vector2.ZERO, radius, Color(0.96, 0.95, 0.9))
	draw_circle(Vector2(-radius * 0.28, -radius * 0.28), radius * 0.28, Color(1, 1, 1, 0.85))
