extends "res://enceladus/Repairs.gd"

var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

var repairStepAmount = 0.5


var printable_status = "Operation status: [system: %s; status: %s; operation: %s]"
var appraisal_status = "Appraisal status: [system: %s; mode: %s; operation: %s]"


func createRepairMenuFor(ship):
	.createRepairMenuFor(ship)
#	yield(get_tree(),"idle_frame")
#	yield(ship,"systemPoll")
	
	if ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","automatic_repairs") and handleFocuses(ship):
		var validSystems = []
		for b in systemsBox.get_children():
#			yield(get_tree(),"idle_frame")
#			yield(b,"fixed")
			if b.visible and isValidForAuto(b):
				validSystems.append(b)
		for b in validSystems:
				var retry = true
				
				var mode = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","method_priority")
				var max_repair = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","maximum_repair")
				var max_replace = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","maximum_replace")
				var min_cash = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","minimum_money")
				var min_insurance = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","minimum_insurance")
				var target = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","target_percent")
				
				var shouldOnlyMode = 0
				
				var mustTarget = false
				
				match mode:
					"VP_AUTOREPAIR_PRIORITY_COSTEFFECTIVE":
						mustTarget = true
					"VP_AUTOREPAIR_PRIORITY_ONLYREPAIR":
						shouldOnlyMode = 1
					"VP_AUTOREPAIR_PRIORITY_ONLYREPLACE":
						shouldOnlyMode = 2
					"VP_AUTOREPAIR_PRIORITY_MAXPROFIT":
						target = 100
				while retry:
					
					var currentCash = CurrentGame.getMoney()
					var currentInsurance = CurrentGame.getInsurance()
					
					var can_afford = true
					
					if min_insurance > 0:
						if currentInsurance < min_insurance:
							can_afford = false
					else:
						if currentCash + currentInsurance < min_cash:
							can_afford = false
					
					if can_afford:
						if shouldOnlyMode > 0 :
							var status = b.system.status
							match shouldOnlyMode:
								1:
									if status < target:
										retry = fixIfCan(b,ship)
									else:
										retry = false
								2:
									retry = replaceIfCan(b,ship)
						else:
							retry = handle_operation(b,target,currentCash,mustTarget,ship)
					else:
						retry = false
					wait(10)

func wait(frames):
	for i in range(frames):
		yield(get_tree(),"idle_frame")

func replaceIfCan(b,ship):
	if b.isReplaceable(b.system):
		print(printable_status % [b.system.name,b.system.status,"replace"])
		b.doReplaceSystem()
#		yield(b,"fixed")
		handleFocuses(ship)
	return false

func fixIfCan(b,ship):
	if b.shouldBeFixed(b.system):
		print(printable_status % [b.system.name,b.system.status,"fix"])
		b.doFixSystem()
#		yield(b,"fixed")
		handleFocuses(ship)
		return true
	else:
		print(printable_status % [b.system.name,b.system.status,"skip (cannot fix)"])
		return false

func handleFocuses(ship):
	yield(get_tree(),"idle_frame")
#	yield(ship,"systemPoll")
	var focused = false
	for b in systemsBox.get_children():
		if b.visible:
			b.fixButton.grab_focus()
			focused = true
			break
	if not focused:
		get_node("Autorepairs/PanelContainer/Buttons/Autorepairs").grab_focus()
	return focused

func handle_operation(b,target,currentCash,mustTarget,ship):
	var retry = true
	var action = appraise_for_cost_efficiency(b,mustTarget)
	match action:
		0:
			print(printable_status % [b.system.name,b.system.status,"skip (inefficient)"])
			retry = false
		1:
			var fixPrice = b.fixPrice(b.system)
			if b.system.status >= target:
				retry = false
				print(printable_status % [b.system.name,b.system.status,"skip (target passed)"])
			else:
				if fixPrice <= currentCash:
					retry = fixIfCan(b,ship)
				else:
					print(printable_status % [b.system.name,b.system.status,"skip (insufficient money)"])
					retry = false
		2:
			var replacePrice = b.replacementPrice(b.system)
			if b.system.status >= target:
				retry = false
			else:
				if replacePrice <= currentCash:
					retry = replaceIfCan(b,ship)
				else:
					retry = false
			
			retry = false
	
	handleFocuses(ship)
	return retry

