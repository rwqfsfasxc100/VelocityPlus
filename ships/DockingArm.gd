extends "res://ships/modules/DockingArm.gd"

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func isValidTarget(body: RigidBody2D) -> bool:
	var result = .isValidTarget(body)
	var allow = ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","arm_focuses_to_targeted_object")
	if result and allow:
		if Tool.claim(ship):
			if ship.autopilotVelocityOffsetTarget and body != ship.autopilotVelocityOffsetTarget:
				# Debug.l("ARMFocus: Ignoring %s, want %s instead" % [body, ship.autopilotVelocityOffsetTarget])
				result = false
			Tool.release(ship)
	return result
