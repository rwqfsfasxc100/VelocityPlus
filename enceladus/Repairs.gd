extends "res://enceladus/Repairs.gd"

var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

var repairStepAmount = 0.5


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
#		queue.merge()
		perform_repair(button,cost_effective)
	

func repair_cycles(system,cost_effective:bool,cycles:int):
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
	for i in range(cycles):
		if cost_effective:
			var do = is_repair_cost_effective(system,i,cycles)
			if do:
				queue.repairs += 1
			else:
				break
	pass
	
	
	
	
	return queue

func perform_repair(button,cost_effective:bool):
	if button.shouldBeFixed(button.system):
		var cycles = button.appriseRequiredRepairSteps()
		repair_cycles(button.system,cost_effective,cycles)
	else:
		return {}


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

func simulate_repair(system,specific_cycle,total_cycles):
	if specific_cycle == 0:
		return system
#	var ref2 = system.ref.duplicate(7)
	
	var after_repair = system.duplicate(true)
	after_repair.damage.clear()
	for d in system.damage:
		var newdmg = d.duplicate(true)
		for i in range(specific_cycle):
			var total = newdmg.current * repairStepAmount
			newdmg.current = total
		after_repair.damage.append(newdmg)
	var current = 0
	var dmg1 = 0.0
	var dmg2 = 0.0
	var dmg3 = 0.0
	for d in after_repair.damage:
		current += 1
		var val = d.current / d.max
		match current:
			1:
				dmg1 = val
			2:
				dmg2 = val
			3:
				dmg3 = val
	if dmg1 > 0.0 and dmg2 > 0.0 and dmg3 > 0.0:
		var newstatus = clamp(100 - max(max(dmg1, dmg2), dmg3) * 100, 0, 100)
		after_repair.status = newstatus
	return after_repair

func is_repair_cost_effective(system,specific_cycle,total_cycles):
	var ref = system.ref
	var fix_price = ref.repairFixPrice
	var offset = price_offset_after_repair(system,specific_cycle,total_cycles)
	
	return fix_price < offset

func price_offset_after_repair(system,specific_cycle,total_cycles):
	var current = getSystemPrice(simulate_repair(system,specific_cycle,total_cycles),specific_cycle + 1 != total_cycles)
	var sim = getSystemPrice(simulate_repair(system,specific_cycle + 1,total_cycles),specific_cycle + 1 != total_cycles)
	var difference = sim - current
	return difference
