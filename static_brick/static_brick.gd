extends Node2D

var hp := 1
var current_hp := 1


func _ready() -> void:
	var mat := PhysicsMaterial.new()
	mat.friction = 0.0
	mat.bounce = 1.0
	$brick_body.physics_material_override = mat
	_fit()


func _fit() -> void:
	var m: Dictionary = global.metrics()
	var bw: float = m.brick_w
	var bh: float = m.brick_h
	var shape := RectangleShape2D.new()
	shape.size = Vector2(bw * 0.96, bh * 0.9)
	$brick_body/CollisionShape2D.shape = shape
	var sprite: Sprite2D = $Sprite2D
	if sprite.texture:
		var tex := sprite.texture.get_size()
		sprite.scale = Vector2(bw / tex.x, bh / tex.y)


func set_hp(new_hp: int) -> void:
	hp = new_hp
	set_current_hp(hp)


func set_current_hp(new_hp: int) -> void:
	current_hp = new_hp
	if current_hp > 0 and current_hp < global.brick_texture.size():
		$Sprite2D.texture = global.brick_texture[current_hp]
		_fit()
