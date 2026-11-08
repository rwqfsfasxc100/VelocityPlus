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

extends Popup

var current_save_slot:String = "user://savegame.dv"

onready var text_template:String = TranslationServer.translate("VP_SAVE_INFO_TEMPLATE")

func show_menu(slot,button):
	current_save_slot = slot
	get_data()
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
var equipment_names:PoolStringArray = PoolStringArray()
var ship_names:PoolStringArray = PoolStringArray()

func _about_to_show():
	
	lastFocus = get_focus_owner()


func _confirmed():
	cancel()

func get_data():
	var equipment:Node = load("res://enceladus/Upgrades.tscn").instance()
	for slot in equipment.get_node("VB/MarginContainer/ScrollContainer/MarginContainer/Items").get_children():
		var children:Array = slot.get_node("VBoxContainer").get_children()
		if children.size() < 2:
			continue
		for i in children:
			var ename:String = ""
			if "system" in i:
				if "nameOverride" in i and i.nameOverride != "":
					ename = i.nameOverride
				else:
					ename = i.system
			if ename and not ename in equipment_names:
				equipment_names.append(ename)
	Tool.remove(equipment)
	
	
	for ship in Shipyard.ships:
		var s:Node = Shipyard.ships[ship].instance()
		var sname:String = s.shipName
		if sname and not sname in ship_names:
			ship_names.append(sname)
		Tool.remove(s)

func handle_save():
	var data:Dictionary = getSave(current_save_slot)
	var datetime:int = data.get("time",0)
	var diff:int = datetime - CurrentGame.getGameStartTime() + Time.get_unix_time_from_datetime_dict({"year":0})
	var time:String = Time.get_datetime_string_from_unix_time(diff,true).lstrip(str(0))
	var elapsed_split:PoolStringArray = time.split(" ")
	var elapsed_date_split:PoolStringArray = elapsed_split[0].split("-")
	var elapsed_time_split:PoolStringArray = elapsed_split[1].split(":")
	for f in elapsed_date_split.size():
		if not int(elapsed_date_split[f]) > 0:
			elapsed_date_split[f] = "0"
	for f in elapsed_time_split.size():
		if not int(elapsed_time_split[f]) > 0:
			elapsed_time_split[f] = "0"
	var playtime:Dictionary = data.get("playtime",{})
	var playtime_display:String = ""
	var playtime_dict:Dictionary = {}
	var playtime_array:PoolStringArray = PoolStringArray()
	for item in playtime:
		playtime_dict[item] = get_minutes(playtime[item])
		playtime_array.append(item)
	playtime_array.sort()
	var ships_display:String = ""
	var equipment_display:String = ""
	var misc_display:String = ""
	for p in playtime_array:
		var d:String = playtime_dict[p]
		if p in equipment_names:
			equipment_display += ("    " + TranslationServer.translate(p) + ": " + d)
		elif p in ship_names:
			ships_display += ("    " + TranslationServer.translate(p) + ": " + d)
		else:
			misc_display += ("    " + TranslationServer.translate(p) + ": " + d)
	$PanelContainer/VBoxContainer/ScrollContainer/Label.text = text_template % [Time.get_datetime_string_from_unix_time(datetime,true),"%s years %s months %s days %s hours %s minutes %s seconds" % [elapsed_date_split[0],elapsed_date_split[1],elapsed_date_split[2],elapsed_time_split[0],elapsed_time_split[1],elapsed_time_split[2]],CurrentGame.formatThousands(int(data.get("money",0.0))),CurrentGame.formatThousands(int(data.get("insurance",0.0))),data.get("crew",{}).size(),data.get("garage",{}).size() + 1,data.get("seed",0),ships_display,equipment_display,misc_display]

func get_minutes(time):
	var timeconcat:float = round(time/60.0)
	var minute_indicator:String = TranslationServer.translate("VP_MINUTES_INDICATOR") % int(timeconcat) % 60
	var hour_indicator:String = TranslationServer.translate("VP_HOURS_INDICATOR") % int(floor(timeconcat / 60))
	
	return hour_indicator + " " + minute_indicator
func getSave(file) -> Dictionary:
	var f:File = File.new()
	if f.file_exists(file):
		f.open_encrypted_with_pass(file, File.READ, "FTWOMG")
		var savedState = parse_json(f.get_line())
		f.close()
		if savedState:
			return savedState
	return {}
