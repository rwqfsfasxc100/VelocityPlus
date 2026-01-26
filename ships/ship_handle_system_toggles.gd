extends "res://ships/ship-ctrl.gd"

func _ready():
	handleSystemToggles()

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
