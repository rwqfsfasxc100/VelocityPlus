extends Control

func _ready():
	var costEffective = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/CostEffectiveFixTo100/Action")
	var fix = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/RepairFixTo100/Action")
	var replace = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/ReplaceFixTo100/Action")
	var ce = get_node_or_null(costEffective)
	var f = get_node_or_null(fix)
	var r = get_node_or_null(replace)
	var p = get_parent().get_parent()
	if ce:
		ce.connect("pressed",p,"manual_cost_effective_repair")
	if f:
		f.connect("pressed",p,"manual_fix_repair")
	if r:
		r.connect("pressed",p,"manual_replace_repair")
	
	
	
	pass

func move():
	var pos = get_parent().get_parent().rect_global_position# + get_parent().rect_global_position
	rect_position = Vector2(-pos.x + 10,55)

func _process(delta):
	if is_visible_in_tree():
		move()
