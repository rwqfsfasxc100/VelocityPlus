extends "res://ships/modules/PDT.gd"

var default_gimbal_limit = 0

var pointersVPPDT

func _ready():
	pointersVPPDT = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVPPDT.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()
	default_gimbal_limit = gimbalLimit

func updateValues():
	if pointersVPPDT:
		pointersVPPDT.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","disable_gimballed_and_turreted_weapons")

var fixed = false

func _physics_process(delta):
	if fixed:
		gimbalLimit = 0
	else:
		gimbalLimit = default_gimbal_limit
