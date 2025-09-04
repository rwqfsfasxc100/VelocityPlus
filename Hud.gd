extends "res://hud/Hud.gd"

func _ready():
	self.set_process_input(true)

func _input(event):
	if !ship.cutscene and ship.isPlayerControlled():
		if Input.is_action("velocityplus_toggle_hud"):
			visible = !visible
