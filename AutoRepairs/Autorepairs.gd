extends Control

func _ready():
	var costEffective = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/CostEffectiveFixTo100/Action")
	var fix = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/RepairFixTo100/Action")
	var replace = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/ReplaceFixTo100/Action")
	var profit = NodePath( "Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MaxProfit/Action" )
	var ce = get_node_or_null(costEffective)
	var f = get_node_or_null(fix)
	var r = get_node_or_null(replace)
	var pr = get_node_or_null(profit)
	
	var manual = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/RepairFromCurrentOperands/Action")
	var manual_costEffective = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/FixToCurrent/Action")
	var manual_fix = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/RepairToCurrent/Action")
	var manual_replace = NodePath("Popup/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/ReplaceToCurrent/Action")
	var m = get_node_or_null(manual)
	var mce = get_node_or_null(manual_costEffective)
	var mf = get_node_or_null(manual_fix)
	var mr = get_node_or_null(manual_replace)
	
	
	var p = get_parent().get_parent()
	if ce:
		ce.connect("pressed",p,"manual_cost_effective_repair")
	if f:
		f.connect("pressed",p,"manual_fix_repair")
	if r:
		r.connect("pressed",p,"manual_replace_repair")
	if pr:
		pr.connect("pressed",p,"manual_max_profit")
	if m:
		m.connect("pressed",p,"manual_current")
	if mce:
		mce.connect("pressed",p,"manual_ce")
	if mf:
		mf.connect("pressed",p,"manual_f")
	if mr:
		mr.connect("pressed",p,"manual_r")
	
	
	pass

func move():
	var pos = get_parent().get_parent().rect_global_position# + get_parent().rect_global_position
	rect_position = Vector2(-pos.x + 10,55)

func _process(delta):
	if is_visible_in_tree():
		move()
