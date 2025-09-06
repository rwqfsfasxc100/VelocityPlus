extends "res://hud/OMS.gd"

var _diveClock: Label
var _diveClockGame

var ship

var MPUs = []

var add_dive_time = false

func _ready():
	if Settings.VelocityPlus["in_ring"]["show_dive_time_in_OMS"]:
		add_dive_time = true
	if add_dive_time:
		Debug.l("DIVE-CLOCK: Readying hud/OMS")
		var container = find_node("CREW_OCCUPATION_MECHANIC", true)
		_diveClock = Label.new()
		_diveClock.modulate = Color("#00ff00")
		container.add_child(_diveClock)
		_diveClockGame = get_tree().root.get_node("Game")
	ship = get_parent().get_parent()
	for child in ship.get_children():
		var scriptobj = child.get_script()
		if scriptobj != null:
			var script = scriptobj.get_path()
			if script == "res://ships/modules/MineralProcessingUnit.gd":
				MPUs.append(child)
	
	


func _input(event):
	if !ship.cutscene and ship.isPlayerControlled():
#		breakpoint
		if event.is_action_pressed("velocityplus_toggle_hud"):
			get_parent().visible = !get_parent().visible
		if event.is_action_pressed("velocityplus_toggle_mpu"):
			var current_mpu = ship.getConfig("cargo.equipment")
			for node in ship.get_children():
				if "systemName" in node:
					var nname = node.name
					if node.systemName == current_mpu:
						node.enabled = !node.enabled

func _physics_process(delta):
	if add_dive_time:
		var now = CurrentGame.getInGameTimestamp()
		var text = CurrentGame.timeToString(now)
		if _diveClockGame != null:
			var timeInDive = int(now - _diveClockGame.diveStartTime)
			text += "\nIn dive: %dh %02dm %02ds" % [
				timeInDive / 3600,
				timeInDive / 60 % 60,
				timeInDive % 60,
			]
		_diveClock.text = text
