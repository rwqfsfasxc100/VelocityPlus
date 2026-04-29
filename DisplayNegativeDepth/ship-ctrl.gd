extends "res://ships/ship-ctrl.gd"

var pointersVP_show_neg_depth
func _enter_tree():
	pointersVP_show_neg_depth = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP_show_neg_depth.ConfigDriver.__establish_connection("vp_shipmanager_UV",self)
	vp_show_negative_depth_UV()

func vp_show_negative_depth_UV():
	if pointersVP_show_neg_depth:
		show_neg_depth = pointersVP_show_neg_depth.ConfigDriver.__get_value("VelocityPlus","VP_RING","display_negative_depth")

var show_neg_depth = false
func sensorGet(sensor):
	if show_neg_depth and sensor == "diveDepth":
		if show_neg_depth:
			var depth = CurrentGame.globalCoords(global_position).x / 10000 - 1.0
			return depth
	return .sensorGet(sensor)
