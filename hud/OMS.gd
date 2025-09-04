extends "res://hud/OMS.gd"

var _diveClock: Label
var _diveClockGame

var ship

func _ready():
	Debug.l("DIVE-CLOCK: Readying hud/OMS")
	ship = get_parent().get_parent()
	var container = find_node("CREW_OCCUPATION_MECHANIC", true)
	_diveClock = Label.new()
	_diveClock.modulate = Color("#00ff00")
	container.add_child(_diveClock)

	_diveClockGame = get_tree().root.get_node("Game")


func _input(event):
	if !ship.cutscene and ship.isPlayerControlled():
		if Input.is_action("velocityplus_toggle_hud"):
			get_parent().visible = !get_parent().visible


func _physics_process(delta):
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
