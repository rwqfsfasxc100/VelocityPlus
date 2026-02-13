extends "res://hud/SystemList.gd"

var omsToggleCfg = "omstoggles.%s.%s"

var pointersVP

func _enter_tree():
	pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()

func updateValues():
	if pointersVP:
		remember_toggled_systems = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","remember_toggled_systems")

var remember_toggled_systems = false
func toggle(s, b):
	.toggle(s, b)
	if remember_toggled_systems:
		var vname = s.ref.name
		var sname = s.name
		ship.setConfig(omsToggleCfg % [vname,sname],b.pressed)
