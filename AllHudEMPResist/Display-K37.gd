extends "res://hud/Display-K37.gd"

var alwaysOn_default = false

var pointersVP_always_emp_huds
func _enter_tree():
	alwaysOn_default = alwaysOn
	pointersVP_always_emp_huds = ModLoader._savedObjects[0]
	pointersVP_always_emp_huds.ConfigDriver.__establish_connection("vp_always_emp_huds_UV",self)
	vp_always_emp_huds_UV()

func vp_always_emp_huds_UV():
	if pointersVP_always_emp_huds:
		if pointersVP_always_emp_huds.ConfigDriver.pointers.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","always_emp_resistant_HUD"):
			alwaysOn = true
		else:
			alwaysOn = alwaysOn_default
