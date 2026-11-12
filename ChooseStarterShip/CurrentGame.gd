extends "res://CurrentGame.gd"

var vp_ship_override:String = "TRTL"

func newGame():
	.newGame()
	if vp_ship_override != "TRTL":
		state.ship = Shipyard.getDefaultConfigByName(vp_ship_override)
		vp_ship_override = "TRTL"
	
