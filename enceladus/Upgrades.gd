extends "res://enceladus/Upgrades.gd"

var _showReliability_system = null

var disable_when_false = PoolStringArray(["damageModel"])
var disable_when_true = PoolStringArray([])

func previewShipSystem(slot,system,control=""):
	.previewShipSystem(slot,system,control)
	if slot == null or system is int or system is float:
		return
	_showReliability_system = system

# Wait until the ship in the simulation is fully instantiated.
func _process(delta):
	if _showReliability_system == null:
		return
	var system = _showReliability_system

	var n = get_tree().root \
		.find_node("UPGRADE_SIMULATION", true, false) \
		.find_node("VP", true, false) \
		.find_node("Viewport", true, false) \
		.find_node("*_" + system, true, false)
	if n == null or n is InstancePlaceholder:
		return
	_showReliability_system = null  # OK, it's instantiated.
	
	var enabled = true
	var txt = ""
	
	for p in n.get_property_list():
		if p.name == "weaponPath":
			var pname = n.get(p.name)
			var path = pname
			var objname = n.name
			var sysname = n.systemName
			var split = str(path).split(sysname)
			if split.size() >= 2:
				path = split[1].lstrip("/")
			n = n.get_node(path)
	
	for p in n.get_property_list():
		if p.name in disable_when_false:
			var check = n.get(p.name)
			if check == false:
				enabled = false
		if p.name in disable_when_true:
			var check = n.get(p.name)
			if check == true:
				enabled = false
		
		if p.name.begins_with("damage") and p.name.ends_with("Capacity"):
			var name = p.name.substr(6, p.name.length() - 8)
			var units = ""
			var factor = 1
			match p.name:
				# I made these up. They're probably wrong.
				"damageWearCapacity":
					name = "MTBF at 100% stress"
					units = "h"
					factor = 1 / 3600.0
				"damageBentCapacity":
					name = "Bend resilience"
					units = "kN"
					factor = 1 / 1000.0
				"damageChokeCapacity":
					name = "Choke resilience"
					units = "kN"
					factor = 1 / 1000.0
				
				# Mass driver and Mike specifics
				"damageFocusCapacity":
					name = "Thermal resilience"
					units = "MJ"
					factor = 1 / 1000.0
				
				# Laser specifics
				"damagePumpDamageCapacity":
					name = "Short-circuit resilience"
					units = "MJ"
					factor = 1 / 1000000.0
				
				

				# These aren't visible in the game right now, because
				# you can't buy / customize computers.
				"damageSensorsCapacity":
					name = "Impact resilience"
					units = "kN"
					factor = 1 / 1000.0
				"damageShortCircuitCapacity":
					name = "Short-circuit resilience"
					units = "MJ"
					factor = 1 / 1000000.0
				"damageOverheatCapacity":
					name = "Thermal resilience"
					units = "MJ"
					factor = 1 / 1000000.0

				# Neither are these (reactor != reactor core).
				"damageRodsCapacity":
					name = "Shock resilience"
					units = "m/s"
				"damageLeakCapacity":
					name = "Impact resilience"
					units = "kN"
					factor = 1 / 1000.0
				"damageTurbineCapacity":
					name = "Thermal resilience"
					units = "MJ"
					factor = 1 / 1000000.0
				
				# Also fusion reactor damage
				"damageCoilsCapacity":
					name = "Acceleration dampening"
					units = "m/s"
				"damageCoolantCapacity":
					name = "Impact resilience"
					units = "kN"
					factor = 1 / 1000.0
				"damageLaserCapacity":
					name = "Thermal resilience"
					units = "MJ"
					factor = 1 / 1000000.0
				
			txt = txt + "\n%s: %s %s" % [name, _showReliability_formatFloat(n.get(p.name) * factor), units]
	if enabled:
		specsLabel.text = TranslationServer.translate(specsLabel.text) + txt
func _showReliability_formatFloat(f):
	# Format without unneeded decimals
	var s = "%f" % f
	while s.find(".") >= 0 and (s.ends_with("0") or s.ends_with(".")):
		s = s.substr(0, s.length() - 1)
	return s
