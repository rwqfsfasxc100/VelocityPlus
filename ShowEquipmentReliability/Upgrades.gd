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

extends "res://enceladus/Upgrades.gd"

var disable_when_false:PoolStringArray = PoolStringArray(["damageModel"])
var disable_when_true:PoolStringArray = PoolStringArray()

func vp_upgrades_UV(how:bool):
	cfg_show_equipment_reliability = how

func _enter_tree():
	var pointersVP:HevLibPointers._ConfigDriver = ModLoader._savedObjects[0].ConfigDriver
	pointersVP.__subscribe_to_setting_change("vp_upgrades_UV",self,"VelocityPlus","VP_ENCELADUS","show_equipment_reliability")
	cfg_show_equipment_reliability = pointersVP.__get_value("VelocityPlus","VP_ENCELADUS","show_equipment_reliability",true)

var grace_item
func preview(test, slot, system, item):
	.preview(test, slot, system, item)
	grace_item = item

func previewShipSystem(slot,system,control=""):
	.previewShipSystem(slot,system,control)
	if slot == null or system is int or system is float:
		mtbf_label.visible = false
		return
	yield(get_tree().create_timer(0.25),"timeout")
	showReliabilityDisplay()
var mtbf_label
const manual_container_path = NodePath("VB/WindowMargin/TabHintContainer/Window/UPGRADE_MANUAL")
var MTBF_container:PackedScene = load("res://VelocityPlus/ShowEquipmentReliability/MTBF_container.tscn")
var vp_showequipmentreliabilityhandler_uinit : bool = false
func _ready():
	if vp_showequipmentreliabilityhandler_uinit:
		OS.kill(OS.get_process_id())
	vp_showequipmentreliabilityhandler_uinit = true
	var mtbf:Node = MTBF_container.instance()
	get_node(manual_container_path).add_child(mtbf)
	mtbf_label = mtbf.get_node("VBoxContainer/Label")

var cfg_show_equipment_reliability:bool = true
func showReliabilityDisplay():
	if cfg_show_equipment_reliability:
		if grace_item == null:
			mtbf_label.visible = false
			return
		var itemContainer:Node = grace_item
		var system:String = itemContainer.system
		var vp:Viewport = $VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP/Contain1/Viewport
		var n:Node = vp.find_node("*_" + itemContainer.system, true, false)
		if n == null and "nameOverride" in itemContainer and itemContainer.nameOverride != "":
			n = vp.find_node("*_" + itemContainer.nameOverride, true, false)
		if n == null or n is InstancePlaceholder:
			mtbf_label.visible = false
			return
		grace_item = null
		
		
		var enabled:bool = true
		var damagePropertyExists:bool = false
		var txt:String = ""
		
		if "weaponPath" in n:
			var path:String = n.get("weaponPath")
			var objname:String = n.name
			var sysname:String = n.systemName
			var split:PoolStringArray = path.split(sysname)
			if split.size() > 1:
				path = split[1].trim_prefix("/")
			n = n.get_node(path)
		
		for p in n.get_property_list():
			var propertyName:String = p.name
			if enabled:
				if propertyName in disable_when_false:
					if n.get(propertyName) == false:
						enabled = false
			if enabled:
				if propertyName in disable_when_true:
					if n.get(propertyName) == true:
						enabled = false
			if enabled:
				if propertyName.begins_with("damage") and propertyName.ends_with("Capacity"):
					damagePropertyExists = true
					var nm:String = propertyName.substr(6, propertyName.length() - 8)
					var units:String = ""
					var factor:float = 1
					match propertyName:
						"damageWearCapacity":
							nm = "MTBF at 100% stress"
							units = "h"
							factor = 1 / 3600.0
						"damageBentCapacity":
							nm = "Bend resilience"
							units = "kN"
							factor = 1 / 1000.0
						"damageChokeCapacity":
							nm = "Choke resilience"
							units = "kN"
							factor = 1 / 1000.0
						
						# Mass driver and Mike specifics
						"damageFocusCapacity":
							nm = "Thermal resilience"
							units = "MJ"
							factor = 1 / 1000.0
						
						# Laser specifics
						"damagePumpDamageCapacity":
							nm = "Short-circuit resilience"
							units = "MJ"
							factor = 1 / 1000000.0
						
						# These aren't visible in the game right now, because
						# you can't buy / customize computers.
						"damageSensorsCapacity":
							nm = "Impact resilience"
							units = "kN"
							factor = 1 / 1000.0
						"damageShortCircuitCapacity":
							nm = "Short-circuit resilience"
							units = "MJ"
							factor = 1 / 1000000.0
						"damageOverheatCapacity":
							nm = "Thermal resilience"
							units = "MJ"
							factor = 1 / 1000000.0

						# Neither are these (reactor != reactor core).
						"damageRodsCapacity":
							nm = "Shock resilience"
							units = "m/s"
						"damageLeakCapacity":
							nm = "Impact resilience"
							units = "kN"
							factor = 1 / 1000.0
						"damageTurbineCapacity":
							nm = "Thermal resilience"
							units = "MJ"
							factor = 1 / 1000000.0
						
						# Also fusion reactor damage
						"damageCoilsCapacity":
							nm = "Acceleration dampening"
							units = "m/s"
						"damageCoolantCapacity":
							nm = "Impact resilience"
							units = "kN"
							factor = 1 / 1000.0
						"damageLaserCapacity":
							nm = "Thermal resilience"
							units = "MJ"
							factor = 1 / 1000000.0
						
					txt += "\n%s: %s %s" % [nm, formatFloat(n.get(propertyName) * factor), units]
		if enabled and damagePropertyExists:
			mtbf_label.text = txt
			mtbf_label.visible = true
		else:
			mtbf_label.visible = false
func formatFloat(f):
	# Format without unneeded decimals
	var s:String = "%f" % f
	while "." in s and (s.ends_with("0") or s.ends_with(".")):
		s = s.substr(0, s.length() - 1)
	return s
