extends "res://enceladus/Upgrades.gd"

var _showReliability_system = null

var disable_when_false = PoolStringArray(["damageModel"])
var disable_when_true = PoolStringArray([])


var pointersVP

func _enter_tree():
	pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()

func updateValues():
	if pointersVP:
		cfg_show_equipment_reliability = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_ENCELADUS","show_equipment_reliability")

func previewShipSystem(slot,system,control=""):
	.previewShipSystem(slot,system,control)
	if slot == null or system is int or system is float:
		return
	_showReliability_system = system
var mtbf_label
const manual_container_path = NodePath("VB/WindowMargin/TabHintContainer/Window/UPGRADE_MANUAL")
const MTBF_container = preload("res://VelocityPlus/enceladus/MTBF_container.tscn")
func _ready():
	var cont = get_node(manual_container_path)
	var mtbf = MTBF_container.instance()
	cont.add_child(mtbf)
	mtbf_label = mtbf.get_node("VBoxContainer/Label")
#const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
# Wait until the ship in the simulation is fully instantiated.
var cfg_show_equipment_reliability
func _process(delta):
	if cfg_show_equipment_reliability:
		if _showReliability_system == null:
			return
		var system = _showReliability_system
	#	Removal of inefficient method of getting the system node
	#	var n = get_tree().root \
	#		.find_node("UPGRADE_SIMULATION", true, false) \
	#		.find_node("VP", true, false) \
	#		.find_node("Viewport", true, false) \
	#		.find_node("*_" + system, true, false)
		
		var n = get_node("VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP/Contain1/Viewport").find_node("*_" + system, true, false)
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
			mtbf_label.text = txt
			mtbf_label.visible = true
		else:
			mtbf_label.visible = false
func _showReliability_formatFloat(f):
	# Format without unneeded decimals
	var s = "%f" % f
	while s.find(".") >= 0 and (s.ends_with("0") or s.ends_with(".")):
		s = s.substr(0, s.length() - 1)
	return s
