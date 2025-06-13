extends "res://ships/ship-ctrl.gd"

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
	
	
	if CurrentGame.globalCoords(global_position).x < 0 and Settings.VelocityPlus["in_ring"]["allow_exit_of_ring_to_the_left"] == false:
		return true
	if CurrentGame.globalCoords(global_position).x > 3.006e+07 and Settings.VelocityPlus["in_ring"]["allow_exit_of_ring_to_the_right"] == false:
		return true
	if linear_velocity.length() > 2000 and Settings.VelocityPlus["in_ring"]["remove_max_speed_limit"] == false:
		return true
	
	
	return false
