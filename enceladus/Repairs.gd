extends "res://enceladus/Repairs.gd"

var repairStepAmount = 0.5


var pointersVP

func _enter_tree():
	pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()
	set_physics_process(false)

func updateValues():
	if pointersVP:
		cfg_do_automatic_repairs = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","automatic_repairs")
		cfg_method_priority = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","method_priority")
		cfg_max_repair = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","maximum_repair")
		cfg_max_replace = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","maximum_replace")
		cfg_min_cash = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","minimum_money")
		cfg_min_insurance = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","minimum_insurance")
		cfg_target = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","target_percent")
		
		

var cfg_do_automatic_repairs = false
var cfg_method_priority = "VP_AUTOREPAIR_PRIORITY_COSTEFFECTIVE"
var cfg_max_repair = 250000
var cfg_max_replace = 2500000
var cfg_min_cash = 100000
var cfg_min_insurance = 0
var cfg_target = 70

var printable_status = "VelocityPlus AutoRepair Operation status: [system: %s; status: %s; operation: %s]"
var appraisal_status = "VelocityPlus AutoRepair Appraisal status: [system: %s; mode: %s; operation: %s]"
var force_appraisal_status = "VelocityPlus AutoRepair Appraisal status: [system: %s; repairs missing: %s; decision: %s]"
var force_appraisal_decision = "VelocityPlus AutoRepair Appraisal status: [system: %s; operation: %s; decision: %s]"
var multiappraisal_status = "VelocityPlus AutoRepair Appraisal status: [system: %s; repairs: %s; replace: %s; decision: %s]"

var queued_repairs = []

var yield_frame = true
func _physics_process(delta):
	if queued_repairs.size() > 0:
		if not visible or $Shower.is_playing():
			return
		if yield_frame:
			yield_frame = false
		else:
			var pq = queued_repairs.pop_front()
			match pq[1]:
				"fix":
					pq[0].doFixSystem()
				"replace":
					pq[0].doReplaceSystem()
			yield_frame = true
	else:
		set_physics_process(false)

func createRepairMenuFor(ship):
	.createRepairMenuFor(ship)
#	yield(get_tree(),"idle_frame")
#	yield(ship,"systemPoll")
	
	if cfg_do_automatic_repairs and handleFocuses(ship):
		var validSystems = []
		var mode = cfg_method_priority
		Debug.l("VelocityPlus AutoRepair: Attempting repairs on ship %s %s [%s], using repair mode [%s]" % [ship.getTransponder(),ship.getShipName(),TranslationServer.translate(ship.shipName),TranslationServer.translate(mode)])
		for b in systemsBox.get_children():
#			yield(get_tree(),"idle_frame")
#			yield(b,"fixed")
			if b.visible and isValidForAuto(b):
				validSystems.append(b)
#		for b in validSystems:
#			can_update(false,b)
		for b in validSystems:
			
			var max_repair = cfg_max_repair
			var max_replace = cfg_max_replace
			var min_cash = cfg_min_cash
			var min_insurance = cfg_min_insurance
			var target = cfg_target
			
			var shouldOnlyMode = 0
			
			var mustTarget = false
			
			match mode:
				"VP_AUTOREPAIR_PRIORITY_COSTEFFECTIVE":
					mustTarget = true
				"VP_AUTOREPAIR_PRIORITY_ONLYREPAIR":
					mustTarget = true
					shouldOnlyMode = 1
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
				handle_operation(b,available_cash,mustTarget,ship,shouldOnlyMode,target)
		if queued_repairs.size() > 0:
			set_physics_process(true)
	handleFocuses(ship)

func replaceIfCan(b,ship,cycle = 0):
	if b.isReplaceable(b.system):
		var sim = b.system.duplicate(true)
		var s = simulate_repair(sim,cycle + 1)
		var stat = b.system.status
		var status = simulate_status(s)
		if stat < status:
			stat = status
		Tool.remove(s)
		Tool.remove(sim)
		Debug.l(printable_status % [b.system.name,stat,"replace"])
		queued_repairs.append([b,"replace"])
