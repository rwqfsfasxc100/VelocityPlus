extends "res://hud/OMS.gd"

var _diveClock# = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/HBoxContainer/_diveClock")
onready var _diveClockGame = get_tree().root.get_node_or_null("Game")

var money_waiting_label# = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/MoneyWaiting")
var money_waiting_label_1# = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/Waiting_1")

var soldGoods# = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/Waiting_0")
var soldGoods_1# = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/SoldGoods")
var soldGoods_2# = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/soldGoods_2")
var soldGoods_3# = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/soldGoods_3")
var soldGoods_4# = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/soldGoods_4")
var soldGoods_5# = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/soldGoods_5")

var astro_vpbox
var astro_vb_1
var astro_hb_2
var astro_vb_spacer
var astroTimeLabel
var astroTimeDescLabel

var ship

var pointersVP


func vp_omslabels_UV():
	if pointersVP:
		var config = pointersVP.ConfigDriver.__get_config("VelocityPlus").get("VP_RING",{})
		show_dive_clock = config.get("show_dive_time_in_OMS",true)
		show_shipped_value = config.get("show_shipped_cargo_value",true)
		show_transactions = config.get("show_transactions",true)
		show_transactions_sold_goods = config.get("show_transactions_sold_goods",true)
		show_transactions_bought_goods = config.get("show_transactions_bought_goods",true)
		show_time_spent_astrogating = config.get("show_astrogation_time",true)
		
		handle_visibility()


func _ready():
	var headBox = $MarginContainer/VBoxContainer/Comms/VBoxContainer
	var box2 = headBox.get_node("HBoxContainer2")
	var box1 = headBox.get_node("HBoxContainer")
	var w2Label = Label.new()
	w2Label.name = "Waiting_2"
	w2Label.text = "VP_CURRENT_CASH"
	box2.get_node("Money").size_flags_horizontal = 1
	var vp_box = HBoxContainer.new()
	vp_box.name = "VP_BOX"
	vp_box.modulate = Color( 0.5, 4, 0.5, 1 )
	vp_box.size_flags_vertical = 0
	soldGoods = Label.new()
	soldGoods.name = "Waiting_0"
	money_waiting_label_1 = Label.new()
	money_waiting_label_1.name = "Waiting_1"
	money_waiting_label_1.size_flags_horizontal = 3
	money_waiting_label_1.align = 2
	money_waiting_label_1.text = "VP_CASH_AT_ENCELADUS"
	soldGoods.text = "VP_SOLD_GOODS"
	soldGoods.align = 2
	soldGoods_1 = Label.new()
	soldGoods_2 = Label.new()
	soldGoods_3 = Label.new()
	soldGoods_4 = Label.new()
	soldGoods_5 = Label.new()
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
	money_waiting_label = Label.new()
	money_waiting_label.name = "MoneyWaiting"
	money_waiting_label.text = "0 E$"
	var label2 = Label.new()
	label2.name = "Label2"
	label2.size_flags_horizontal = 3
	_diveClock = Label.new()
	_diveClock.name = "_diveClock"
	_diveClock.modulate = Color( 0.5, 4, 0.5, 1 )
	_diveClock.text = "In dive: 0h 00m 00s | "
	_diveClock.align = 2
	var igt = box1.get_node("InGameTime")
	igt.size_flags_horizontal = 1
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
	box1.add_child(_diveClock)
	headBox.add_child(vp_box)
	headBox.move_child(vp_box,1)
	box2.move_child(w2Label,2)
	box1.move_child(label2,1)
	box1.move_child(_diveClock,2)
	
	
	
	var astroGC = get_node("MarginContainer/VBoxContainer/TabHintContainer/TabContainer/CREW_OCCUPATION_ASTROGATOR")
	astro_vpbox = HBoxContainer.new()
	astro_vpbox.modulate = Color("40ff40")
	astro_vpbox.alignment = BoxContainer.ALIGN_END
	astro_vpbox.anchor_bottom = 1
	astro_vpbox.anchor_right = 1
	astro_vpbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	astro_vpbox.name = "VP_ASTRO_BOX"
	astroGC.add_child(astro_vpbox)
	astro_vb_1 = VBoxContainer.new()
	astro_vb_1.alignment = BoxContainer.ALIGN_END
	astro_vb_1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	astro_vpbox.add_child(astro_vb_1)
	astro_vb_spacer = VBoxContainer.new()
	astro_vb_spacer.alignment = BoxContainer.ALIGN_END
	astro_vb_spacer.rect_min_size.x = 15
	astro_vb_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	astro_vpbox.add_child(astro_vb_spacer)
	astro_hb_2 = HBoxContainer.new()
	astro_hb_2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	astro_vb_1.add_child(astro_hb_2)
	
