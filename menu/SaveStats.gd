extends Popup

var current_save_slot = "user://savegame.dv"

onready var text_template = TranslationServer.translate("VP_SAVE_INFO_TEMPLATE")

func show_menu(slot,button):
	current_save_slot = slot
	handle_save()
	popup_centered()

func cancel():
	hide()
	refocus()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")
var items_node_path = "VB/MarginContainer/ScrollContainer/MarginContainer/Items"
var equipment_names = []
var ship_names = []
func _ready():
	var equipment = load("res://enceladus/Upgrades.tscn").instance()
	
	var cv = equipment.get_node(items_node_path).get_children()
	for slot in cv:
		var children = slot.get_node("VBoxContainer").get_children()
		if children.size() <= 1:
			continue
		for i in children:
			var ename = ""
			if "system" in i:
				if "nameOverride" in i and i.nameOverride != "":
					ename = i.nameOverride
				else:
					ename = i.system
			if ename != "" and not ename in equipment_names:
				equipment_names.append(ename)
	Tool.remove(equipment)
	
	
	for ship in Shipyard.ships:
		var s = Shipyard.ships[ship].instance()
		var sname = s.shipName
		if not sname in ship_names:
			ship_names.append(sname)
		Tool.remove(s)
	
	

func _about_to_show():
	
	lastFocus = get_focus_owner()


func _confirmed():
	cancel()

func handle_save():
	var offset_time = Time.get_unix_time_from_datetime_dict({"year":0})
	var data = getSave(current_save_slot)
	var datetime = data.get("time",0)
	var date = Time.get_datetime_string_from_unix_time(datetime,true)
	var gamestart = CurrentGame.getGameStartTime()
	var diff = datetime - gamestart + offset_time
	var time = str(Time.get_datetime_string_from_unix_time(diff,true)).lstrip(str(0))
	var time_concat = "%s hours %s minutes %s seconds"
	var date_concat = "%s years %s months %s days"
	var elapsed_split = time.split(" ")
	var elapsed_date_split = elapsed_split[0].split("-")
	var elapsed_time_split = elapsed_split[1].split(":")
	var crew = data.get("crew",{}).size()
	var owned_ships = data.get("garage",{}).size() + 1
	var money = data.get("money",0.0)
	var insurance = data.get("insurance",0.0)
	var sseed = data.get("seed",0)
	var playtime = data.get("playtime",{})
	var playtime_display = ""
	var playtime_dict = {}
	var playtime_array = []
	for item in playtime:
		var i = playtime[item]
		var pt = get_minutes(i)
		playtime_dict.merge({item:pt})
		playtime_array.append(item)
	playtime_array.sort()
	var ships = []
	var equipment = []
	var misc = []
	for p in playtime_array:
		var d = playtime_dict[p]
		if p in equipment_names:
			equipment.append("    " + TranslationServer.translate(p) + ": " + d + "\n")
		elif p in ship_names:
			ships.append("    " + TranslationServer.translate(p) + ": " + d + "\n")
		else:
			misc.append("    " + TranslationServer.translate(p) + ": " + d + "\n")
	var ships_display = ""
	var equipment_display = ""
	var misc_display = ""
	for i in ships:
		ships_display = ships_display + i
	
	for i in equipment:
		equipment_display = equipment_display + i
	
	for i in misc:
		misc_display = misc_display + i
	
	var display = text_template % [str(date),date_concat % [elapsed_date_split[0],elapsed_date_split[1],elapsed_date_split[2]] + " " + time_concat % [elapsed_time_split[0],elapsed_time_split[1],elapsed_time_split[2]],str(CurrentGame.formatThousands(int(money))),str(CurrentGame.formatThousands(int(insurance))),str(crew),str(owned_ships),str(sseed),ships_display,equipment_display,misc_display]
	
	
	$PanelContainer/VBoxContainer/ScrollContainer/Label.text = display
	pass
func get_minutes(time):
	var minute_indicator = TranslationServer.translate("VP_MINUTES_INDICATOR")
	var hour_indicator = TranslationServer.translate("VP_HOURS_INDICATOR")
	var hour_temp = Time.get_unix_time_from_datetime_dict({"hour":1})
	var timeconcat = round(time/60.0)
	var minutes = int(timeconcat) % 60
	var hours = floor(timeconcat / 60)
	
	
	
	
	
	return hour_indicator % hours + " " + minute_indicator % minutes
func getSave(file):
	var f = File.new()
	if f.file_exists(file):
		f.open_encrypted_with_pass(file, File.READ, "FTWOMG")
		var sg = f.get_line()
		var savedState = parse_json(sg)
		f.close()
		return savedState
