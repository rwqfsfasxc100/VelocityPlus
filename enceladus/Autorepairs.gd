extends Popup

export (NodePath) var systems
onready var sys = get_node_or_null(systems)



func _visibility_changed():
	var pos = get_parent().get_parent().rect_global_position# + get_parent().rect_global_position
	yield(get_tree(),"idle_frame")
	get_parent().rect_position = Vector2(-pos.x + 10,55)

