extends "res://ships/modules/PDT.gd"

var default_gimbal_limit = 0

func _ready():
	default_gimbal_limit = gimbalLimit
	if Settings.VelocityPlus["ships"]["disable_gimballed_and_turreted_weapons"]:
		gimbalLimit = 0
