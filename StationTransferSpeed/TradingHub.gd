extends "res://story/habitat/TradingHub.gd"

var base_transfer_speed = 0

var transfer_speed_multi = 1.0
var pointersVP_base_transfer_speed
func _enter_tree():
	base_transfer_speed = tradePerSecond
	pointersVP_base_transfer_speed = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP_base_transfer_speed.ConfigDriver.__establish_connection("vp_shipmanager_UV",self)
	vp_station_trade_transfer_speed_UV()

func vp_station_trade_transfer_speed_UV():
	if pointersVP_base_transfer_speed:
		transfer_speed_multi = pointersVP_base_transfer_speed.ConfigDriver.__get_value("VelocityPlus","VP_RING","station_trade_transfer_speed")
	else: transfer_speed_multi = 1.0
	tradePerSecond = base_transfer_speed * transfer_speed_multi
