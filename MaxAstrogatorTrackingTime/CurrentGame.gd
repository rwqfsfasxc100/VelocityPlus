extends "res://CurrentGame.gd"

var pointersVP_astro_tracking_time

var astrogation_tracking_time_modifier = true

func _ready():
	yield(get_tree(),"idle_frame")
	pointersVP_astro_tracking_time = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP_astro_tracking_time.ConfigDriver.__establish_connection("vp_astrogator_tracking_time_UV",self)
	vp_astrogator_tracking_time_UV()

func vp_astrogator_tracking_time_UV():
	if pointersVP_astro_tracking_time:
		astrogation_tracking_time_modifier = pointersVP_astro_tracking_time.ConfigDriver.__get_value("VelocityPlus","VP_CREW","astrogation_tracking_time_modifier")

func deriveStats(stats):
	var s = .deriveStats(stats)
	var multi = astrogation_tracking_time_modifier
	stats.CREW_STATS_ASTROGATOR_TIME = max(12 * 3600, 24 * 3600 * (stats.CREW_OCCUPATION_ASTROGATOR.experience * 30 * 3 * (multi / 90)))
	return s
