extends "res://enceladus/Repairs.gd"

var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func createRepairMenuFor(ship):
	.createRepairMenuFor(ship)
	if ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","automatic_repairs"):
		var mode = ConfigDriver.__get_value("VelocityPlus","VP_AUTOREPAIRS","automatic_repairs")
		for i in systemsBox.get_children():
			handle_repair_key(mode,i)


func handle_repair_key(mode,menu):
	match mode:
		"VP_AUTOREPAIR_PRIORITY_COSTEFFECTIVE":
			pass
		"VP_AUTOREPAIR_PRIORITY_ONLYREPAIR":
			pass
		"VP_AUTOREPAIR_PRIORITY_ONLYREPLACE":
			pass
		"VP_AUTOREPAIR_PRIORITY_REPAIRREPLACE":
			pass
		