#	var separator1 = Label.new()
#	var separator2 = Label.new()
#	separator1.size_flags_vertical = Label.SIZE_EXPAND_FILL
#	separator2.size_flags_vertical = Label.SIZE_EXPAND_FILL
	
	astroTimeDescLabel = Label.new()
	astroTimeLabel = Label.new()
	astroTimeDescLabel.align = Label.ALIGN_RIGHT
	astroTimeDescLabel.text = "VP_OMS_ASTRO_TIME_COUNTER_LABEL"
	astroTimeLabel.text = Tool.readableTimeSpan(0)
	astroTimeLabel.size_flags_horizontal = Label.SIZE_FILL
	astroTimeLabel.rect_size.x = 10
	astroTimeDescLabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	astroTimeLabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
#	astroGC.add_child(separator1)
#	astroGC.add_child(separator2)
	astro_hb_2.add_child(astroTimeDescLabel)
	astro_hb_2.add_child(astroTimeLabel)
	
	
	# Must be handled last to ensure all labels are loaded
	pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP.ConfigDriver.__establish_connection("vp_omslabels_UV",self)
	vp_omslabels_UV()
	ship = get_parent().get_parent()
	if ship == CurrentGame.getPlayerShip():
		CurrentGame.this_dive_transactions_gain = 0
		CurrentGame.this_dive_transactions_spent = 0
	
	

var money_format = "%s E$"
var shipped_cargo_amt = 0.0

func _input(event):
	if !ship.cutscene and ship.isPlayerControlled():
#		breakpoint
		if event.is_action_pressed("velocityplus_toggle_hud"):
			get_parent().visible = !get_parent().visible
		if event.is_action_pressed("velocityplus_toggle_mpu"):
			var current_mpu = ship.getConfig("cargo.equipment")
			for node in ship.get_children():
				if "systemName" in node and "removeChunks" in node:
					var nname = node.name
					if node.systemName == current_mpu:
						node.enabled = !node.enabled

var show_dive_clock = true
var show_shipped_value = true
var show_transactions = true
var show_transactions_sold_goods = true
var show_transactions_bought_goods = true
var show_time_spent_astrogating = true
var vpFrameUpdateTimer = 0
func _physics_process(delta):
	vpFrameUpdateTimer += 1
	if vpFrameUpdateTimer % 5 == 0:
		if show_dive_clock:
			var text = ""
			if _diveClockGame != null and _diveClock != null:
				var timeInDive = int(ceil(_diveClockGame.realtimePlayed))
				text += TranslationServer.translate("VP_DIVE_CLOCK_DISPLAY") % [
					timeInDive / 3600,
					timeInDive / 60 % 60,
					timeInDive % 60,
				]
				_diveClock.text = text + " | "
				
		else:
			if _diveClock != null:
				_diveClock.visible = false
	if vpFrameUpdateTimer % 10 == 0:
		if show_shipped_value:
			shipped_cargo_amt = 0.0
			ship.configMutex.lock()
			if "remoteCargo" in ship.shipConfig:
				for mineral in ship.shipConfig.remoteCargo.keys():
					shipped_cargo_amt += CurrentGame.getMineralMarketPricePerKg(mineral) * ship.shipConfig.remoteCargo[mineral]
			ship.configMutex.unlock()
			var txt = money_format % CurrentGame.formatThousands(shipped_cargo_amt)
			money_waiting_label.text = str(txt)
		if show_transactions:
			var mGain = CurrentGame.this_dive_transactions_gain
			var mSpent = -CurrentGame.this_dive_transactions_spent
			var soldVal = mGain + mSpent
			var soldTex = money_format % CurrentGame.formatThousands(soldVal)
			soldGoods_1.text = soldTex
			if show_transactions_sold_goods:
				soldGoods_3.text = money_format % CurrentGame.formatThousands(mGain)
			if show_transactions_bought_goods:
				soldGoods_5.text = money_format % CurrentGame.formatThousands(abs(mSpent))
		if show_time_spent_astrogating:
			var t = CurrentGame.vp_this_dive_time_spent_astrogating
			astroTimeLabel.text = Tool.readableTimeSpan(t)
	if vpFrameUpdateTimer > 100:
		vpFrameUpdateTimer = 0

func handle_visibility():
	if _diveClock != null:
		_diveClock.visible = show_dive_clock
	money_waiting_label.visible = show_shipped_value
	money_waiting_label_1.visible = show_shipped_value
	soldGoods.visible = show_transactions
	soldGoods_1.visible = show_transactions
	soldGoods_2.visible = (show_transactions and show_transactions_sold_goods)
	soldGoods_3.visible = (show_transactions and show_transactions_sold_goods)
	soldGoods_4.visible = (show_transactions and show_transactions_bought_goods)
	soldGoods_5.visible = (show_transactions and show_transactions_bought_goods)
	astroTimeLabel.visible = show_time_spent_astrogating
	astroTimeDescLabel.visible = show_time_spent_astrogating
