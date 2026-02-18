extends "res://enceladus/SystemShipRepairUI.gd"

var allow_hide = true

var pointersVP

func _enter_tree():
	pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()

func updateValues():
	if pointersVP:
		hide_unrepairable_equipment = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_ENCELADUS","hide_unrepairable_equipment")


var hide_unrepairable_equipment = true
func updateStatuses():
	.updateStatuses()
	if hide_unrepairable_equipment and allow_hide:
		var was_visible = visible
		if system.status >= 99.5:
			visible = false
		else:
			visible = true
		if was_visible != visible:
			handleFocuses()

func handleFocuses():
	var focused = false
	if visible:
		fixButton.call_deferred("grab_focus")
		focused = true
	else:
		for b in get_parent().get_children():
			if b.visible:
				b.fixButton.grab_focus()
				focused = true
				break
	if not focused:
		get_node("../../../../Control/Autorepairs/PanelContainer/Buttons/Autorepairs").grab_focus()
