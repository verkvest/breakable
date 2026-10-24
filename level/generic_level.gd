extends RefCounted


func init_level(_level_node: Node) -> int:
	return 0


func build(level_node: Node, rows: Array) -> int:
	var brick_scene: PackedScene = load("res://static_brick/static_brick.tscn")
	var m: Dictionary = global.metrics()
	var total := 0
	for i in rows.size():
		var line = rows[i]
		for j in int(m.cols):
			var hp := 0
			if j < line.size():
				hp = int(line[j])
			if hp <= 0:
				continue
			var b := brick_scene.instantiate()
			b.name = "brick_%d_%d" % [i, j]
			b.position = Vector2(
				m.left + j * (m.brick_w + m.sep) + m.brick_w * 0.5,
				m.top + 12.0 + i * (m.brick_h + m.sep) + m.brick_h * 0.5
			)
			b.set_meta("type", "brick")
			level_node.add_child(b)
			b.set_hp(hp)
			total += 1
	return total
