extends "res://enceladus/CrewFaceOnEnceladus.gd"

var pointersVP
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
			if hideVac:
				get_node_or_null("C/O").position = Vector2(120,100)
				get_node_or_null("C/O/Face/Sprite").z_index = 2
				get_node_or_null("C/O/Vac").visible = false
				get_node_or_null("C/O/Screen2").texture_scale = 50
				get_node_or_null("C/O/Screen2").energy = 2.19
				get_node_or_null("C/O/Screen2").color = Color( "bebebe" )
				get_node_or_null("C/O/Screen3").energy = 0.0
				get_node_or_null("C/O/Screen3").visible = false
				
			else:
				get_node_or_null("C/O").position = Vector2(120,0)
				get_node_or_null("C/O/Face/Sprite").z_index = 1
				get_node_or_null("C/O/Vac").visible = true
				get_node_or_null("C/O/Screen2").texture_scale = 4.34
				get_node_or_null("C/O/Screen2").energy = 4.05
				get_node_or_null("C/O/Screen2").color = Color( "e1a023" )
				get_node_or_null("C/O/Screen3").energy = 5.9
				get_node_or_null("C/O/Screen3").visible = true
					
			visible = true
	else:
		visible = true
