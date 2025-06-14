extends OptionButton

export (int) var number_of_options = 3

export (String) var section = "enceladus"
export (String) var setting = "simulator_shader"

export (Array) var option_names = ["OPTION_ONE","OPTION_TWO","OPTION_THREE"]

export (String) var config_selection = "VelocityPlus"

func _ready():
	align = Button.ALIGN_RIGHT
	addItems()
	
func addItems():
	var count = option_names.size()
	var index = 0
	while count >= 1:
		var added_option = option_names[index]
		add_item(added_option)
		count -= 1
		index += 1
	selected = Settings.get(config_selection)[section][setting]

func _on_OptionButton_item_selected(index):
	Settings.get(config_selection)[section][setting] = index


func _on_OptionButton_visibility_changed():
	selected = Settings.get(config_selection)[section][setting]
