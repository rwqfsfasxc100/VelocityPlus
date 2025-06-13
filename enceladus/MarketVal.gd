extends Label
# Fixes issue no. 5033
# https://git.kodera.pl/games/delta-v/-/issues/5033

export  var format = "%s E$"

func _process(delta):
	var sliders = get_parent().get_parent().get_parent().get_parent().get_node("MarginContainer/ScrollContainer/MarginContainer/Market").get_children()
	var total = 0
	for slide in sliders:
		var price = removeFormatting(slide.get_node("VBoxContainer/MarginContainer/HBoxContainer/Price").text)
		var multi = removeFormatting(slide.get_node("VBoxContainer/MarginContainer/HBoxContainer/H/Owned").text)
		var value = price * multi
		total = total + value
	var txt = CurrentGame.formatThousands(total)
	text = format % txt

func removeFormatting(value):
	var vals = value.split(",")
	var rets = ""
	for val in vals:
		rets = rets + val
	return float(rets)
