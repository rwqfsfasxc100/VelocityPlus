extends "res://enceladus/DoTradeIn.gd"
# Fixes issue no. 5284
# https://git.kodera.pl/games/delta-v/-/issues/5284

func _process(delta):
	if disabled:
		hint_tooltip = "DKB_DEALER_TRADE_IN_MAINT"
	else:
		hint_tooltip = "DKB_DEALER_TRADE_IN_OK"
