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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends "res://hud/OMS.gd"

var dive_clock:Label = Label.new()
onready var dive_clock_game_node = get_tree().root.get_node_or_null("Game")

var money_waiting_label:Label = Label.new()
var money_waiting_label_1:Label = Label.new()

var soldGoods:Label = Label.new()
var soldGoods_1:Label = Label.new()
var soldGoods_2:Label = Label.new()
var soldGoods_3:Label = Label.new()
var soldGoods_4:Label = Label.new()
var soldGoods_5:Label = Label.new()

var astro_vpbox:HBoxContainer = HBoxContainer.new()
var astro_vb_1:VBoxContainer = VBoxContainer.new()
var astro_hb_2:HBoxContainer = HBoxContainer.new()
var astro_vb_spacer:VBoxContainer = VBoxContainer.new()
var astroTimeLabel:Label = Label.new()
var astroTimeDescLabel:Label = Label.new()

var vpShip

func vp_update_show_dive_time(how:bool):
	vp_show_dive_clock = how
	handle_visibility()

func vp_update_show_shipped_value(how:bool):
	vp_show_shipped_value = how
	handle_visibility()

func vp_update_show_transactions(how:bool):
	vp_show_transactions = how
	handle_visibility()

func vp_update_show_sold_goods(how:bool):
	vp_show_transactions_sold_goods = how
	handle_visibility()

func vp_update_show_bought_goods(how:bool):
	vp_show_transactions_bought_goods = how
	handle_visibility()

func vp_update_show_astrogation_time(how:bool):
	vp_show_time_spent_astrogating = how
	handle_visibility()

