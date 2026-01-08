extends "res://hud/OMS.gd"

onready var _diveClock = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/HBoxContainer/RealTime")
onready var _diveClockGame = get_tree().root.get_node_or_null("Game")

onready var money_waiting_label = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/HBoxContainer2/MoneyWaiting")
onready var money_waiting_label_1 = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/HBoxContainer2/Waiting_1")
onready var money_waiting_label_2 = get_node_or_null("MarginContainer/VBoxContainer/Comms/VBoxContainer/HBoxContainer2/Waiting_2")

var ship

var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func _ready():
	ship = get_parent().get_parent()

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
			if money_waiting_label != null and money_waiting_label_1 != null and money_waiting_label_2 != null:
				var value = 0.0
				money_waiting_label.visible = true
				money_waiting_label_1.visible = true
				money_waiting_label_2.visible = true
				ship.configMutex.lock()
				if "remoteCargo" in ship.shipConfig:
					for mineral in ship.shipConfig.remoteCargo.keys():
						value += CurrentGame.getMineralMarketPricePerKg(mineral) * ship.shipConfig.remoteCargo[mineral]
				ship.configMutex.unlock()
				var txt = money_format % CurrentGame.formatThousands(value)
				money_waiting_label.text = str(txt) + " | "
				
		else:
			if money_waiting_label != null and money_waiting_label_1 != null and money_waiting_label_2 != null:
				money_waiting_label.visible = false
				money_waiting_label_1.visible = false
				money_waiting_label_2.visible = false
				
