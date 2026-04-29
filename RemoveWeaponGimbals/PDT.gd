extends "res://ships/modules/PDT.gd"

var default_gimbal_limit = 0
var fixed = false
var pointersVP_gimbal_remover

func _enter_tree():
	default_gimbal_limit = gimbalLimit
	pointersVP_gimbal_remover = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP_gimbal_remover.ConfigDriver.__establish_connection("vp_gimbal_remover_UV",self)
	vp_gimbal_remover_UV()

func vp_gimbal_remover_UV():
	if pointersVP_gimbal_remover:
		fixed = pointersVP_gimbal_remover.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","disable_gimballed_and_turreted_weapons")

func _physics_process(delta):
	if fixed:
		gimbalLimit = 0
	else:
		gimbalLimit = default_gimbal_limit
