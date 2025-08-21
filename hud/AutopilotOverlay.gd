extends "res://hud/AutopilotOverlay.gd"

func check_value(val):
	var type = typeof(val)
	if ((type == TYPE_INT || type == TYPE_REAL) && val >= 0):
		return (val as float)
	else:
		return 1.0

func _ready():
	var mineral = Settings.VelocityPlus["crew"]["geologist_mineral_marker_display_limit_multiplier"]
	var tactical = Settings.VelocityPlus["crew"]["astrogator_tactical_marker_display_limit_multiplier"]
	
	mineralMarkerMax *= check_value(mineral)
	tacticalMarkerMax *= check_value(tactical)
