extends Popup

func _ready():
	get_tree().get_root().connect("size_changed", self, "_on_resize")
	
func _on_resize():
	if visible:
		var viewportSize = get_parent().rect_size
		var size = rect_size
		rect_position = (viewportSize - size) / 2

func _on_Save_pressed():
	Settings.save_VelocityPlus_ToFile()
	Settings.restartGame()

func cancel():
	Settings.load_VelocityPlus_FromFile()
	Settings.save_VelocityPlus_ToFile()
	hide()
	refocus()
	
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else :
		Debug.l("I have no focus to fall back to!")

func _on_Cancel_pressed():
	cancel()
	
func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		
		cancel()
		get_tree().set_input_as_handled()
		

var lastFocus = null
#
#
func _on_VelocityPlus_pressed():
	popup_centered()


func _on_VelocityPlus_about_to_show():
	Settings.save_VelocityPlus_ToFile()
	lastFocus = get_focus_owner()
