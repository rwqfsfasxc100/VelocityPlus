extends "res://ships/ship-ctrl.gd"

var pointersVP_disable_pilot_auto_adrenaline
func _enter_tree():
	pointersVP_disable_pilot_auto_adrenaline = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP_disable_pilot_auto_adrenaline.ConfigDriver.__establish_connection("vp_disable_pilot_adrenaline_UV",self)
	vp_disable_pilot_adrenaline_UV()

func vp_disable_pilot_adrenaline_UV():
	if pointersVP_disable_pilot_auto_adrenaline:
		prevent_adrenaline = pointersVP_disable_pilot_auto_adrenaline.ConfigDriver.pointers.ConfigDriver.__get_value("VelocityPlus","VP_CREW","pilots_disable_adrenaline")
	
var prevent_adrenaline = false

func handlePilotAdrenaline(delta):
	if prevent_adrenaline:
		return
	.handlePilotAdrenaline(delta)
