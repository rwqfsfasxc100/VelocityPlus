extends Label
# Fixes issue no. 5033
# https://git.kodera.pl/games/delta-v/-/issues/5033

export  var format = "%s E$"

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
var config = {}
func _ready():
	config = ConfigDriver.__get_config("VelocityPlus")

func _process(delta):
	if config.get("VP_ENCELADUS",{}).get("mineral_market_show_total_value",true):
		get_parent().visible = true
		var sliders = get_parent().get_parent().get_parent().get_parent().get_node("MarginContainer/ScrollContainer/MarginContainer/Market").get_children()
		var total = 0
		for slide in sliders:
			var price = removeFormatting(slide.get_node("VBoxContainer/MarginContainer/HBoxContainer/Price").text)
			var multi = removeFormatting(slide.get_node("VBoxContainer/MarginContainer/HBoxContainer/H/Owned").text)
			var value = price * multi
			total = total + value
		var txt = CurrentGame.formatThousands(total)
		text = format % txt
	else:
		get_parent().visible = false

func removeFormatting(value):
	var vals = value.split(",")
	var rets = ""
	for val in vals:
		rets = rets + val
	return float(rets)
