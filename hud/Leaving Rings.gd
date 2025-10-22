extends "res://hud/Leaving Rings.gd"

var noSpeedLimit = false
var goLeft = false
var goRight = false

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
var config = {}
func _init():
	config = ConfigDriver.__get_config("VelocityPlus")
	visible = true
	if config.get("VP_RING",{}).get("remove_max_speed_limit",true):
		warnVelocity = 1.79769e308
	
	
	
func _process(delta):
	if not is_visible_in_tree():
		return 
	if Tool.claim(ship):
		config = ConfigDriver.__get_config("VelocityPlus")
		var v = CurrentGame.globalCoords(ship.global_position).x
		var leftMost = false
		var rightMost = false
		if v > 3.005e+07 and config.get("VP_RING",{}).get("allow_exit_of_ring_to_the_right",true) == false:
			rightMost = true
		if v < 10000 and config.get("VP_RING",{}).get("allow_exit_of_ring_to_the_left",true) == false:
			leftMost = true
		
		if leftMost or rightMost:
			text = "HUD_LEAVING_RINGS"
		else:
			text = ""
		
		Tool.release(ship)
