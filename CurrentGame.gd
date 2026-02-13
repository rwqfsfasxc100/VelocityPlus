extends "res://CurrentGame.gd"

var pointersVPEMP

func _ready():
	yield(get_tree(),"idle_frame")
	pointersVPEMP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVPEMP.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()

func updateValues():
	if pointersVPEMP:
		show_shipped_cargo_value = pointersVPEMP.ConfigDriver.__get_value("VelocityPlus","VP_RING","show_shipped_cargo_value")
		astrogation_tracking_time_modifier = pointersVPEMP.ConfigDriver.__get_value("VelocityPlus","VP_CREW","astrogation_tracking_time_modifier")

var this_dive_transactions_gain = 0
var this_dive_transactions_spent = 0

var show_shipped_cargo_value = true
var astrogation_tracking_time_modifier = true
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

func deriveStats(stats):
	var s = .deriveStats(stats)
	var multi = astrogation_tracking_time_modifier
	stats.CREW_STATS_ASTROGATOR_TIME = max(12 * 3600, 24 * 3600 * (stats.CREW_OCCUPATION_ASTROGATOR.experience * 30 * 3 * (multi / 90)))
	return s
