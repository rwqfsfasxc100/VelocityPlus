extends Label
# Fixes issue no. 5033
# https://git.kodera.pl/games/delta-v/-/issues/5033

export  var format = "%s E$"

var pointersVP

func _enter_tree():
	pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()

func updateValues():
	if pointersVP:
		mineral_market_show_total_value = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_ENCELADUS","mineral_market_show_total_value")

var mineral_market_show_total_value = true

func _process(delta):
	if mineral_market_show_total_value:
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
	var vals = value.split(TranslationServer.translate("SEPARATOR_THOUSAND"))
	var rets = ""
	for val in vals:
		rets = rets + val
	return float(rets)
