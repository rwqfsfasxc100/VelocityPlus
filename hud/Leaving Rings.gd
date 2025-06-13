extends "res://hud/Leaving Rings.gd"

var noSpeedLimit = false
var goLeft = false
var goRight = false

func _init():
	loadRemoveRingRestrictionsFromFile()
	visible = true
	if noSpeedLimit == true:
		warnVelocity = 1.79769e308
	
	
	
func _process(delta):
	if not is_visible_in_tree():
		return 
	if Tool.claim(ship):
		var v = CurrentGame.globalCoords(ship.global_position).x
		var leftMost = false
		var rightMost = false
		if v > 3.005e+07 and goRight == false:
			rightMost = true
		if v < 10000 and goLeft == false:
			leftMost = true
		
		if leftMost or rightMost:
			text = "HUD_LEAVING_RINGS"
		else:
			text = ""
		
		Tool.release(ship)

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
		if p.begins_with("allow_exit_of_ring_to_the_left="):
			if p.ends_with("true"):
				goLeft = true
			else:
				goLeft = false
		if p.begins_with("allow_exit_of_ring_to_the_right="):
			if p.ends_with("true"):
				goRight = true
			else:
				goRight = false
