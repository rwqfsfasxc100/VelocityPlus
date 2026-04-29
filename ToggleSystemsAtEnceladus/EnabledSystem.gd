extends VBoxContainer

var tuningItem:String
var tune:bool = true

signal value_changed(to)

func _ready():
	$HBoxContainer / Name.text = tuningItem
	var cb = $HBoxContainer / Value
	cb.pressed = tune
	changed(tune)
	cb.connect("focus_entered", self, "_focus")
	$HBoxContainer / Name.connect("focus_entered", self, "_nameFocus")
	
func _nameFocus():
	$HBoxContainer / Value.grab_focus()
	
func _focus():
	emit_signal("value_changed", tune)
	
func changed(to):
	emit_signal("value_changed", to)
	
func focus():
	$HBoxContainer / Value.grab_focus()
	emit_signal("value_changed", tune)

func _on_Button_pressed():
	$HBoxContainer / Value.pressed = tune