var vp_currently_installed_mpu:String = ""
var vp_has_mpu:bool = false
var vp_omsextendeddisplayhandler_uinit : bool = false
func _ready():
	if vp_omsextendeddisplayhandler_uinit:
		OS.kill(OS.get_process_id())
	vp_omsextendeddisplayhandler_uinit = true
	vpShip = get_parent().get_parent()
	if vpShip != CurrentGame.getPlayerShip():
		return
	vp_currently_installed_mpu = vpShip.getConfig("cargo.equipment","")
	if vp_currently_installed_mpu:
		vp_has_mpu = true
	CurrentGame.vp_this_dive_time_spent_astrogating = 0
	var headBox:VBoxContainer = $MarginContainer/VBoxContainer/Comms/VBoxContainer
	var box2:HBoxContainer = headBox.get_node("HBoxContainer2")
	var box1:HBoxContainer = headBox.get_node("HBoxContainer")
	var w2Label:Label = Label.new()
	w2Label.name = "Waiting_2"
	w2Label.text = "VP_CURRENT_CASH"
	box2.get_node("Money").size_flags_horizontal = 1
	var vp_box:HBoxContainer = HBoxContainer.new()
	vp_box.name = "VP_BOX"
	vp_box.modulate = Color( 0.5, 4, 0.5, 1 )
	vp_box.size_flags_vertical = 0
	soldGoods.name = "Waiting_0"
	money_waiting_label_1.name = "Waiting_1"
	money_waiting_label_1.size_flags_horizontal = 3
	money_waiting_label_1.align = 2
	money_waiting_label_1.text = "VP_CASH_AT_ENCELADUS"
	soldGoods.text = "VP_SOLD_GOODS"
	soldGoods.align = 2
	soldGoods_1.name = "SoldGoods"
	soldGoods_2.name = "soldGoods_2"
	soldGoods_3.name = "soldGoods_3"
	soldGoods_4.name = "soldGoods_4"
	soldGoods_5.name = "soldGoods_5"
	soldGoods_1.text = "0 E$"
	soldGoods_2.text = "|+"
	soldGoods_3.text = "0 E$"
	soldGoods_4.text = "|-"
	soldGoods_5.text = "0 E$"
	money_waiting_label_1.size_flags_horizontal = 3
	money_waiting_label_1.text = "VP_CASH_AT_ENCELADUS"
	money_waiting_label_1.align = 2
	money_waiting_label.name = "MoneyWaiting"
	money_waiting_label.text = "0 E$"
	var label2:Label = Label.new()
	label2.name = "Label2"
	label2.size_flags_horizontal = 3
	dive_clock.name = "DiveClock"
	dive_clock.modulate = Color( 0.5, 4, 0.5, 1 )
	dive_clock.text = "In dive: 0h 00m 00s | "
	dive_clock.align = 2
	box1.get_node("InGameTime").size_flags_horizontal = 1
	box2.add_child(w2Label)
	vp_box.add_child(soldGoods)
	vp_box.add_child(soldGoods_1)
	vp_box.add_child(soldGoods_2)
	vp_box.add_child(soldGoods_3)
	vp_box.add_child(soldGoods_4)
	vp_box.add_child(soldGoods_5)
	vp_box.add_child(money_waiting_label_1)
	vp_box.add_child(money_waiting_label)
	box1.add_child(label2)
	box1.add_child(dive_clock)
	headBox.add_child(vp_box)
	headBox.move_child(vp_box,1)
	box2.move_child(w2Label,2)
	box1.move_child(label2,1)
	box1.move_child(dive_clock,2)
	
	astro_vpbox.modulate = Color("40ff40")
	astro_vpbox.alignment = BoxContainer.ALIGN_END
	astro_vpbox.anchor_bottom = 1
	astro_vpbox.anchor_right = 1
	astro_vpbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	astro_vpbox.name = "VP_ASTRO_BOX"
	$MarginContainer/VBoxContainer/TabHintContainer/TabContainer/CREW_OCCUPATION_ASTROGATOR.add_child(astro_vpbox)
	astro_vb_1.alignment = BoxContainer.ALIGN_END
	astro_vb_1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	astro_vpbox.add_child(astro_vb_1)
	astro_vb_spacer.alignment = BoxContainer.ALIGN_END
	astro_vb_spacer.rect_min_size.x = 15
	astro_vb_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	astro_vpbox.add_child(astro_vb_spacer)
	astro_hb_2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	astro_vb_1.add_child(astro_hb_2)
	
	astroTimeDescLabel.align = Label.ALIGN_RIGHT
	astroTimeDescLabel.text = "VP_OMS_ASTRO_TIME_COUNTER_LABEL"
	astroTimeLabel.text = Tool.readableTimeSpan(0)
	astroTimeLabel.size_flags_horizontal = Label.SIZE_FILL
	astroTimeLabel.rect_size.x = 10
	astroTimeDescLabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	astroTimeLabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	astro_hb_2.add_child(astroTimeDescLabel)
	astro_hb_2.add_child(astroTimeLabel)
	
	# Must be handled last to ensure all labels are loaded
	var pointers:HevLibPointers._ConfigDriver = ModLoader._savedObjects[0].ConfigDriver
	pointers.__subscribe_to_setting_change("vp_update_show_dive_time",self,"VelocityPlus","VP_RING","show_dive_time_in_OMS")
	pointers.__subscribe_to_setting_change("vp_update_show_shipped_value",self,"VelocityPlus","VP_RING","show_shipped_cargo_value")
	pointers.__subscribe_to_setting_change("vp_update_show_transactions",self,"VelocityPlus","VP_RING","show_transactions")
	pointers.__subscribe_to_setting_change("vp_update_show_sold_goods",self,"VelocityPlus","VP_RING","show_transactions_sold_goods")
	pointers.__subscribe_to_setting_change("vp_update_show_bought_goods",self,"VelocityPlus","VP_RING","show_transactions_bought_goods")
	pointers.__subscribe_to_setting_change("vp_update_show_astrogation_time",self,"VelocityPlus","VP_RING","show_astrogation_time")
	vp_show_dive_clock = pointers.__get_value("VelocityPlus","VP_RING","show_dive_time_in_OMS",true)
	vp_show_shipped_value = pointers.__get_value("VelocityPlus","VP_RING","show_shipped_cargo_value",true)
	vp_show_transactions = pointers.__get_value("VelocityPlus","VP_RING","show_transactions",true)
	vp_show_transactions_sold_goods = pointers.__get_value("VelocityPlus","VP_RING","show_transactions_sold_goods",true)
	vp_show_transactions_bought_goods = pointers.__get_value("VelocityPlus","VP_RING","show_transactions_bought_goods",true)
	vp_show_time_spent_astrogating = pointers.__get_value("VelocityPlus","VP_RING","show_astrogation_time",true)
	handle_visibility()
	CurrentGame.this_dive_transactions_gain = 0
	CurrentGame.this_dive_transactions_spent = 0

