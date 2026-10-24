extends RigidBody2D

var effect := ""


func _ready() -> void:
	gravity_scale = 0.0
	can_sleep = false
	lock_rotation = true
	var sum := 0
	for key in global.bonus_effect.keys():
		sum += int(global.bonus_effect[key])
	var choice := randi() % maxi(sum, 1)
	var running := 0
	effect = ""
	for key in global.bonus_effect.keys():
		running += int(global.bonus_effect[key])
		if choice <= running and effect == "":
			effect = str(key)
	if global.bonus_texture.has(effect):
		$sprite.texture = global.bonus_texture[effect]
	var m: Dictionary = global.metrics()
	var target: float = m.brick_h * 1.2
	if $sprite.texture:
		var tex: Vector2 = $sprite.texture.get_size()
		$sprite.scale = Vector2(target / tex.x, target / tex.y)
	var shape := CircleShape2D.new()
	shape.radius = target * 0.42
	$CollisionShape2D.shape = shape


func start() -> void:
	var m: Dictionary = global.metrics()
	linear_velocity = Vector2(0, m.height * 0.28)
