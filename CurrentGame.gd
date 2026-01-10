extends "res://CurrentGame.gd"

const VPCFG = preload("res://HevLib/pointers/ConfigDriver.gd")

var sold_goods_on_this_dive = 0

func logEvent(type: String, details = {}):
	.logEvent(type,details)
	if VPCFG.__get_value("VelocityPlus","VP_RING","show_shipped_cargo_value"):
		if type == "LOG_EVENT_DIVE":
			if "LOG_EVENT_DETAILS_TRADE_SELL" in details:
				var data = details["LOG_EVENT_DETAILS_TRADE_SELL"]
				if data > 0:
					sold_goods_on_this_dive += data
