extends "res://hud/Hud.gd"

func _input(event):
	if Input.is_action_just_pressed("toggle_hud"):
		visible = !visible
