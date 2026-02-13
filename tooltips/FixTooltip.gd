extends Button
# Fixes issue no. 5340
# https://git.kodera.pl/games/delta-v/-/issues/5340

var pointersVP

func _enter_tree():
	pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()

func updateValues():
	if pointersVP:
		showVPToolTips = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_ENCELADUS","extra_tooltips")

var showVPToolTips = true
func _physics_process(delta):
	if showVPToolTips:
		if disabled:
			hint_tooltip = "DKB_CANNOT_REPAIR"
		else:
			hint_tooltip = "DKB_REPAIR_EQUIPMENT"
	else:
		hint_tooltip = ""
