extends "res://ships/ship-ctrl.gd"

var pointersVP_remove_ring_limits
func _enter_tree():
	pointersVP_remove_ring_limits = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP_remove_ring_limits.ConfigDriver.__establish_connection("vp_shipmanager_UV",self)
	vp_remove_ring_limits_UV()

var vpconfig_ring_limits_container = {}
func vp_remove_ring_limits_UV():
	if pointersVP_remove_ring_limits:
		vpconfig_ring_limits_container = pointersVP_remove_ring_limits.ConfigDriver.__get_config("VelocityPlus").get("VP_RING")

func isInEscapeCondition():
	if test:
		return false
	if dead:
		return false
	if escapeCutscene:
		return true
	if cutscene:
		return false
	if not isPlayerControlled():
		return false
	
	
	if CurrentGame.globalCoords(global_position).x < 0 and not vpconfig_ring_limits_container.get("allow_exit_of_ring_to_the_left",true):
		return true
	if CurrentGame.globalCoords(global_position).x > 3.006e+07 and not vpconfig_ring_limits_container.get("allow_exit_of_ring_to_the_right",true):
		return true
	if linear_velocity.length() > 2000 and not vpconfig_ring_limits_container.get("remove_max_speed_limit",true):
		return true
	
	
	return false
