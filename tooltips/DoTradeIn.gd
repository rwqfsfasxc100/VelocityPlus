extends "res://enceladus/DoTradeIn.gd"
# Fixes issue no. 5284
# https://git.kodera.pl/games/delta-v/-/issues/5284

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func _process(delta):
	if ConfigDriver.__get_value("VelocityPlus","VP_ENCELADUS","extra_tooltips"):
		if disabled:
			hint_tooltip = "DKB_DEALER_TRADE_IN_MAINT"
		else:
			hint_tooltip = "DKB_DEALER_TRADE_IN_OK"
	else:
		hint_tooltip = ""
