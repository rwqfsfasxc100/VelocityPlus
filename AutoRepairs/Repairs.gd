# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends "res://enceladus/Repairs.gd"

enum{
	VP_AUTOREPAIR_PRIORITY_COSTEFFECTIVE,
	VP_AUTOREPAIR_PRIORITY_ONLYREPAIR,
	VP_AUTOREPAIR_PRIORITY_ONLYREPLACE,
	VP_AUTOREPAIR_PRIORITY_MAXPROFIT,
}

func _enter_tree():
	var pointersVP:HevLibPointers = ModLoader._savedObjects[0]
	pointersVP.ConfigDriver.__subscribe_to_setting_change("vp_update_do_auto",self,"VelocityPlus","VP_AUTOREPAIRS","automatic_repairs")
	pointersVP.ConfigDriver.__subscribe_to_setting_change("vp_update_method_priority",self,"VelocityPlus","VP_AUTOREPAIRS","repair_method_priority")
	pointersVP.ConfigDriver.__subscribe_to_setting_change("vp_update_max_repair",self,"VelocityPlus","VP_AUTOREPAIRS","maximum_repair")
	pointersVP.ConfigDriver.__subscribe_to_setting_change("vp_update_max_replace",self,"VelocityPlus","VP_AUTOREPAIRS","maximum_replace")
	pointersVP.ConfigDriver.__subscribe_to_setting_change("vp_update_min_cash",self,"VelocityPlus","VP_AUTOREPAIRS","minimum_money")
	pointersVP.ConfigDriver.__subscribe_to_setting_change("vp_update_min_insurance",self,"VelocityPlus","VP_AUTOREPAIRS","minimum_insurance")
	pointersVP.ConfigDriver.__subscribe_to_setting_change("vp_update_target",self,"VelocityPlus","VP_AUTOREPAIRS","target_percent")
	cfg_do_automatic_repairs = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","automatic_repairs",false)
	cfg_method_priority = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","repair_method_priority",VP_AUTOREPAIR_PRIORITY_COSTEFFECTIVE)
	cfg_max_repair = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","maximum_repair",250000)
	cfg_max_replace = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","maximum_replace",2500000)
	cfg_min_cash = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","minimum_money",100000)
	cfg_min_insurance = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","minimum_insurance",0)
	cfg_target = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","target_percent",70)

var vp_repairsautorepairmenu_uinit : bool = false
func _ready():
	if vp_repairsautorepairmenu_uinit:
		OS.kill(OS.get_process_id())
	vp_repairsautorepairmenu_uinit = true
	add_child(load("res://VelocityPlus/AutoRepairs/AutoRepairPanel.tscn").instance())
	set_physics_process(false)

func vp_update_do_auto(how:bool):
	cfg_do_automatic_repairs = how

func vp_update_method_priority(how:int):
	cfg_method_priority = how

func vp_update_max_repair(how:int):
	cfg_max_repair = how

func vp_update_max_replace(how:int):
	cfg_max_replace = how

func vp_update_min_cash(how:int):
	cfg_min_cash = how

func vp_update_min_insurance(how:int):
	cfg_min_insurance = how

func vp_update_target(how:int):
	cfg_target = how

var cfg_do_automatic_repairs:bool = false
var cfg_method_priority:int = VP_AUTOREPAIR_PRIORITY_COSTEFFECTIVE
var cfg_max_repair:int = 250000
var cfg_max_replace:int = 2500000
var cfg_min_cash:int = 100000
var cfg_min_insurance:int = 0
var cfg_target:int = 70

const printable_status = "VelocityPlus AutoRepair Operation status: [system: %s; status: %s; operation: %s]"
const appraisal_status = "VelocityPlus AutoRepair Appraisal status: [system: %s; mode: %s; operation: %s]"
const force_appraisal_status = "VelocityPlus AutoRepair Appraisal status: [system: %s; repairs missing: %s; decision: %s]"
const force_appraisal_decision = "VelocityPlus AutoRepair Appraisal status: [system: %s; operation: %s; decision: %s]"
const multiappraisal_status = "VelocityPlus AutoRepair Appraisal status: [system: %s; repairs: %s; replace: %s; decision: %s]"

var queued_repairs:Array = []

var yield_frame:bool = true
func _physics_process(delta:float):
	if queued_repairs.size() > 0:
		if not visible or $Shower.is_playing():
			return
		if yield_frame:
			yield_frame = false
		else:
			var pq:Array = queued_repairs.pop_front()
			if Tool.ov(pq[0]):
				match pq[1]:
					"fix":
						pq[0].doFixSystem()
					"replace":
						pq[0].doReplaceSystem()
			yield_frame = true
	else:
		set_physics_process(false)

