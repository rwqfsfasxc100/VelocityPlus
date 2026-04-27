extends "res://weapons/drone-plant.gd"

var pointersVPEMP

var baseSanbus = true

var allowed_to = true

func _ready():
	if droneFunction == "repair":
		pointersVPEMP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
		pointersVPEMP.ConfigDriver.__establish_connection("vp_repairnosanbus_UV",self)
		vp_repairnosanbus_UV()

func vp_repairnosanbus_UV():
	if pointersVPEMP and droneFunction == "repair":
		baseSanbus = sanbus
		allowed_to = pointersVPEMP.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","disable_maint_sanbus")
		if allowed_to:
			sanbus = false
		else:
			sanbus = baseSanbus
