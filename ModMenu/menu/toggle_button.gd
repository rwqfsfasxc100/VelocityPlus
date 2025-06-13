extends CheckButton

export  var setting = "mineral_market_show_total_value"
export  var section = "enceladus"

func _ready():
	connect("visibility_changed", self, "_visibility_changed")
	connect("toggled", self, "_toggled")
	
func _toggled(how):
	Settings.VelocityPlus[section][setting] = how

func _visibility_changed():
	pressed = Settings.VelocityPlus[section][setting]
