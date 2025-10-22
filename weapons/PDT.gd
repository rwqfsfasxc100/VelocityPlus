extends "res://ships/modules/PDT.gd"

var default_gimbal_limit = 0

const ConfigDriverVP = preload("res://HevLib/pointers/ConfigDriver.gd")

func _ready():
	default_gimbal_limit = gimbalLimit

func _physics_process(delta):
	if ConfigDriverVP.__get_value("VelocityPlus","VP_SHIPS","disable_gimballed_and_turreted_weapons"):
		gimbalLimit = 0
	else:
		gimbalLimit = default_gimbal_limit