#		b.doReplaceSystem()
#		yield(b,"fixed")
#		handleFocuses(ship)
	else:
		Debug.l(printable_status % [b.system.name,b.system.status,"skip (cannot replace)"])
	return false

func fixIfCan(b,ship,cycle = 0):
	if b.shouldBeFixed(b.system):
		var sim = b.system.duplicate(true)
		var s = simulate_repair(sim,cycle + 1)
		var stat = b.system.status
		var status = simulate_status(s)
		if stat < status:
			stat = status
		Tool.remove(s)
		Tool.remove(sim)
		Debug.l(printable_status % [b.system.name,stat,"fix"])
		queued_repairs.append([b,"fix"])
#		b.doFixSystem()
#		yield(b,"fixed")
#		handleFocuses(ship)
		return true
	else:
		Debug.l(printable_status % [b.system.name,b.system.status,"skip (cannot fix)"])
		return false

func handleFocuses(ship):
	var focused = false
	for b in systemsBox.get_children():
		if b.visible:
			b.fixButton.grab_focus()
			focused = true
			break
	if not focused:
		get_node("Control/Autorepairs/PanelContainer/Buttons/Autorepairs").grab_focus()
	return focused

func handle_operation(b,available_cash,mustTarget,ship,forceMode,targetVal):
	var action_list = appraise_for_cost_efficiency(b,mustTarget,forceMode,targetVal)
	var max_repair = cfg_max_repair
	var max_replace = cfg_max_replace
	
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
			fixIfCan(b,ship,i)
	if replace:
		if replaceCost <= max_replace:
			replaceIfCan(b,ship,affordable_repairs - 1)
	
	
	handleFocuses(ship)
	return false

func isValidForAuto(box) -> bool:
	var mode = cfg_method_priority
	var target = cfg_target
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
		if forcemode == 2:
			action_list = [0,true,replaceCost]
		if mustTarget and not action_list[1]:
			var force_repairs = repairs_needed_to_target(box)
			if force_repairs > action_list[0]:
				Debug.l(force_appraisal_status % [box.system.name,force_repairs,"missing repairs (target of %s not met)" % force_repairs])
				var l = find_most_effective_match(box,action_list.duplicate(true),forcemode,replaceCost,force_repairs)
				action_list = l
	
	return action_list

func find_most_effective_match(box,current_actions,force_mode,replaceCost,target):
	
	if force_mode == 1:
		return current_actions
	if force_mode == 2:
		return [0,true,replaceCost]
	var sys = box.system
	var fix_price = sys.ref.repairFixPrice
	var add_actions = [0,false]
	var replace_value = sys.ref.repairReplacementPrice
	var finished = false
	var operations = 0
	for f in range(target - current_actions[0]):
		if finished:
			continue
		var rprice = getSystemPrice(simulate_repair(sys,current_actions[0] + f),true)
		var replace_cost_after_repair = replace_value - rprice
		var cost_of_all_fixes = (fix_price * (target - operations))
		if cost_of_all_fixes < replace_cost_after_repair:
			add_actions[0] += 1
			Debug.l(force_appraisal_decision % [box.system.name,"repair", "fix price of %s [%s x%s] cheaper than replace price of %s" % [cost_of_all_fixes,fix_price,target,replace_cost_after_repair]])
		else:
			add_actions[1] = true
			Debug.l(force_appraisal_decision % [box.system.name,"replace", "replace price of %s cheaper than fix price of %s [%s x%s]" % [replace_cost_after_repair,cost_of_all_fixes,fix_price,target - operations]])
			finished = true
		operations += 1
	current_actions[0] += add_actions[0]
	current_actions[1] = add_actions[1]
	return current_actions

func repairs_needed_to_target(box):
	var repairs = 0
	
	var maxRepairs = CurrentGame.getRepairLimit(true)
	var base_system = box.system
	var status = base_system.status
	var target = cfg_target
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
	opts.merge({0:{"repair":current,"replace":current - replaceCost,"replace_cost":replaceCost,"repair_cost":0,"status":init_status}})
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
		
		opts.merge({c:{"repair":repair_gain,"replace":replace_gain,"replace_cost":replace_cost,"repair_cost":previous_cost,"status":sim_status}})
		
	
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
