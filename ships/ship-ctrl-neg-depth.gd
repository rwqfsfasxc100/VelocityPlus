extends "res://ships/ship-ctrl.gd"

func sensorGet(sensor):
	var ConfigDriver = load("res://HevLib/pointers/ConfigDriver.gd")
	if ConfigDriver.__get_value("VelocityPlus","VP_RING","display_negative_depth"):
		match sensor:
			"diveDepth":
				var depth = CurrentGame.globalCoords(global_position).x / 10000 - 1.0
				return depth
			_:
				return .sensorGet(sensor)
	else:
		return .sensorGet(sensor)
