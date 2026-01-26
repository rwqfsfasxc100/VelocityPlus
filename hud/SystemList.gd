extends "res://hud/SystemList.gd"

const ConfigDriverVP = preload("res://HevLib/pointers/ConfigDriver.gd")
var omsToggleCfg = "omstoggles.%s.%s"

func toggle(s, b):
	.toggle(s, b)
	if ConfigDriverVP.__get_value("VelocityPlus","VP_SHIPS","remember_toggled_systems"):
		var vname = s.ref.name
		var sname = s.name
		ship.setConfig(omsToggleCfg % [vname,sname],b.pressed)
