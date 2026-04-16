extends "res://hud/Escape Veloity.gd"

var noSpeedLimit = false

var pointersVP

func vp_escape_UV():
	if pointersVP:
		noSpeedLimit = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_RING","remove_max_speed_limit")

func _init():
	if CurrentGame != null:
		pointersVP = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
		pointersVP.ConfigDriver.__establish_connection("vp_escape_UV",self)
		vp_escape_UV()
		if noSpeedLimit:
			warnVelocity = 1.79769e308
