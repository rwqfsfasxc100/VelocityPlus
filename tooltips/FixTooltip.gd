extends Button
# Fixes issue no. 5340
# https://git.kodera.pl/games/delta-v/-/issues/5340

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func _physics_process(delta):
	if ConfigDriver.__get_value("VelocityPlus","VP_ENCELADUS","extra_tooltips"):
		if disabled:
			hint_tooltip = "DKB_CANNOT_REPAIR"
		else:
			hint_tooltip = "DKB_REPAIR_EQUIPMENT"
	else:
		hint_tooltip = ""
