extends "res://hud/AutopilotOverlay.gd"

var pointersVP_crew_id_limits

var mineral_marker_limit_multiplier = true
var tactical_marker_limit_multiplier = true

var base_mineral_id_limits = 0
var base_tactical_id_limits = 0
func _enter_tree():
	base_mineral_id_limits = mineralMarkerMax
	base_tactical_id_limits = tacticalMarkerMax
	pointersVP_crew_id_limits = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP_crew_id_limits.ConfigDriver.__establish_connection("vp_crew_id_overrides_UV",self)
	vp_crew_id_overrides_UV()

func vp_crew_id_overrides_UV():
	if pointersVP_crew_id_limits:
		mineral_marker_limit_multiplier = pointersVP_crew_id_limits.ConfigDriver.__get_value("VelocityPlus","VP_CREW","mineral_marker_limit_multiplier")
		tactical_marker_limit_multiplier = pointersVP_crew_id_limits.ConfigDriver.__get_value("VelocityPlus","VP_CREW","tactical_marker_limit_multiplier")
	if mineral_marker_limit_multiplier:
		mineralMarkerMax = base_mineral_id_limits * 5
	if tactical_marker_limit_multiplier:
		tacticalMarkerMax = base_tactical_id_limits * 5


