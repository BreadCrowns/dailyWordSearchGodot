extends Line2D

var start_pos: Vector2 = Vector2.ZERO

func start(pos: Vector2):
	start_pos = pos
	clear_points()
	add_point(pos)

func update_line(current: Vector2):
	clear_points()
	add_point(start_pos)
	add_point(current)

func finish(end_pos: Vector2):
	clear_points()
	add_point(start_pos)
	add_point(end_pos)
