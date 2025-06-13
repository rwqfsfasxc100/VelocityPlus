extends OptionButton

export (int) var number_of_options = 3

export (Array) var option_names = ["OPTION_ONE","OPTION_TWO","OPTION_THREE"]

export (String) var config_selection = "VelocityPlus"

func _ready():
	addItems()
	
func addItems():
	for i in range(0,number_of_options - 1):
		var added_option = option_names[i]
		add_item(added_option)
	selected = Settings.get(config_selection)["mainSettings"]["updaterOption"]

func _on_OptionButton_item_selected(index):
	Settings.get(config_selection)["mainSettings"]["updaterOption"] = index


func _on_OptionButton_visibility_changed():
	selected = Settings.get(config_selection)["mainSettings"]["updaterOption"]
