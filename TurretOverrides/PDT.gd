extends "res://ships/modules/PDT.gd"

var default_fire_mode = true
var default_fire_action = ""

var pointersVP_turret_overrides
var wp

func _enter_tree():
	wp = get_node_or_null(weaponPath)
	default_fire_mode = autoFire
	if wp:
		default_fire_action = wp.command
	else:
		yield(get_tree(),"idle_frame")
		wp = get_node_or_null(weaponPath)
		if wp:
			default_fire_action = wp.command
	pointersVP_turret_overrides = ModLoader._savedObjects[0]
	pointersVP_turret_overrides.ConfigDriver.__establish_connection("vp_turretfixer_UV",self)
	vp_turretfixer_UV()

var do_change_mode = false
var autofire_type = "VP_TURRET_OVERRIDE_NOFIRE"

func vp_turretfixer_UV():
	if pointersVP_turret_overrides:
		do_change_mode = pointersVP_turret_overrides.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","override_turret_autofire")
		autofire_type = pointersVP_turret_overrides.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","turret_override_mode")
	if not wp:
		wp = get_node_or_null(weaponPath)
		if wp:
			default_fire_action = wp.command
	if do_change_mode:
		match autofire_type:
			"VP_TURRET_OVERRIDE_FIRE":
				autoFire = true
				if wp:
					wp.command = default_fire_action
			"VP_TURRET_OVERRIDE_NOFIRE":
				autoFire = false
				if wp:
					wp.command = "w"
			_:
				autoFire = default_fire_mode
				if wp:
					wp.command = default_fire_action
	else:
		if wp:
			wp.command = default_fire_action
		autoFire = default_fire_mode
