extends "res://enceladus/DoTradeIn.gd"
# Fixes issue no. 5284
# https://git.kodera.pl/games/delta-v/-/issues/5284

var pointersVP

func _enter_tree():
	pointersVP = ModLoader._savedObjects[0]
	pointersVP.ConfigDriver.__establish_connection("vp_tradetooltip_UV",self)
	vp_tradetooltip_UV()

func vp_tradetooltip_UV():
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
