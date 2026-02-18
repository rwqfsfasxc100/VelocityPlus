extends Control


func move():
	var pos = get_parent().get_parent().rect_global_position# + get_parent().rect_global_position
	rect_position = Vector2(-pos.x + 10,55)

func _process(delta):
	if is_visible_in_tree():
		move()
