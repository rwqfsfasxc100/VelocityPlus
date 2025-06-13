extends "res://Settings.gd"

var VelocityPlus = {
	"enceladus":{
		"mineral_market_show_total_value":true,
		"add_empty_cradle_equipment":true,
		"simulator_shader":1,
	}, 
	"crew_portraits":{
		"hide_on_enceladus":false,
		"hide_in_OMS":false,
	},
	"ships":{
		"fix_voyager_MPU_in_OCP":true,
	},
	"in_ring":{
		"remove_max_speed_limit":true,
		"allow_exit_of_ring_to_the_left":true,
		"allow_exit_of_ring_to_the_right":true,
		"broadcast_variations":true
	},
	"input":{
		"toggle_hud":[ "F6" ],
	}, 
}

var VelocityPlus_ConfigPath = "user://cfg/VelocityPlus.cfg"
var VelocityPlus_CfgFile = ConfigFile.new()

func _ready():
	var dir = Directory.new()
	dir.make_dir("user://cfg")
	load_VelocityPlus_FromFile()
	save_VelocityPlus_ToFile()


func save_VelocityPlus_ToFile():
	for section in VelocityPlus:
		for key in VelocityPlus[section]:
			VelocityPlus_CfgFile.set_value(section, key, VelocityPlus[section][key])
	VelocityPlus_CfgFile.save(VelocityPlus_ConfigPath)


func load_VelocityPlus_FromFile():
	var error = VelocityPlus_CfgFile.load(VelocityPlus_ConfigPath)
	if error != OK:
		Debug.l("Velocity Plus: Error loading settings %s" % error)
		return 
	for section in VelocityPlus:
		for key in VelocityPlus[section]:
			VelocityPlus[section][key] = VelocityPlus_CfgFile.get_value(section, key, VelocityPlus[section][key])
	loadKeymapsFromConfig()

func loadKeymapsFromConfig():
	for action_name in VelocityPlus.input:
		var addAction = true
		for m in InputMap.get_actions():
			if m == action_name:
				addAction = false
		if addAction:
			InputMap.add_action(action_name)
		for key in VelocityPlus.input[action_name]:
			var event = InputEventKey.new()
			event.scancode = OS.find_scancode_from_string(key)
			InputMap.action_add_event(action_name, event)
	emit_signal("controlSchemeChaged")