var money_format:String = "%s E$"
var shipped_cargo_amt:float = 0.0

func _input(event:InputEvent):
	if event.is_action_pressed("velocityplus_toggle_hud"):
		if Tool.claim(vpShip):
			if !vpShip.cutscene and vpShip.isPlayerControlled():
				get_parent().visible = !get_parent().visible
			Tool.release(vpShip)
	if vp_has_mpu and event.is_action_pressed("velocityplus_toggle_mpu"):
		if Tool.claim(vpShip):
			if !vpShip.cutscene and vpShip.isPlayerControlled():
				var shipSystems:Dictionary = vpShip.getSystems()
				for node in shipSystems.keys():
					var sys:Dictionary = shipSystems[node]
					if sys.name == vp_currently_installed_mpu:
						sys.enabled = !sys.enabled
						sys.ref.enabled = !sys.ref.enabled
			Tool.release(vpShip)

var vp_show_dive_clock:bool = true
var vp_show_shipped_value:bool = true
var vp_show_transactions:bool = true
var vp_show_transactions_sold_goods:bool = true
var vp_show_transactions_bought_goods:bool = true
var vp_show_time_spent_astrogating:bool = true
var vpFrameUpdateTimer:int = 0
func _physics_process(delta:float):
	vpFrameUpdateTimer += 1
	if vpFrameUpdateTimer % 5 == 0:
		if dive_clock != null:
			if vp_show_dive_clock and dive_clock_game_node != null:
					var timeInDive:int = int(ceil(dive_clock_game_node.realtimePlayed))
					dive_clock.text = TranslationServer.translate("VP_DIVE_CLOCK_DISPLAY") % [
						int(timeInDive / 3600.0),
						int(timeInDive / 60.0) % 60,
						timeInDive % 60,
					] + " | "
					
			else:
				dive_clock.visible = false
	if vpFrameUpdateTimer % 10 == 0:
		if vp_show_shipped_value:
			shipped_cargo_amt = 0.0
			vpShip.configMutex.lock()
			if "remoteCargo" in vpShip.shipConfig:
				for mineral in vpShip.shipConfig.remoteCargo.keys():
					shipped_cargo_amt += CurrentGame.getMineralMarketPricePerKg(mineral) * vpShip.shipConfig.remoteCargo[mineral]
			vpShip.configMutex.unlock()
			money_waiting_label.text = money_format % CurrentGame.formatThousands(shipped_cargo_amt)
		if vp_show_transactions:
			var mGain:float = CurrentGame.this_dive_transactions_gain
			var mSpent:float = -CurrentGame.this_dive_transactions_spent
			soldGoods_1.text = money_format % CurrentGame.formatThousands(mGain + mSpent)
			if vp_show_transactions_sold_goods:
				soldGoods_3.text = money_format % CurrentGame.formatThousands(mGain)
			if vp_show_transactions_bought_goods:
				soldGoods_5.text = money_format % CurrentGame.formatThousands(abs(mSpent))
		if vp_show_time_spent_astrogating:
			astroTimeLabel.text = Tool.readableTimeSpan(CurrentGame.vp_this_dive_time_spent_astrogating)
	if vpFrameUpdateTimer > 100:
		vpFrameUpdateTimer = 0

func handle_visibility():
	if dive_clock != null:
		dive_clock.visible = vp_show_dive_clock
	money_waiting_label.visible = vp_show_shipped_value
	money_waiting_label_1.visible = vp_show_shipped_value
	soldGoods.visible = vp_show_transactions
	soldGoods_1.visible = vp_show_transactions
	soldGoods_2.visible = (vp_show_transactions and vp_show_transactions_sold_goods)
	soldGoods_3.visible = (vp_show_transactions and vp_show_transactions_sold_goods)
	soldGoods_4.visible = (vp_show_transactions and vp_show_transactions_bought_goods)
	soldGoods_5.visible = (vp_show_transactions and vp_show_transactions_bought_goods)
	astroTimeLabel.visible = vp_show_time_spent_astrogating
	astroTimeDescLabel.visible = vp_show_time_spent_astrogating
