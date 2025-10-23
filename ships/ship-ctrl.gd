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

func handleTrajectoryProgress(delta):
	var config = ConfigDriverVP.__get_config("VelocityPlus")
	if config.get("VP_CREW",{}).get("pilots_reduce_astro_calculations",true):
		var education = 0
		var experience = 0
		var crewData = CurrentGame.getCurrentlyActiveCrewNames()
		for crew in crewData:
			var dta = CurrentGame.state.crew[crew]
			if dta.occupation == "CREW_OCCUPATION_PILOT":
				if dta.experience >= experience:
					experience = dta.experience
				if dta.talent >= education:
					education = dta.talent
		
		var minimum = float(config.get("VP_CREW",{}).get("minimum_astrogation_time",3))
		var maximum = float(config.get("VP_CREW",{}).get("maximum_astrogation_time",10))
		var bias = float(config.get("VP_CREW",{}).get("pilot_skill_bias",0.3))
		var exmod = lerp(education,experience,bias)
		var diff = (exmod * maximum)
		var shrink = (maximum - diff)/maximum
		var modifier = lerp(minimum,maximum,shrink)
		trajectoryTime = clamp(modifier,minimum,maximum)
	.handleTrajectoryProgress(delta)

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
