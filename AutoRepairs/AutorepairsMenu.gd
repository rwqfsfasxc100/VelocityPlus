# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends Popup

export var enable_p = NodePath("PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/EnableAutorepair/CheckButton")
onready var enable = get_node_or_null(enable_p)
export var mode_button_p = NodePath("PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MethodPrio/OptionButton")
onready var mode_button = get_node_or_null(mode_button_p)

export var minmoney_p = NodePath("PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MinMoney/HSlider")
onready var minmoney = get_node_or_null(minmoney_p)

export var mininsurance_p = NodePath("PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MinInsurance/HSlider")
onready var mininsurance = get_node_or_null(mininsurance_p)

export var maxrepair_p = NodePath("PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MaxRepair/HSlider")
onready var maxrepair = get_node_or_null(maxrepair_p)

export var maxreplace_p = NodePath("PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MaxReplace/HSlider")
onready var maxreplace = get_node_or_null(maxreplace_p)

export var target_p = NodePath("PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/Target/HSlider")
onready var target = get_node_or_null(target_p)

var pointersVP

func vp_autorepairsmenu_VP():
	if pointersVP:
		config = pointersVP.ConfigDriver.__get_config("VelocityPlus")

func _enter_tree():
	pointersVP = ModLoader._savedObjects[0]
	pointersVP.ConfigDriver.__establish_connection("vp_autorepairsmenu_VP",self)
	vp_autorepairsmenu_VP()

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
		set_slider_val(config["VP_AUTOREPAIRS"]["minimum_money"],minmoney,"PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MinMoney/Val",true)
		set_slider_val(config["VP_AUTOREPAIRS"]["minimum_insurance"],mininsurance,"PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MinInsurance/Val",true)
		set_slider_val(config["VP_AUTOREPAIRS"]["maximum_repair"],maxrepair,"PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MaxRepair/Val",true)
		set_slider_val(config["VP_AUTOREPAIRS"]["maximum_replace"],maxreplace,"PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MaxReplace/Val",true)
		set_slider_val(config["VP_AUTOREPAIRS"]["target_percent"],target,"PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/Target/Val",true)

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
	save_slider_val(value,minmoney,"minimum_money","PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MinMoney/Val")


func mininsurance_changed(value):
	save_slider_val(value,mininsurance,"minimum_insurance","PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MinInsurance/Val")


func maxrepair_changed(value):
	save_slider_val(value,maxrepair,"maximum_repair","PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MaxRepair/Val")


func maxreplace_changed(value):
	save_slider_val(value,maxreplace,"maximum_replace","PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/MaxReplace/Val")


func target_changed(value):
	save_slider_val(value,target,"target_percent","PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/Target/Val")