func match_mode_to_string(item_mode:int):
	if item_mode == VP_AUTOREPAIR_PRIORITY_ONLYREPAIR:
		return "VP_AUTOREPAIR_PRIORITY_ONLYREPAIR"
	elif item_mode == VP_AUTOREPAIR_PRIORITY_ONLYREPLACE:
		return "VP_AUTOREPAIR_PRIORITY_ONLYREPLACE"
	elif item_mode == VP_AUTOREPAIR_PRIORITY_MAXPROFIT:
		return "VP_AUTOREPAIR_PRIORITY_MAXPROFIT"
	else:
		return "VP_AUTOREPAIR_PRIORITY_COSTEFFECTIVE"

func createRepairMenuFor(ship):
	.createRepairMenuFor(ship)
	if cfg_do_automatic_repairs and handleFocuses(ship):
		var validSystems:Array = []
		Debug.l("VelocityPlus AutoRepair: Attempting repairs on ship %s %s [%s], using repair mode [%s]" % [ship.getTransponder(),ship.getShipName(),TranslationServer.translate(ship.shipName),TranslationServer.translate(match_mode_to_string(cfg_method_priority))])
		for b in systemsBox.get_children():
			if b.visible and isValidForAuto(b):
				validSystems.append(b)
		
		for b in validSystems:
			var shouldOnlyMode:int = 0
			var mustTarget:bool = false
			if cfg_method_priority == VP_AUTOREPAIR_PRIORITY_ONLYREPAIR:
				mustTarget = true
				shouldOnlyMode = 1
			elif cfg_method_priority == VP_AUTOREPAIR_PRIORITY_ONLYREPLACE:
				shouldOnlyMode = 2
			elif cfg_method_priority == VP_AUTOREPAIR_PRIORITY_MAXPROFIT:
				cfg_target = 100
			else:
				mustTarget = true
			
			var currentCash:float = CurrentGame.getMoney()
			var currentInsurance:float = CurrentGame.getInsurance()
			var can_afford = true
			if cfg_min_insurance > 0:
				if currentInsurance < cfg_min_insurance:
					can_afford = false
			else:
				if (currentCash + currentInsurance) < cfg_min_cash:
					can_afford = false
			
			if can_afford:
				handle_operation(b,(currentInsurance - cfg_min_insurance) if cfg_min_insurance > 0 else ((currentCash + currentInsurance) - cfg_min_cash),mustTarget,ship,shouldOnlyMode,cfg_target)
		if queued_repairs:
			set_physics_process(true)
	handleFocuses(ship)

func replaceIfCan(b,ship,cycle:int = 0):
	if b.isReplaceable(b.system):
		var s:Dictionary = simulate_repair(b.system,cycle + 1)
		var stat:float = b.system.status
		var status:float = simulate_status(s)
		if stat < status:
			stat = status
		Debug.l(printable_status % [b.system.name,stat,"replace"])
		queued_repairs.append([b,"replace"])
	else:
		Debug.l(printable_status % [b.system.name,b.system.status,"skip (cannot replace)"])
	return false

func fixIfCan(b,ship,cycle = 0):
	if Tool.ov(b):
		if b.shouldBeFixed(b.system):
			var s:Dictionary = simulate_repair(b.system,cycle + 1)
			var stat:float = b.system.status
			var status:float = simulate_status(s)
			if stat < status:
				stat = status
			Debug.l(printable_status % [b.system.name,stat,"fix"])
			queued_repairs.append([b,"fix"])
			return true
		else:
			Debug.l(printable_status % [b.system.name,b.system.status,"skip (cannot fix)"])
			return false

func handleFocuses(ship):
	var focused:bool = false
	for b in systemsBox.get_children():
		if b.visible:
			b.fixButton.grab_focus()
			focused = true
			break
	if not focused:
		get_node("Control/Autorepairs/PanelContainer/Buttons/Autorepairs").grab_focus()
	return focused

