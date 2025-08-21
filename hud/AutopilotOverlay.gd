extends "res://hud/AutopilotOverlay.gd"

func _ready():
	var mineral = Settings.VelocityPlus["crew"]["geologist_mineral_marker_display_limit_multiplier"]
	var tactical = Settings.VelocityPlus["crew"]["astrogator_tactical_marker_display_limit_multiplier"]
	if mineral:
		mineralMarkerMax *= 5.0
	if tactical:
		tacticalMarkerMax *= 5.0
