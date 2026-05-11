extends "res://ships/ship-ctrl.gd"

func fastTravelTo(target):
	var dv = CurrentGame.getInRingVectorTowards(target.vector, CurrentGame.globalCoords(global_position))
	var t = dv.length() / astrogationVelocity
	CurrentGame.vp_this_dive_time_spent_astrogating += t
	.fastTravelTo(target)