func handle_operation(b,available_cash,mustTarget,ship,forceMode,targetVal,max_repair = cfg_max_repair,max_replace = cfg_max_replace):
	var sys:Dictionary = b.system
	var current:float = getSystemPrice(simulate_repair(sys,0),true)
	var replace_value:float = float(b.system.ref.repairReplacementPrice)
	var repairs:int = 0
	var replace:bool = false
	var replaceCost:float = (replace_value - current)
	if b.shouldBeFixed(sys):
		if forceMode == 0:
			var action_list:Array = cost_effective_action_list(b,b.appriseRequiredRepairSteps(),targetVal)
			repairs = action_list[0]
			replace = action_list[1]
			replaceCost = action_list[2]
		elif forceMode == 2:
			repairs = 0
			replace = true
			replaceCost = replaceCost
		if mustTarget and not replace:
			var force_repairs:int = repairs_needed_to_target(b, targetVal)
			if force_repairs > repairs:
				Debug.l(force_appraisal_status % [b.system.name,force_repairs,"missing repairs (target of %s not met)" % force_repairs])
				var action_list:Array = find_most_effective_match(b,[repairs,replace,replaceCost],forceMode,replaceCost,force_repairs)
				repairs = action_list[0]
				replace = action_list[1]
				replaceCost = action_list[2]
	elif b.isReplaceable(sys):
		if forceMode == 2:
			repairs = 0
			replace = true
			replaceCost = replaceCost
		if mustTarget and not replace:
			replace = true
	
	var fixPrice:float = b.fixPrice(b.system)
	var affordable_repairs:int = 0
	var current_cost:float = 0
	
	for i in repairs:
		if available_cash >= fixPrice:
			current_cost += fixPrice
			available_cash -= fixPrice
			affordable_repairs += 1
		else:
			replace = false
			replaceCost = 0
	if replace:
		if available_cash < replaceCost:
			replace = false
			replaceCost = 0
	
	for i in affordable_repairs:
		if fixPrice <= max_repair:
			fixIfCan(b,ship,i)
	if replace and replaceCost <= max_replace:
		replaceIfCan(b,ship,affordable_repairs - 1)
	
	handleFocuses(ship)
	return false

func isValidForAuto(box) -> bool:
	var ref = box.system.ref
	if not "repairReplacementPrice" in ref:
		return false
	if not "repairFixPrice" in ref:
		return false
	var stat:float = box.system.status
	if stat >= 99.5:
		return false
	if (cfg_method_priority == VP_AUTOREPAIR_PRIORITY_COSTEFFECTIVE or cfg_method_priority == VP_AUTOREPAIR_PRIORITY_ONLYREPAIR) and stat >= cfg_target:
		return false
	return true



func find_most_effective_match(box,current_actions:Array,force_mode:int,replaceCost,target):
	if force_mode == 1:
		current_actions[0] = target
		return current_actions
	if force_mode == 2:
		return [0,true,replaceCost]
	var sys:Dictionary = box.system
	var fix_price:float = float(sys.ref.repairFixPrice)
	var add_fixes:int = 0
	var do_replace:bool = false
	var replace_value:float = float(sys.ref.repairReplacementPrice)
	var finished:bool = false
	var operations:int = 0
	for f in (target - current_actions[0]):
		if finished:
			continue
		var replace_cost_after_repair:float = replace_value - getSystemPrice(simulate_repair(sys,current_actions[0] + f),true)
		var cost_of_all_fixes:float = (fix_price * (target - operations))
		if cost_of_all_fixes < replace_cost_after_repair:
			add_fixes += 1
			Debug.l(force_appraisal_decision % [box.system.name,"repair", "fix price of %s [%s x%s] cheaper than replace price of %s" % [cost_of_all_fixes,fix_price,target,replace_cost_after_repair]])
		else:
			do_replace = true
			Debug.l(force_appraisal_decision % [box.system.name,"replace", "replace price of %s cheaper than fix price of %s [%s x%s]" % [replace_cost_after_repair,cost_of_all_fixes,fix_price,target - operations]])
			finished = true
		operations += 1
	current_actions[0] += add_fixes
	current_actions[1] = do_replace
	return current_actions

func repairs_needed_to_target(box, target_override:int = 0):
	var repairs:int = 0
	
	var base_system:Dictionary = box.system
	var status:float = base_system.status
	var target:int = target_override if target_override else cfg_target
	var r:int = 1
	var system:Dictionary = simulate_repair(base_system,r)
	while status < target and status < CurrentGame.getRepairLimit(true) and r < 8:
		status = simulate_status(system)
		repairs += 1
		r += 1
		system = simulate_repair(base_system,r)
	return repairs

func cost_effective_action_list(box,cycles:int,targetVal:int):
	var opts:Dictionary = {}
	
	var system:Dictionary = box.system
	var ref = system.ref
	var fix_price:float = float(ref.repairFixPrice)
	var rx:Dictionary = simulate_repair(system,0)
	var init_status:float = simulate_status(rx)
	var current:float = getSystemPrice(rx,true)
	
	var replace_value:float = float(ref.repairReplacementPrice)
	var replaceCost:float = (replace_value - current)
	opts.merge({0:{"repair":current,"replace":current - replaceCost,"replace_cost":replaceCost,"repair_cost":0,"status":init_status}})
	for specific_cycle in cycles:
		var previous_cost:float = (specific_cycle * fix_price) + fix_price
		var c:int = specific_cycle + 1
		if simulate_repair(system,specific_cycle).status >= targetVal:
			break
		var rv:Dictionary = simulate_repair(system,c)
		var sim_status:float = simulate_status(rv)
		var repair:float = getSystemPrice(rv,true)
		
		var repair_gain:float = repair - previous_cost
		
		var replace_cost:float = replace_value - repair_gain
		var replace_gain:float = repair_gain - (replace_cost + previous_cost)
		
		opts.merge({c:{"repair":repair_gain,"replace":replace_gain,"replace_cost":replace_cost,"repair_cost":previous_cost,"status":sim_status}})
		
	
	var best_value:float = 0
	
	var repairs_to_perform:int = 0
	var do_replace:bool = false
	
	var replace_cost:float = 0
	
	for opt in opts.keys():
		var d:Dictionary = opts[opt]
		var rv:float = d["repair"]
		var rp:float = d["replace"]
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
	var damage:Array = system["damage"]
	return clamp(100 - max(max(damage[0]["current"] / damage[0]["max"], damage[1]["current"] / damage[1]["max"]), damage[2]["current"] / damage[2]["max"]) * 100, 0, 100)

