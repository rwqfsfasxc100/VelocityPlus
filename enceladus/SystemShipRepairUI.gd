extends "res://enceladus/SystemShipRepairUI.gd"

func updateStatuses():
	.updateStatuses()
	if system.status >= 99.5:
		visible = false
	else:
		visible = true
