extends StaticBody2D

@export var orientation := "horizontal"
@export var color := Color(0.2, 0.72, 0.62, 1)
@export var width := 16.0
@export var length := 400.0


func _ready() -> void:
	var mat := PhysicsMaterial.new()
	mat.friction = 0.0
	mat.bounce = 1.0
	physics_material_override = mat
	update_wall()


func update_wall() -> void:
	var col := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col == null:
		return
	var shape := RectangleShape2D.new()
	if orientation == "horizontal":
		shape.size = Vector2(length, width)
	else:
		shape.size = Vector2(width, length)
	col.shape = shape
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(-length * 0.5, -width * 0.5, length, width)
	if orientation != "horizontal":
		rect = Rect2(-width * 0.5, -length * 0.5, width, length)
	draw_rect(rect, color)


func set_orientation(value: String) -> void:
	orientation = value
	update_wall()


func set_color(value: Color) -> void:
	color = value
	queue_redraw()


func set_width(value: float) -> void:
	width = value
	update_wall()


func set_length(value: float) -> void:
	length = value
	update_wall()
