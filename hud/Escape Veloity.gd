extends "res://hud/Escape Veloity.gd"

var noSpeedLimit = false

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func _init():
	var config = ConfigDriver.__get_config("VelocityPlus")
	if config.get("VP_RING",{}).get("remove_max_speed_limit",true):
		warnVelocity = 1.79769e308
