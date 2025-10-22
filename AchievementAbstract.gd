extends "res://achievement/AchivementAbstract.gd"

var enable_achievements = false
var cheetah = false

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
var config = {}
func _ready():
	cheetah = CurrentGame.cheetah
	config = ConfigDriver.__get_config("VelocityPlus")

func _physics_process(delta):
	enable_achievements = config.get("VP_ENCELADUS",{}).get("enable_achievements",true)
	if config.get("VP_ENCELADUS",{}).get("enable_achievements_on_cheated_saves",false):
		cheetah = false

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
