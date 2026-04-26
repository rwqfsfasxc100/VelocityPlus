extends "res://hud/Leaving Rings.gd"

var noSpeedLimit = false
var goLeft = false
var goRight = false

var pointersVP

func vp_leavingring_UV():
	if pointersVP:
		config = pointersVP.ConfigDriver.__get_config("VelocityPlus").get("VP_RING",{})

var config = {}
func _init():
	if CurrentGame != null:
		pointersVP = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
		pointersVP.ConfigDriver.__establish_connection("vp_leavingring_UV",self)
		vp_leavingring_UV()
		visible = true
		if config.get("remove_max_speed_limit",true):
			warnVelocity = 1.79769e308
	
	
	
func _process(delta):
	if not is_visible_in_tree():
		return 
	if Tool.claim(ship):
		var v = CurrentGame.globalCoords(ship.global_position).x
		var leftMost = false
		var rightMost = false
		if v > 3.005e+07 and config.get("allow_exit_of_ring_to_the_right",true) == false:
			rightMost = true
		if v < 10000 and config.get("allow_exit_of_ring_to_the_left",true) == false:
			leftMost = true
		
		if leftMost or rightMost:
			text = "HUD_LEAVING_RINGS"
		else:
			text = ""
		
		Tool.release(ship)
