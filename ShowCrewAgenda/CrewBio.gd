extends "res://enceladus/CrewBio.gd"

var vp_agendalabel = false

var pointersVP_crew_agenda_labels
func _enter_tree():
	pointersVP_crew_agenda_labels = ModLoader._savedObjects[0]
	pointersVP_crew_agenda_labels.ConfigDriver.__establish_connection("vp_agenda_labels_at_enceladus_UV",self)
	vp_agenda_labels_at_enceladus_UV()

func vp_agenda_labels_at_enceladus_UV():
	if pointersVP_crew_agenda_labels:
		vp_agendalabel = pointersVP_crew_agenda_labels.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","scoop_automatic_return_protocol_override")


func fillData():
	var vp_agenda_header = get_node_or_null(NodePath("Margin/HBoxContainer/VBoxContainer/HBoxContainer/GridContainer/AgendaLabel"))
	var vp_agenda_label = get_node_or_null(NodePath("Margin/HBoxContainer/VBoxContainer/HBoxContainer/GridContainer/Agenda"))
	vp_agenda_header.visible = false
	vp_agenda_label.visible = false
	if vp_agendalabel:
		var allagenda = CurrentGame.state.agenda
		for agenda in allagenda:
				if allagenda[agenda] == fullName:
					vp_agenda_header.visible = true
					vp_agenda_label.visible = true
					vp_agenda_label.text = "VP_AGENDANAME_" + agenda
