extends "res://hud/OMS.gd"

onready var _diveClock = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/HBoxContainer/RealTime")
onready var _diveClockGame = get_tree().root.get_node_or_null("Game")

onready var money_waiting_label = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/MoneyWaiting")
onready var money_waiting_label_1 = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/Waiting_1")

onready var soldGoods = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/Waiting_0")
onready var soldGoods_1 = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/SoldGoods")
onready var soldGoods_2 = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/SoldGoods2")
onready var soldGoods_3 = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/SoldGoods3")
onready var soldGoods_4 = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/SoldGoods4")
onready var soldGoods_5 = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/VP_BOX/SoldGoods5")

var ship

var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func _ready():
	ship = get_parent().get_parent()
	if ship == CurrentGame.getPlayerShip():
		CurrentGame.this_dive_transactions_gain = 0
		CurrentGame.this_dive_transactions_spent = 0

var money_format = "%s E$"


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

func _physics_process(delta):
	if int(Time.get_ticks_msec() * 1000) % 4 == 0:
		if ConfigDriver.__get_value("VelocityPlus","VP_RING","show_dive_time_in_OMS"):
			var text = ""
			if _diveClockGame != null and _diveClock != null:
				var timeInDive = int(ceil(_diveClockGame.realtimePlayed))
				text += TranslationServer.translate("VP_DIVE_CLOCK_DISPLAY") % [
					timeInDive / 3600,
					timeInDive / 60 % 60,
					timeInDive % 60,
				]
				_diveClock.text = text + " | "
				_diveClock.visible = true
		else:
			if _diveClock != null:
				_diveClock.visible = false
		
		if ConfigDriver.__get_value("VelocityPlus","VP_RING","show_shipped_cargo_value"):
			
			var value = 0.0
			ship.configMutex.lock()
			if "remoteCargo" in ship.shipConfig:
				for mineral in ship.shipConfig.remoteCargo.keys():
					value += CurrentGame.getMineralMarketPricePerKg(mineral) * ship.shipConfig.remoteCargo[mineral]
			ship.configMutex.unlock()
			money_waiting_label.visible = true
			money_waiting_label_1.visible = true
			var txt = money_format % CurrentGame.formatThousands(value)
			money_waiting_label.text = str(txt) #+ " | "
		else:
			money_waiting_label.visible = false
			money_waiting_label_1.visible = false
			
		if ConfigDriver.__get_value("VelocityPlus","VP_RING","show_transactions"):
			soldGoods.visible = true
			soldGoods_1.visible = true
			var mGain = CurrentGame.this_dive_transactions_gain
			var mSpent = -CurrentGame.this_dive_transactions_spent
			var soldVal = mGain + mSpent
			var soldTex = money_format % CurrentGame.formatThousands(soldVal)
			soldGoods_1.text = soldTex
			
			if ConfigDriver.__get_value("VelocityPlus","VP_RING","show_transactions_sold_goods"):
				soldGoods_2.visible = true
				soldGoods_3.visible = true
				soldGoods_3.text = money_format % CurrentGame.formatThousands(mGain)
			else:
				soldGoods_2.visible = false
				soldGoods_3.visible = false
				
			if ConfigDriver.__get_value("VelocityPlus","VP_RING","show_transactions_bought_goods"):
				soldGoods_4.visible = true
				soldGoods_5.visible = true
				soldGoods_5.text = money_format % CurrentGame.formatThousands(abs(mSpent))
			else:
				soldGoods_4.visible = false
				soldGoods_5.visible = false
		else:
			soldGoods.visible = false
			soldGoods_1.visible = false
			soldGoods_2.visible = false
			soldGoods_3.visible = false
			soldGoods_4.visible = false
			soldGoods_5.visible = false
