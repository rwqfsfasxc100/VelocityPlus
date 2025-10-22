extends "res://enceladus/SystemShipRepairUI.gd"

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func updateStatuses():
	.updateStatuses()
	if system.status >= 99.5 and ConfigDriver.__get_value("VelocityPlus","VP_ENCELADUS","hide_unrepairable_equipment"):
		visible = false
	else:
		visible = true
