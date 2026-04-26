extends "res://achievement/AchivementAbstract.gd"

var enable_achievements = false
var enable_leaderboards = false
var cheetah = false

var pointers

func _ready():
	yield(get_tree(),"idle_frame")
	pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointers.ConfigDriver.__establish_connection("vp_achievements_UV",self)
	vp_achievements_UV()
	cheetah = CurrentGame.cheetah

func vp_achievements_UV():
	if pointers:
		config = pointers.ConfigDriver.__get_config("VelocityPlus").get("VP_ENCELADUS",{})
		enable_achievements = config.get("enable_achievements",true)
		enable_leaderboards = config.get("enable_leaderboards",true)
		if config.get("enable_achievements_on_cheated_saves",false):
			cheetah = false
	
#const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
var config = {}

func validateStatAchievements():
	CurrentGame.checkGameState()
	if enable_achievements and not cheetah:
		for k in achivements:
			if k.begins_with("stat:"):
				var stat = k.trim_prefix("stat:")
				var v = achivements[k]
				Debug.l("Validating stat %s to %s" % [stat, v])
				emit_signal("stat", stat, v)

func setStat(stat:String, to)->void :
	CurrentGame.checkGameState()
	if enable_achievements and not cheetah:
		var skey = "stat:%s" % stat
		var pv = achivements.get(skey, 0)
		if to > pv:
			emit_signal("stat", stat, to)
			achivements[skey] = to
			Debug.l("Game stat %s raised to %s" % [skey, to])
			saveToFile()
		

func achive(what)->void :
	if not (what in achievementRarity):
		Debug.l("Illegal achivement %s" % what)
		return 
	CurrentGame.checkGameState()
	if enable_achievements and not cheetah:
		if not what in achivements:
			Debug.l("New abstract achivement %s" % what)
			achivements[what] = true
			saveToFile()
			emit_signal("achivedOffline", what)
			if not CurrentGame.isDemo():
				emit_signal("achived", what)

func updateLeaderboard(board: String, value: int):
	CurrentGame.checkGameState()
	if enable_achievements and not cheetah:
		if not callIfCan("updateLeaderboard", [board, value]):
			Debug.l("No leadarboards for %s: %f" % [board, value])
