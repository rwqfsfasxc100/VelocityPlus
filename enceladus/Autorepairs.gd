extends Control

func _visibility_changed():
	var pos = get_parent().rect_global_position# + get_parent().rect_global_position
	yield(get_tree(),"idle_frame")
	rect_position = Vector2(-pos.x + 10,55)

