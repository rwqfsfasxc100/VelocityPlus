extends "res://CurrentGame.gd"

const VPCFG = preload("res://HevLib/pointers/ConfigDriver.gd")

var this_dive_transactions_gain = 0
var this_dive_transactions_spent = 0

func logEvent(type: String, details = {}):
	.logEvent(type,details)
	if VPCFG.__get_value("VelocityPlus","VP_RING","show_shipped_cargo_value"):
		if type == "LOG_EVENT_DIVE":
			if "LOG_EVENT_DETAILS_TRADE_SELL" in details:
				var data = details["LOG_EVENT_DETAILS_TRADE_SELL"]
				if data != 0.0:
					this_dive_transactions_gain += abs(data)
			if "LOG_EVENT_DETAILS_TRADE_BUY" in details:
				var data = details["LOG_EVENT_DETAILS_TRADE_BUY"]
				if data != 0.0:
					this_dive_transactions_spent += abs(data)
			if "LOG_EVENT_DETAILS_DIALOG_MONEY" in details:
				var data = details["LOG_EVENT_DETAILS_DIALOG_MONEY"]
				if data != 0.0:
					this_dive_transactions_gain += abs(data)
			if "LOG_EVENT_DETAILS_DIALOG_EXPENSES" in details:
				var data = details["LOG_EVENT_DETAILS_DIALOG_EXPENSES"]
				if data != 0.0:
					this_dive_transactions_spent += abs(data)