func getSystemPrice(system,adjust = true):
	var pf:float = pow(system.status / 100, 2)
	var o = system.ref
	if o != null and "repairReplacementPrice" in o:
		if adjust and pf < 1:
			pf *= 0.8
		return o.repairReplacementPrice * pf
	return 0.0

func simulate_repair(system:Dictionary,specific_cycle:int):
	if specific_cycle == 0:
		return system
	var after_repair:Dictionary = system.duplicate(true)
	after_repair.damage.clear()
	for d in system.damage:
		var newdmg:Dictionary = d.duplicate(true)
		for i in specific_cycle:
			newdmg.current *= 0.5
		after_repair.damage.append(newdmg)
	var current:int = 0
	var damage:PoolRealArray = PoolRealArray([0.0,0.0,0.0])
	for d in after_repair.damage:
		damage[current] = (d.current / d.max)
		current += 1
	if damage[0] > 0.0 and damage[1] > 0.0 and damage[2] > 0.0:
		after_repair.status = clamp(100 - max(max(damage[0], damage[1]), damage[2]) * 100, 0, 100)
	return after_repair

func manual_cost_effective_repair():
	manual_opt(0)

func manual_fix_repair():
	manual_opt(1)

func manual_replace_repair():
	manual_opt(2)
	
func manual_max_profit():
	manual_opt(6)

func manual_current():
	manual_opt(-1)

func manual_ce():
	manual_opt(3)

func manual_f():
	manual_opt(4)

func manual_r():
	manual_opt(5)

func manual_opt(how : int):
	var validSystems:Array = []
	var max_repair:int = cfg_max_repair
	var max_replace:int = cfg_max_replace
	var min_cash:int = cfg_min_cash
	var min_insurance:int = cfg_min_insurance
	var mustTarget:bool = true
	var target:int = 100
	match how:
		-1:
			if cfg_method_priority == VP_AUTOREPAIR_PRIORITY_ONLYREPAIR:
				how = 1
				target = cfg_target
			elif cfg_method_priority == VP_AUTOREPAIR_PRIORITY_ONLYREPLACE:
				how = 2
				mustTarget = false
				target = cfg_target
			elif cfg_method_priority == VP_AUTOREPAIR_PRIORITY_MAXPROFIT:
				mustTarget = false
			else:
				how = 0
				target = cfg_target
		0:
			max_repair = 10000000
			max_replace = 10000000
			min_cash = 0
			min_insurance = 0
		1:
			max_repair = 10000000
			max_replace = 10000000
			min_cash = 0
			min_insurance = 0
		2:
			max_repair = 10000000
			max_replace = 10000000
			min_cash = 0
			min_insurance = 0
		3,4,5:
			target = cfg_target
			how -= 3
		6:
			how = 0
			max_repair = 10000000
			max_replace = 10000000
			min_cash = 0
			min_insurance = 0
			mustTarget = false
	for b in systemsBox.get_children():
		if b.visible and manual_check(b):
			validSystems.append(b)
	
	
	for b in validSystems:
		var currentCash:float = CurrentGame.getMoney()
		var currentInsurance:float = CurrentGame.getInsurance()
		
		var can_afford:bool = true
		
		if min_insurance > 0:
			if currentInsurance < min_insurance:
				can_afford = false
		else:
			if currentCash + currentInsurance < min_cash:
				can_afford = false
		if can_afford:
			handle_operation(b,(currentInsurance - min_insurance) if min_insurance > 0.0 else ((currentCash + currentInsurance) - min_cash),mustTarget,CurrentGame.getPlayerShip(),how,target)
	if queued_repairs:
		set_physics_process(true)

func manual_check(box):
	if not "repairReplacementPrice" in box.system.ref:
		return false
	if not "repairFixPrice" in box.system.ref:
		return false
	if box.system.status >= 99.5:
		return false
	return true
