extends "res://ships/modules/MineralProcessingUnit.gd"

func _ready():
	self.set_process_input(true)

# Toggle the MPU when the key is pressed
func _input(event):
	if !ship.cutscene and ship.isPlayerControlled():
		if event.is_action("velocityplus_toggle_mpu"):
			enabled = not enabled
