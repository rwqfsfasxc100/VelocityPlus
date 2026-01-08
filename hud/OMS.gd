extends "res://hud/OMS.gd"

var _diveClock: Label
var _diveClockGame

var ship

var MPUs = []

var add_dive_time = false

var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func _ready():
	Debug.l("DIVE-CLOCK: Readying hud/OMS")
	var container = find_node("CREW_OCCUPATION_MECHANIC", true)
	_diveClock = Label.new()
	_diveClock.modulate = Color("#00ff00")
	container.add_child(_diveClock)
	_diveClockGame = get_tree().root.get_node_or_null("Game")
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
	if ConfigDriver.__get_value("VelocityPlus","VP_RING","show_dive_time_in_OMS"):
		var text = ""
		if _diveClockGame != null:
			var timeInDive = int(ceil(_diveClockGame.realtimePlayed))
			text += TranslationServer.translate("VP_DIVE_CLOCK_DISPLAY") % [
				timeInDive / 3600,
				timeInDive / 60 % 60,
				timeInDive % 60,
			]
		_diveClock.text = text
		_diveClock.visible = true
	else:
		_diveClock.visible = false
