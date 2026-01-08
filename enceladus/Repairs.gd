extends "res://enceladus/Repairs.gd"

var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

var repairStepAmount = 0.5


var printable_status = "VelocityPlus AutoRepair Operation status: [system: %s; status: %s; operation: %s]"
var appraisal_status = "VelocityPlus AutoRepair Appraisal status: [system: %s; mode: %s; operation: %s]"
var force_appraisal_status = "VelocityPlus AutoRepair Appraisal status: [system: %s; repairs: %s; decision: %s]"
var multiappraisal_status = "VelocityPlus AutoRepair Appraisal status: [system: %s; repairs: %s; replace: %s; decision: %s]"


func createRepairMenuFor(ship):
	.createRepairMenuFor(ship)
#	yield(get_tree(),"idle_frame")
#	yield(ship,"systemPoll")
	
	if ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","automatic_repairs") and handleFocuses(ship):
		var validSystems = []
		var mode = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","method_priority")
		Debug.l("VelocityPlus AutoRepair: Attempting repairs on ship %s %s [%s], using repair mode [%s]" % [ship.getTransponder(),ship.getShipName(),TranslationServer.translate(ship.shipName),TranslationServer.translate(mode)])
		for b in systemsBox.get_children():
#			yield(get_tree(),"idle_frame")
#			yield(b,"fixed")
			if b.visible and isValidForAuto(b):
				validSystems.append(b)
#		for b in validSystems:
#			can_update(false,b)
		for b in validSystems:
			
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
					mustTarget = true
				"VP_AUTOREPAIR_PRIORITY_ONLYREPLACE":
					shouldOnlyMode = 2
				"VP_AUTOREPAIR_PRIORITY_MAXPROFIT":
					target = 100
			
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
				var available_cash = 0
				if min_insurance > 0:
					available_cash = currentInsurance - min_insurance
				else:
					available_cash = (currentCash + currentInsurance) - min_cash
				handle_operation(b,target,available_cash,mustTarget,ship,shouldOnlyMode,target)
#					clear_next(b)
#				yield(wait(1),"completed")
#		for b in validSystems:
#			can_update(true,b)
#			b.updateStatuses()

func can_update(can,b):
	if "allow_hide" in b:
		b.allow_hide = can
	clear_next(b)
	b.set_process(can)
	b.set_physics_process(can)
	for i in b.get_children():
		can_update(can,i)

func clear_next(b):
	if "next" in b and "tooltipLabel" in b and b.tooltipLabel:
		b.next.clear()
	for i in b.get_children():
		clear_next(i)

func wait(frames):
	while frames > 0:
#		yield(get_tree(),"idle_frame")
		frames -= 1

func replaceIfCan(b,ship):
	if b.isReplaceable(b.system):
		Debug.l(printable_status % [b.system.name,b.system.status,"replace"])
		b.doReplaceSystem()
#		yield(b,"fixed")
		handleFocuses(ship)
	else:
		Debug.l(printable_status % [b.system.name,b.system.status,"skip (cannot replace)"])
	return false

func fixIfCan(b,ship):
	if b.shouldBeFixed(b.system):
		Debug.l(printable_status % [b.system.name,b.system.status,"fix"])
		b.doFixSystem()
#		yield(b,"fixed")
		handleFocuses(ship)
		return true
	else:
		Debug.l(printable_status % [b.system.name,b.system.status,"skip (cannot fix)"])
		return false

func handleFocuses(ship):
#	yield(get_tree(),"idle_frame")
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

func handle_operation(b,target,available_cash,mustTarget,ship,forceMode,targetVal):
	var action_list = appraise_for_cost_efficiency(b,mustTarget,forceMode,targetVal)
	var max_repair = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","maximum_repair")
	var max_replace = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","maximum_replace")
	
	var repairs = action_list[0]
	var replace = action_list[1]
	var replaceCost = action_list[2]
	var fixPrice = b.fixPrice(b.system)
	
	var affordable_repairs = 0
	
	var current_cost = 0
	
	for i in range(repairs):
		if available_cash >= fixPrice:
			current_cost += fixPrice
			available_cash -= fixPrice
			affordable_repairs += 1
		else:
			replace = false
			replaceCost = 0
	if replace:
		if available_cash >= replaceCost:
			pass
		else:
			replace = false
			replaceCost = 0
	
	
	for i in range(affordable_repairs):
		if fixPrice <= max_repair:
			fixIfCan(b,ship)
	if replace:
		if replaceCost <= max_replace:
			replaceIfCan(b,ship)
	
	
	handleFocuses(ship)
	return false

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



