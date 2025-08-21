extends "res://achievement/AchivementAbstract.gd"


func validateStatAchievements():
	CurrentGame.checkGameState()
	var cheetah = CurrentGame.cheetah
	if Settings.VelocityPlus["enceladus"]["enable_achievements_on_cheated_saves"]:
		cheetah = false
	if not cheetah:
		for k in achivements:
			if k.begins_with("stat:"):
				var stat = k.trim_prefix("stat:")
				var v = achivements[k]
				Debug.l("Validating stat %s to %s" % [stat, v])
				emit_signal("stat", stat, v)

func setStat(stat:String, to)->void :
	CurrentGame.checkGameState()
	var cheetah = CurrentGame.cheetah
	if Settings.VelocityPlus["enceladus"]["enable_achievements_on_cheated_saves"]:
		cheetah = false
	if not cheetah:
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
	var cheetah = CurrentGame.cheetah
	if Settings.VelocityPlus["enceladus"]["enable_achievements_on_cheated_saves"]:
		cheetah = false
	if not cheetah:
		if not what in achivements:
			Debug.l("New abstract achivement %s" % what)
			achivements[what] = true
			saveToFile()
			emit_signal("achivedOffline", what)
			if not CurrentGame.isDemo():
				emit_signal("achived", what)
