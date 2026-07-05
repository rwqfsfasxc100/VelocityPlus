extends "res://hud/Leaving Rings.gd"

var goLeft = false
var goRight = false
var noSpeedLimit = false

var pointersVPRingEdgeRemoval

var baseWarnVelocity = 0

func vp_leavingring_UV():
	if pointersVPRingEdgeRemoval:
		speed_limit_config = pointersVPRingEdgeRemoval.ConfigDriver.__get_config("VelocityPlus").get("VP_RING",{})
		noSpeedLimit = speed_limit_config.get("VP_RING",{}).get("remove_max_speed_limit")
	if noSpeedLimit:
		warnVelocity = 1.79769e308
	else:
		warnVelocity = baseWarnVelocity

var speed_limit_config = {}
func _init():
	pointersVPRingEdgeRemoval = ModLoader._savedObjects[0]
	pointersVPRingEdgeRemoval.ConfigDriver.__establish_connection("vp_leavingring_UV",self)
	baseWarnVelocity = warnVelocity
	vp_leavingring_UV()
	visible = true
	
	
	
func _process(delta):
	if not is_visible_in_tree():
		return 
	if Tool.claim(ship):
		var v = CurrentGame.globalCoords(ship.global_position).x
		var leftMost = false
		var rightMost = false
		if v > 3.005e+07 and not speed_limit_config.get("allow_exit_of_ring_to_the_right",true):
			rightMost = true
		if v < 10000 and not speed_limit_config.get("allow_exit_of_ring_to_the_left",true):
			leftMost = true
		
		if leftMost or rightMost:
			text = "HUD_LEAVING_RINGS"
		else:
			text = ""
		
		Tool.release(ship)
