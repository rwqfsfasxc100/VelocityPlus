extends "res://ships/ship-ctrl.gd"
#
#var MPUs = []
#var HUDs = []
#
#func _ready():
#	var children = get_children()
#	for child in children:
#		var scriptobj = child.get_script()
#		if scriptobj != null:
#			var script = scriptobj.get_path()
#			if script == "res://hud/Hud.gd":
#				HUDs.append(child)
#			if script == "res://ships/modules/MineralProcessingUnit.gd":
#				MPUs.append(child)
#	var mname = self.shipName
##	breakpoint
#
#func _process(delta):
#	if !self.cutscene and self.isPlayerControlled():
#		if Input.is_action_pressed("velocityplus_toggle_mpu"):
#			for mpu in MPUs:
#				mpu.enabled = not mpu.enabled
#		if Input.is_action_just_pressed("velocityplus_toggle_hud"):
#			for hud in HUDs:
#				hud.visible = !hud.visible
#var key_actions = []
#
#var action_dict = {}

#func _ready():
#	set_process_input(true)
#	key_actions = InputMap.get_actions()
#	for action in key_actions:
#		action_dict.merge({action:false})

#func _input(event):
#	breakpoint

const ConfigDriverVP = preload("res://HevLib/pointers/ConfigDriver.gd")

func sensorGet(sensor):
	
	if ConfigDriverVP.__get_value("VelocityPlus","VP_RING","display_negative_depth"):
		match sensor:
			"diveDepth":
				var depth = CurrentGame.globalCoords(global_position).x / 10000 - 1.0
				return depth
			_:
				return .sensorGet(sensor)
	else:
		return .sensorGet(sensor)

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
	
	
	if CurrentGame.globalCoords(global_position).x < 0 and ConfigDriverVP.__get_value("VelocityPlus","VP_RING","allow_exit_of_ring_to_the_left") == false:
		return true
	if CurrentGame.globalCoords(global_position).x > 3.006e+07 and ConfigDriverVP.__get_value("VelocityPlus","VP_RING","allow_exit_of_ring_to_the_right") == false:
		return true
	if linear_velocity.length() > 2000 and ConfigDriverVP.__get_value("VelocityPlus","VP_RING","remove_max_speed_limit") == false:
		return true
	
	
	return false