func appraise_for_cost_efficiency(box,mustTarget,forcemode,targetVal):
	var sys = box.system
	var current = getSystemPrice(simulate_repair(sys,0),true)
	var replace_value = box.system.ref.repairReplacementPrice
	var replaceCost = (replace_value - current)
	var action_list = [0,false,replaceCost]
	if box.shouldBeFixed(sys):
		var cycles = box.appriseRequiredRepairSteps()
		if forcemode == 0:
			action_list = cost_effective_action_list(box,cycles,targetVal)
		
		
		if mustTarget:
			var force_repairs = repairs_needed_to_target(box)
			if force_repairs > action_list[0]:
				action_list[0] = force_repairs
				Debug.l(force_appraisal_status % [box.system.name,force_repairs,"force repair (target not met)"])
		if forcemode == 2:
			action_list = [0,true,replaceCost]
	
	
	return action_list

func repairs_needed_to_target(box):
	var repairs = 0
	
	var maxRepairs = CurrentGame.getRepairLimit(true)
	var base_system = box.system
	var status = base_system.status
	var target = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","target_percent")
	var r = 1
	var system = simulate_repair(base_system,r)
	while status < target and status < maxRepairs and r < 8:
		status = simulate_status(system)
		repairs += 1
		
		r += 1
		system = simulate_repair(base_system,r)
	
	return repairs

func cost_effective_action_list(box,cycles,targetVal):
	
	var opts = {}
	
	var system = box.system
	var ref = system.ref
	var fix_price = ref.repairFixPrice
	var rx = simulate_repair(system,0)
	var init_status = simulate_status(rx)
	var current = getSystemPrice(rx,true)
	
	var replace_value = ref.repairReplacementPrice
	var replaceCost = (replace_value - current)
	opts.merge({0:{"repair":current,"replace":current - replaceCost,"replace_cost":replaceCost,"status":init_status}})
	for specific_cycle in range(cycles):
		var previous_cost = (specific_cycle * fix_price) + fix_price
		var c = specific_cycle + 1
		if simulate_repair(system,specific_cycle).status >= targetVal:
			break
		var rv = simulate_repair(system,c)
		var sim_status = simulate_status(rv)
		var repair = getSystemPrice(rv,true)
		
		var repair_gain = repair - previous_cost
		
		var replace_cost = replace_value - repair_gain
		var replace_gain = repair_gain - (replace_cost + previous_cost)
		
		opts.merge({c:{"repair":repair_gain,"replace":replace_gain,"replace_cost":replace_cost,"status":sim_status}})
		
	
	var best_value = 0
	
	var repairs_to_perform = 0
	var do_replace = false
	
	var replace_cost = 0
	
	for opt in opts:
		var d = opts[opt]
		var rv = d["repair"]
		var rp = d["replace"]
		if rv > best_value:
			best_value = rv
			do_replace = false
			repairs_to_perform = opt
		if rp > best_value:
			best_value = rp
			do_replace = true
			repairs_to_perform = opt
		if do_replace:
			replace_cost = d["replace_cost"]
		else:
			replace_cost = 0
	
	Debug.l(multiappraisal_status % [box.system.name,repairs_to_perform,do_replace,"cost efficiency appraisal decision, weights: \n\n" + JSON.print(opts,"\t") + "\n\n"])
	return [repairs_to_perform,do_replace,replace_cost]


func simulate_status(system):
	var damage = system["damage"]
	
	var dmg1 = damage[0]["current"] / damage[0]["max"]
	var dmg2 = damage[1]["current"] / damage[1]["max"]
	var dmg3 = damage[2]["current"] / damage[2]["max"]
	
	var newstatus = clamp(100 - max(max(dmg1, dmg2), dmg3) * 100, 0, 100)
	return newstatus


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
			var do = is_repair_cost_effective(system,i)
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

func simulate_repair(system,specific_cycle):
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

func is_repair_cost_effective(system,specific_cycle):
	var ref = system.ref
	var fix_price = ref.repairFixPrice
	var offset = price_offset_after_repair(system,specific_cycle)
	
	return fix_price < offset

func cost_effective_action(box,specific_cycle,total_cycles):
	var system = box.system
	var ref = system.ref
	var fix_price = ref.repairFixPrice
	var current = getSystemPrice(simulate_repair(system,specific_cycle),true)
	var repair = getSystemPrice(simulate_repair(system,specific_cycle + 1),true)
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
			Debug.l(appraisal_status % [box.system.name,mode,"skip (all options lose money)"])
		1:
			Debug.l(appraisal_status % [box.system.name,mode,"repair (most cost effective)"])
		2:
			Debug.l(appraisal_status % [box.system.name,mode,"replace (most cost effective)"])
	return mode

func price_offset_after_repair(system,specific_cycle):
	var current = getSystemPrice(simulate_repair(system,specific_cycle),true)
	var sim = getSystemPrice(simulate_repair(system,specific_cycle + 1),true)
	var difference = sim - current
	return difference

func price_offset_after_replace(system,specific_cycle):
	var current = getSystemPrice(simulate_repair(system,specific_cycle),true)
	var sim = getSystemPrice(simulate_replace(system),false)
	var difference = sim - current
	return difference
