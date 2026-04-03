extends "res://enceladus/CrewFaceOnEnceladus.gd"

var pointersVP
var vacPath = NodePath("C/O/Vac")
func _enter_tree():
	pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP.ConfigDriver.__establish_connection("updateValues",self)
	yield(CurrentGame.get_tree(),"idle_frame")
	updateValues()

func updateValues():
	if pointersVP:
		var hideCrew = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_CREW","hide_on_enceladus")
		if hideCrew:
			visible = false
		else:
			var hideVac = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_CREW","hide_crew_suit")
			var vac = get_node_or_null(vacPath)
			if vac:
				if hideVac:
					vac.visible = false
				else:
					vac.visible = true
			visible = true
	else:
		visible = true
