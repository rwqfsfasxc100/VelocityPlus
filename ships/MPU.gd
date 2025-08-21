extends "res://ships/modules/MineralProcessingUnit.gd"


# Toggle the MPU when the key is pressed
func _input(event):
	if !ship.cutscene and ship.isPlayerControlled():
		if event.is_action_pressed("velocityplus_toggle_mpu"):
			enabled = not enabled
