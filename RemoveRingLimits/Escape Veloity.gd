extends "res://hud/Escape Veloity.gd"

var noSpeedLimit = false

var pointersVPEscapeWarnVelocityOverride

var baseWarnVelocity = 0
func vp_escape_UV():
	if pointersVPEscapeWarnVelocityOverride:
		noSpeedLimit = pointersVPEscapeWarnVelocityOverride.ConfigDriver.__get_value("VelocityPlus","VP_RING","remove_max_speed_limit")
	if noSpeedLimit:
		warnVelocity = 1.79769e308
	else:
		warnVelocity = baseWarnVelocity

func _init():
	if CurrentGame != null:
		pointersVPEscapeWarnVelocityOverride = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
		pointersVPEscapeWarnVelocityOverride.ConfigDriver.__establish_connection("vp_escape_UV",self)
		baseWarnVelocity = warnVelocity
		vp_escape_UV()
		
