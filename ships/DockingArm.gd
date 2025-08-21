extends "res://ships/modules/DockingArm.gd"

func isValidTarget(body: RigidBody2D) -> bool:
	var result = .isValidTarget(body)
	if result:
		if Tool.claim(ship):
			if ship.autopilotVelocityOffsetTarget and body != ship.autopilotVelocityOffsetTarget:
				# Debug.l("ARMFocus: Ignoring %s, want %s instead" % [body, ship.autopilotVelocityOffsetTarget])
				result = false
			Tool.release(ship)
	return result