func isValidForAuto(box) -> bool:
	var mode = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","method_priority")
	var target = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","target_percent")
	if not "repairReplacementPrice" in box.system.ref:
		return false
	if not "repairFixPrice" in box.system.ref:
		return false
	if box.system.status >= 99.5:
				return false
	match mode:
		"VP_AUTOREPAIR_PRIORITY_COSTEFFECTIVE","VP_AUTOREPAIR_PRIORITY_ONLYREPAIR":
			if box.system.status >= target:
				return false
	return true



func appraise_for_cost_efficiency(box,mustTarget):
	var sys = box.system
	if box.shouldBeFixed(sys):
		var cycles = box.appriseRequiredRepairSteps()
		var opt = cost_effective_action(box,0,cycles)
		if mustTarget and opt == 0:
			opt = 1
			print(appraisal_status % [box.system.name,opt,"force repair (target not met)"])
		return opt
	else:
		breakpoint







#	if ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","automatic_repairs"):
#		var mode = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","method_priority")
#		for i in systemsBox.get_children():
#			if i.has_method("isFubar"):
#				handle_repair_key(mode,i)

#func updateStatuses(ship):
#	.updateStatuses(ship)
	


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
		if adjust and pf < 1:
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

func simulate_replace(system):
	var after_repair = system.duplicate(true)
	after_repair.damage.clear()
	for d in system.damage:
		var newdmg = d.duplicate(true)
		var total = 0
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
	
	var newstatus = clamp(100 - max(max(dmg1, dmg2), dmg3) * 100, 0, 100)
	after_repair.status = newstatus
	return after_repair

func is_repair_cost_effective(system,specific_cycle,total_cycles):
	var ref = system.ref
	var fix_price = ref.repairFixPrice
	var offset = price_offset_after_repair(system,specific_cycle,total_cycles)
	
	return fix_price < offset

func cost_effective_action(box,specific_cycle,total_cycles):
	var system = box.system
	var ref = system.ref
	var fix_price = ref.repairFixPrice
	var current = getSystemPrice(simulate_repair(system,specific_cycle,total_cycles),true)
	var repair = getSystemPrice(simulate_repair(system,specific_cycle + 1,total_cycles),true)
	var replace = getSystemPrice(simulate_replace(system),false)
	
	var repair_value_gained = repair - current
	var replace_value_gained = replace - current
	
	var repairEffective = fix_price < repair_value_gained
	var replaceEffective = replace_value_gained > current
	
	var mode = 0
	if repairEffective:
		mode = 1
	if replaceEffective:
		mode = 2
	if repairEffective and replaceEffective:
		if repair_value_gained > replace_value_gained:
			mode = 1
		else:
			mode = 2
	match mode:
		0:
			print(appraisal_status % [box.system.name,mode,"skip (all options lose money)"])
		1:
			print(appraisal_status % [box.system.name,mode,"repair (most cost effective)"])
		2:
			print(appraisal_status % [box.system.name,mode,"replace (most cost effective)"])
	return mode

func price_offset_after_repair(system,specific_cycle,total_cycles):
	var current = getSystemPrice(simulate_repair(system,specific_cycle,total_cycles),true)
	var sim = getSystemPrice(simulate_repair(system,specific_cycle + 1,total_cycles),true)
	var difference = sim - current
	return difference

func price_offset_after_replace(system,specific_cycle,total_cycles):
	var current = getSystemPrice(simulate_repair(system,specific_cycle,total_cycles),true)
	var sim = getSystemPrice(simulate_replace(system),false)
	var difference = sim - current
	return difference
