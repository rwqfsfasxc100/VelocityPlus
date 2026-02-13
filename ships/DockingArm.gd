extends "res://ships/modules/DockingArm.gd"

var pointersVP

func _enter_tree():
	pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()

func updateValues():
	if pointersVP:
		armFocuses = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","arm_focuses_to_targeted_object")


var armFocuses = true
func isValidTarget(body: RigidBody2D) -> bool:
	var result = .isValidTarget(body)
	if not hardLock:
		if result:
			if armFocuses:
				if Tool.claim(ship):
					if ship.autopilotVelocityOffsetTarget and body != ship.autopilotVelocityOffsetTarget:
						# Debug.l("ARMFocus: Ignoring %s, want %s instead" % [body, ship.autopilotVelocityOffsetTarget])
						result = false
					Tool.release(ship)
	return result
