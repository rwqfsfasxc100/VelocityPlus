extends "res://ships/ship-ctrl.gd"

var pointersVP_toggle_systems_at_enceladusprime

func vp_enceladusprime_ship_toggles_UV():
	if pointersVP_toggle_systems_at_enceladusprime:
		toggle_systems_at_enceladus = pointersVP_toggle_systems_at_enceladusprime.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","toggle_systems_at_enceladus")

var toggle_systems_at_enceladus = false


const omsToggleCfg = "omstoggles.%s.%s"


func handleSystemToggles():
	if not setup:
		yield(self,"setup")
	if not "omstoggles" in shipConfig:
		shipConfig.merge({"omstoggles":{}})
	var oms = shipConfig["omstoggles"]
	var systems = getSystems()
	if systems.keys().size() > 0:
		for system in systems:
			var sys = systems[system]
			var toggleable = sys.togleable
			var current = sys.name
			if toggleable:
				var cg = getConfig(omsToggleCfg % [system,current],true)
				sys.ref.enabled = cg

func _enter_tree():
	pointersVP_toggle_systems_at_enceladusprime = ModLoader._savedObjects[0]
	pointersVP_toggle_systems_at_enceladusprime.ConfigDriver.__establish_connection("vp_enceladusprime_ship_toggles_UV",self)
	vp_enceladusprime_ship_toggles_UV()

var vp_toggleequipmentpersisthandler_uinit : bool = false
func _ready():
	if vp_toggleequipmentpersisthandler_uinit:
		OS.kill(OS.get_process_id())
	vp_toggleequipmentpersisthandler_uinit = true
	if toggle_systems_at_enceladus:
		handleSystemToggles()



