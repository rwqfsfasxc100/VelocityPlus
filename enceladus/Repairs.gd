extends "res://enceladus/Repairs.gd"

var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func createRepairMenuFor(ship):
	.createRepairMenuFor(ship)
	if ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","automatic_repairs"):
		var mode = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","method_priority")
		for i in systemsBox.get_children():
			if i.has_method("isFubar"):
				handle_repair_key(mode,i)


func handle_repair_key(mode,menu):
	match mode:
		"VP_AUTOREPAIR_PRIORITY_COSTEFFECTIVE":
			calculate_repairs(true,true,true,true,menu)
		"VP_AUTOREPAIR_PRIORITY_ONLYREPAIR":
			calculate_repairs(true,false,true,false,menu)
		"VP_AUTOREPAIR_PRIORITY_ONLYREPLACE":
			calculate_repairs(false,true,false,false,menu)
		"VP_AUTOREPAIR_PRIORITY_MAXPROFIT":
			calculate_repairs(true,true,false,true,menu)
		

func calculate_repairs(can_repair:bool,can_replace:bool,match_target:bool,cost_effective:bool,button):
	var queue = {}
	if can_repair:
		queue.merge(repair_cycles(button.system))
	

func repair_cycles(system):
	var ref = system.ref
	if "repairReplacementPrice" in ref:
		pass
	else:
		return {}
	
	if "repairFixPrice" in ref:
		pass
	else:
		return {}
	
	var queue = {"repairs":0}
	var replace_price = ref.repairReplacementPrice
	var fix_price = ref.repairFixPrice
	var current_val = getSystemPrice(system)
	
	pass

func perform_repair(button):
	if button.shouldBeFixed(button.system):
		pass
	else:
		return false


func perform_replace(button):
	
	pass

func getSystemPrice(system,adjust = true):
	var pf = pow(system.status / 100, 2)
	var o = system.ref
	if o != null and "repairReplacementPrice" in o:
		if pf < 1 and adjust:
			pf *= 0.8
		return o.repairReplacementPrice * pf
	return 0.0
