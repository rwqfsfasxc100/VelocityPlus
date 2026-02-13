extends "res://enceladus/DoTradeIn.gd"
# Fixes issue no. 5284
# https://git.kodera.pl/games/delta-v/-/issues/5284

var pointersVP

func _enter_tree():
	pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()

func updateValues():
	if pointersVP:
		showVPToolTips = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_ENCELADUS","extra_tooltips")

var showVPToolTips = true

func _process(delta):
	if showVPToolTips:
		if disabled:
			hint_tooltip = "DKB_DEALER_TRADE_IN_MAINT"
		else:
			hint_tooltip = "DKB_DEALER_TRADE_IN_OK"
	else:
		hint_tooltip = ""
