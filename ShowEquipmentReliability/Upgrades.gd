extends "res://enceladus/Upgrades.gd"

var _showReliability_system = null

var disable_when_false = PoolStringArray(["damageModel"])
var disable_when_true = PoolStringArray([])


var pointersVP


func vp_upgrades_UV():
	if pointersVP:
		cfg_show_equipment_reliability = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_ENCELADUS","show_equipment_reliability")

func _enter_tree():
	pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP.ConfigDriver.__establish_connection("vp_upgrades_UV",self)
	vp_upgrades_UV()

func previewShipSystem(slot,system,control=""):
	.previewShipSystem(slot,system,control)
	if slot == null or system is int or system is float:
		return
	_showReliability_system = system
var mtbf_label
const manual_container_path = NodePath("VB/WindowMargin/TabHintContainer/Window/UPGRADE_MANUAL")
var MTBF_container = load("res://VelocityPlus/ShowEquipmentReliability/MTBF_container.tscn")
func _ready():
	var cont = get_node(manual_container_path)
	var mtbf = MTBF_container.instance()
	cont.add_child(mtbf)
	mtbf_label = mtbf.get_node("VBoxContainer/Label")

# Wait until the ship in the simulation is fully instantiated.
var cfg_show_equipment_reliability
func _process(delta):
	if cfg_show_equipment_reliability:
		if _showReliability_system == null:
			return
		var system = _showReliability_system
		var n = get_node("VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP/Contain1/Viewport").find_node("*_" + system, true, false)
		if n == null or n is InstancePlaceholder:
			return
		_showReliability_system = null  # OK, it's instantiated.
		
		var enabled = true
		var damagePropertyExists = false
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
				damagePropertyExists = true
				var nm = p.name.substr(6, p.name.length() - 8)
				var units = ""
				var factor = 1
				match p.name:
					# I made these up. They're probably wrong.
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
					
				txt = txt + "\n%s: %s %s" % [nm, _showReliability_formatFloat(n.get(p.name) * factor), units]
		if enabled and damagePropertyExists:
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
