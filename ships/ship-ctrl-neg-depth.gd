extends "res://ships/ship-ctrl.gd"

func sensorGet(sensor):
	match sensor:
		"diveDepth":
			var depth = CurrentGame.globalCoords(global_position).x / 10000 - 1.0
			return depth
		_:
			return .sensorGet(sensor)
