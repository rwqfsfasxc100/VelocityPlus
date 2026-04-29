extends "res://CurrentGame.gd"

var pointersVP_shipped_goods_display

func _ready():
	yield(get_tree(),"idle_frame")
	pointersVP_shipped_goods_display = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP_shipped_goods_display.ConfigDriver.__establish_connection("vp_shippedgoods_UV",self)
	vp_shippedgoods_UV()

func vp_shippedgoods_UV():
	if pointersVP_shipped_goods_display:
		show_shipped_cargo_value = pointersVP_shipped_goods_display.ConfigDriver.__get_value("VelocityPlus","VP_RING","show_shipped_cargo_value")

var this_dive_transactions_gain = 0
var this_dive_transactions_spent = 0

var show_shipped_cargo_value = true
func logEvent(type: String, details = {}):
	.logEvent(type,details)
	if show_shipped_cargo_value:
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
