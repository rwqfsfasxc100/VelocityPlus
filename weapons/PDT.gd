extends "res://ships/modules/PDT.gd"

var default_gimbal_limit = 0
var default_fire_mode = true
var default_fire_action = ""

var pointersVPPDT
var wp

func _enter_tree():
	wp = get_node_or_null(weaponPath)
	default_fire_mode = autoFire
	default_gimbal_limit = gimbalLimit
	default_fire_action = wp.command
	pointersVPPDT = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVPPDT.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()

var fixed = false

var do_change_mode = false
var autofire_type = "VP_TURRET_OVERRIDE_NOFIRE"

func updateValues():
	if pointersVPPDT:
		fixed = pointersVPPDT.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","disable_gimballed_and_turreted_weapons")
		do_change_mode = pointersVPPDT.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","override_turret_autofire")
		autofire_type = pointersVPPDT.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","turret_override_mode")
	if do_change_mode:
		match autofire_type:
			"VP_TURRET_OVERRIDE_FIRE":
				autoFire = true
				wp.command = default_fire_action
			"VP_TURRET_OVERRIDE_NOFIRE":
				autoFire = false
				wp.command = "w"
			_:
				autoFire = default_fire_mode
				wp.command = default_fire_action
	else:
		wp.command = default_fire_action
		autoFire = default_fire_mode


func _physics_process(delta):
	if fixed:
		gimbalLimit = 0
	else:
		gimbalLimit = default_gimbal_limit
