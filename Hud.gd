extends "res://hud/Hud.gd"

func _input(event):
	if Input.is_action_just_pressed("velocityplus_toggle_hud"):
		visible = !visible
