extends "res://hud/Escape Veloity.gd"

var noSpeedLimit = false

func _init():
	loadRemoveRingRestrictionsFromFile()
	if noSpeedLimit == true:
		warnVelocity = 1.79769e308

var RemoveRingRestrictionsPath = "user://cfg/VelocityPlus.cfg"

func loadRemoveRingRestrictionsFromFile():
	var file = File.new()
	file.open(RemoveRingRestrictionsPath, File.READ)
	var txt = file.get_as_text()
	file.close()
	var split = txt.split("\n")
	for line in split:
		var p = str(line)
		if p.begins_with("remove_max_speed_limit="):
			if p.ends_with("true"):
				noSpeedLimit = true
			else:
				noSpeedLimit = false
