extends "res://hud/components/RestricedCrewList.gd"

var pointersVP
signal drawn_crew
var vacPath = NodePath("C/O/Vac")

func _enter_tree():
	pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP.ConfigDriver.__establish_connection("updateValues",self)
	yield(self,"drawn_crew")
	updateValues()

func updateValues():
	if pointersVP:
		var hideCrew = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_CREW","hide_in_OMS")
		if hideCrew:
			visible = false
		else:
			var hideVac = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_CREW","hide_crew_suit")
			for i in list.get_children():
				var vac = i.get_node_or_null(vacPath)
				if vac:
					if hideVac:
						vac.visible = false
					else:
						vac.visible = true
			visible = true

func drawCrew():
	.drawCrew()
	emit_signal("drawn_crew")
