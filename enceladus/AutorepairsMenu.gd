extends Popup

export var enable_p = NodePath("PanelContainer/VBoxContainer/VBoxContainer/EnableAutorepair/CheckButton")
onready var enable = get_node_or_null(enable_p)
export var mode_button_p = NodePath("PanelContainer/VBoxContainer/VBoxContainer/MethodPrio/OptionButton")
onready var mode_button = get_node_or_null(mode_button_p)

export var minmoney_p = NodePath("PanelContainer/VBoxContainer/VBoxContainer/MinMoney/HSlider")
onready var minmoney = get_node_or_null(minmoney_p)

export var mininsurance_p = NodePath("PanelContainer/VBoxContainer/VBoxContainer/MinInsurance/HSlider")
onready var mininsurance = get_node_or_null(minmoney_p)

export var maxrepair_p = NodePath("PanelContainer/VBoxContainer/VBoxContainer/MaxRepair/HSlider")
onready var maxrepair = get_node_or_null(minmoney_p)

export var maxreplace_p = NodePath("PanelContainer/VBoxContainer/VBoxContainer/MaxReplace/HSlider")
onready var maxreplace = get_node_or_null(minmoney_p)

export var target_p = NodePath("PanelContainer/VBoxContainer/VBoxContainer/Target/HSlider")
onready var target = get_node_or_null(minmoney_p)

var pointersVP

func _enter_tree():
	pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()

func updateValues():
	if pointersVP:
		config = pointersVP.ConfigDriver.__get_config("VelocityPlus")

var config = {}
func _ready():
	mode_button.add_item("VP_AUTOREPAIR_PRIORITY_COSTEFFECTIVE",0)
	mode_button.add_item("VP_AUTOREPAIR_PRIORITY_ONLYREPAIR",1)
	mode_button.add_item("VP_AUTOREPAIR_PRIORITY_ONLYREPLACE",2)
	mode_button.add_item("VP_AUTOREPAIR_PRIORITY_MAXPROFIT",3)
	

func _visibility_changed():
	if is_visible_in_tree():
		
		
		enable.pressed = config["VP_AUTOREPAIRS"]["automatic_repairs"]
		
		match config["VP_AUTOREPAIRS"]["method_priority"]:
			"VP_AUTOREPAIR_PRIORITY_COSTEFFECTIVE":
				mode_button.selected = 0
			"VP_AUTOREPAIR_PRIORITY_ONLYREPAIR":
				mode_button.selected = 1
			"VP_AUTOREPAIR_PRIORITY_ONLYREPLACE":
				mode_button.selected = 2
			"VP_AUTOREPAIR_PRIORITY_MAXPROFIT":
				mode_button.selected = 3
		yield(get_tree(),"idle_frame")
		set_slider_val(config["VP_AUTOREPAIRS"]["minimum_money"],minmoney,"PanelContainer/VBoxContainer/VBoxContainer/MinMoney/Val",true)
		set_slider_val(config["VP_AUTOREPAIRS"]["minimum_insurance"],mininsurance,"PanelContainer/VBoxContainer/VBoxContainer/MinInsurance/Val",true)
		set_slider_val(config["VP_AUTOREPAIRS"]["maximum_repair"],maxrepair,"PanelContainer/VBoxContainer/VBoxContainer/MaxRepair/Val",true)
		set_slider_val(config["VP_AUTOREPAIRS"]["maximum_replace"],maxreplace,"PanelContainer/VBoxContainer/VBoxContainer/MaxReplace/Val",true)
		set_slider_val(config["VP_AUTOREPAIRS"]["target_percent"],target,"PanelContainer/VBoxContainer/VBoxContainer/Target/Val",true)

var code_changed = []

func set_slider_val(val,s,v,code = false):
	if code:
		code_changed.append(s)
	s.value = val
	get_node(v).text = str(val)
	yield(get_tree(),"idle_frame")
	if code:
		code_changed.erase(s)

func save_slider_val(val,s,opt,v):
	if not s in code_changed:
		pointersVP.ConfigDriver.__store_value("VelocityPlus","VP_AUTOREPAIRS",opt,val)
		get_node(v).text = str(val)

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")

func _about_to_show():
	lastFocus = get_focus_owner()
	

func _input(event):
	if visible:
		if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("pause"):
			cancel()
			get_tree().set_input_as_handled()

func show_menu():
	popup_centered()

func cancel():
	hide()
	refocus()


func enabled_toggle(button_pressed):
	pointersVP.ConfigDriver.__store_value("VelocityPlus","VP_AUTOREPAIRS","automatic_repairs",button_pressed)


func method_select(index):
	match index:
		0:
			pointersVP.ConfigDriver.__store_value("VelocityPlus","VP_AUTOREPAIRS","method_priority","VP_AUTOREPAIR_PRIORITY_COSTEFFECTIVE")
		1:
			pointersVP.ConfigDriver.__store_value("VelocityPlus","VP_AUTOREPAIRS","method_priority","VP_AUTOREPAIR_PRIORITY_ONLYREPAIR")
		2:
			pointersVP.ConfigDriver.__store_value("VelocityPlus","VP_AUTOREPAIRS","method_priority","VP_AUTOREPAIR_PRIORITY_ONLYREPLACE")
		3:
			pointersVP.ConfigDriver.__store_value("VelocityPlus","VP_AUTOREPAIRS","method_priority","VP_AUTOREPAIR_PRIORITY_MAXPROFIT")


func minmoney_changed(value):
	save_slider_val(value,minmoney,"minimum_money","PanelContainer/VBoxContainer/VBoxContainer/MinMoney/Val")


func mininsurance_changed(value):
	save_slider_val(value,mininsurance,"minimum_insurance","PanelContainer/VBoxContainer/VBoxContainer/MinInsurance/Val")


func maxrepair_changed(value):
	save_slider_val(value,maxrepair,"maximum_repair","PanelContainer/VBoxContainer/VBoxContainer/MaxRepair/Val")


func maxreplace_changed(value):
	save_slider_val(value,maxreplace,"maximum_replace","PanelContainer/VBoxContainer/VBoxContainer/MaxReplace/Val")


func target_changed(value):
	save_slider_val(value,target,"maximum_replace","PanelContainer/VBoxContainer/VBoxContainer/Target/Val")
