extends SpinBox

export  var setting = "mineral_market_show_total_value"
export  var section = "enceladus"

var num_value = 1.0

func _ready():
	connect("value_changed", self, "_value_changed")
	num_value = Settings.VelocityPlus[section][setting]

func _value_changed(v):
	num_value = v
	Settings.VelocityPlus[section][setting] = num_value
