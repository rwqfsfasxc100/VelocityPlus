extends "res://enceladus/SystemShipRepairUI.gd"

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

var allow_hide = true

func updateStatuses():
	.updateStatuses()
	if ConfigDriver.__get_value("VelocityPlus","VP_ENCELADUS","hide_unrepairable_equipment") and allow_hide:
		if system.status >= 99.5:
			visible = false
		else:
			visible = true
	
