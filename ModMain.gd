extends Node

# Set mod priority if you want it to load before/after other mods
# Mods are loaded from lowest to highest priority, default is 0
const MOD_PRIORITY = -1
# Name of the mod, used for writing to the logs
const MOD_NAME = "Velocity Plus"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 2
const MOD_VERSION_BUGFIX = 0
const MOD_VERSION_METADATA = ""
const MOD_IS_LIBRARY = false
var modPath:String = get_script().resource_path.get_base_dir() + "/"
var _savedObjects := []
var ADD_EQUIPMENT_ITEMS = []
var check
var config = {}
func _init(modLoader = ModLoader):
	l("Initializing DLC")
	loadDLC()
	
	var mp = self.get_script().get_path()
	var md = mp.split(mp.split("/")[mp.split("/").size() - 1])[0]
	var mc = load(md + "mod_checker_script.tscn").instance()
	add_child(mc)
	
	var ConfigDriver = load("res://HevLib/pointers/ConfigDriver.gd")
	config = ConfigDriver.__get_config("VelocityPlus")
	
	installScriptExtension("enceladus/Upgrades.gd")
	
	if config.get("VP_SHIPS",{}).get("add_scoop_halt_on_return",false):
		replaceScene("comms/conversation/subtrees/DIALOG_SCOOP_RETURNING_1.tscn","res://comms/conversation/subtrees/DIALOG_SCOOP_RETURNING_1.tscn")
	
	if config.get("VP_CREW",{}).get("hide_on_enceladus",false):
		replaceScene("enceladus/CrewFaceOnEnceladus.tscn")
	if config.get("VP_CREW",{}).get("hide_in_OMS",false):
		replaceScene("hud/OMS.tscn")
	
	
	if config.get("VP_SHIPS",{}).get("fix_voyager_MPU_in_OCP",true):
		replaceScene("ships/ocp-209.tscn")
	
	installScriptExtension("comms/ConversationPlayer.gd")
#	var weaponslot_path = "res://weapons/WeaponSlot.tscn"
	
	installScriptExtension("enceladus/SystemShipRepairUI.gd")
	
	
	replaceScene("tooltips/SystemShipRepairUI.tscn","res://enceladus/SystemShipRepairUI.tscn")
	installScriptExtension("tooltips/DoTradeIn.gd")
	
	
#	installScriptExtension("ships/ship-ctrl-neg-depth.gd")
	
	
	installScriptExtension("hud/OMS.gd")
	
	installScriptExtension("ships/DockingArm.gd")
	
#	installScriptExtension("ships/MPU.gd")
	
	installScriptExtension("AchievementAbstract.gd")



#	if config.get("VP_SHIPS",{})["disable_gimballed_weapons"]:
#		replaceScene("weapons/weaponslots/NoGimballedWeapons/WeaponSlot.tscn",weaponslot_path)
#	if config.get("VP_SHIPS",{})["disable_turrets_turning"]:
#		replaceScene("weapons/weaponslots/NoTurningTurrets/WeaponSlot.tscn",weaponslot_path)
	
	# Don't Change
#	installScriptExtension("Hud.gd")
#	replaceScene("weapons/weaponslots/Cradles/WeaponSlot.tscn",weaponslot_path)
	installScriptExtension("ships/ship-ctrl.gd")
	installScriptExtension("hud/Escape Veloity.gd")
	installScriptExtension("hud/Leaving Rings.gd")
	installScriptExtension("weapons/PDT.gd")
	
	
	replaceScene("enceladus/MineralMarket.tscn") # Fixes issue #5033 ; https://git.kodera.pl/games/delta-v/-/issues/5033
	

var cradle_left = {
	"system":"SYSTEM_CRADLE-L",
	"name_override":"SYSTEM_CRADLE",
	"manual":"SYSTEM_CRADLE_MANUAL",
	"specs":"SYSTEM_CRADLE_SPECS",
	"price":2500,
	"alignment":"ALIGNMENT_LEFT",
	"test_protocol":"detach",
	"equipment_type":"EQUIPMENT_CARGO_CONTAINER",
	"slot_type":"HARDPOINT"
}
var cradle_right = {
	"system":"SYSTEM_CRADLE-R",
	"name_override":"SYSTEM_CRADLE",
	"manual":"SYSTEM_CRADLE_MANUAL",
	"specs":"SYSTEM_CRADLE_SPECS",
	"price":2500,
	"alignment":"ALIGNMENT_RIGHT",
	"test_protocol":"detach",
	"equipment_type":"EQUIPMENT_CARGO_CONTAINER", 
	"slot_type":"HARDPOINT"
}

func _ready():
	l("Readying")
	var version = CurrentGame.version.split(".")
	var modern = false
	if int(version[0]) >= 1:
		if int(version[1]) >= 86:
			modern = true
	
	if modern:
		
		var simulator_path = "res://enceladus/Simulator/SimulationLayer.tscn"
		match config.get("VP_ENCELADUS",{}).get("simulator_shader",1):
			0:
				pass
			1:
				replaceScene("enceladus/Simulator/background/SimulationLayer.tscn",simulator_path)
			2:
				replaceScene("enceladus/Simulator/nobackground/SimulationLayer.tscn",simulator_path)
			3:
				replaceScene("enceladus/Simulator/lumaedge/SimulationLayer.tscn",simulator_path)
	else:
		var simulator_path = "res://enceladus/Simulator/SimulationLayer.tscn"
		match config.get("VP_ENCELADUS",{}).get("simulator_shader",1):
			0:
				pass
			1:
				replaceScene("enceladus/Simulator/background/SimulationLayer-old.tscn",simulator_path)
			2:
				replaceScene("enceladus/Simulator/nobackground/SimulationLayer-old.tscn",simulator_path)
			3:
				replaceScene("enceladus/Simulator/lumaedge/SimulationLayer-old.tscn",simulator_path)
	
	if Directory.new().file_exists("res://HevLib/ModMain.gd"):
		if config.get("VP_ENCELADUS",{}).get("add_empty_cradle_equipment",true): # Implementation for issue #5133 ; https://git.kodera.pl/games/delta-v/-/issues/5133
			addEquipmentItem(cradle_left)
			addEquipmentItem(cradle_right)
#		var WebTranslate = load("res://HevLib/pointers/WebTranslate.gd")
#		var fallback = [
#			modPath + "i18n/en_ends.txt",
#			modPath + "i18n/en_base.txt",
#			modPath + "i18n/en_60.txt",
#			modPath + "i18n/en_45.txt",
#			modPath + "i18n/en_30.txt",
#			modPath + "i18n/en_1.txt",
#			modPath + "i18n/en.txt",
#		]
#		WebTranslate.__webtranslate("https://github.com/rwqfsfasxc100/VelocityPlus",fallback, "res://VelocityPlus/ModMain.gd")
#	else:
	updateTL("i18n/en_ends.txt", "|")
	updateTL("i18n/en_base.txt", "|")
	updateTL("i18n/en_60.txt", "|")
	updateTL("i18n/en_45.txt", "|")
	updateTL("i18n/en_30.txt", "|")
	updateTL("i18n/en_1.txt", "|")
	updateTL("i18n/en.txt", "|")
	
	installScriptExtension("enceladus/Repairs.gd")
	replaceScene("enceladus/Repairs.tscn")
	l("Ready")


func updateTL(path:String, delim:String = ",", useRelativePath:bool = true, fullLogging:bool = true):
	if useRelativePath:
		path = str(modPath + path)
	l("Adding translations from: %s" % path)
	var tlFile:File = File.new()
	tlFile.open(path, File.READ)

	var translations := []
	
	var translationCount = 0
	var csvLine := tlFile.get_line().split(delim)
	if fullLogging:
		l("Adding translations as: %s" % csvLine)
	for i in range(1, csvLine.size()):
		var translationObject := Translation.new()
		translationObject.locale = csvLine[i]
		translations.append(translationObject)

	while not tlFile.eof_reached():
		csvLine = tlFile.get_csv_line(delim)

		if csvLine.size() > 1:
			var translationID := csvLine[0]
			for i in range(1, csvLine.size()):
				translations[i - 1].add_message(translationID, csvLine[i].c_unescape())
			if fullLogging:
				l("Added translation: %s" % csvLine)
			translationCount += 1

	tlFile.close()

	for translationObject in translations:
		TranslationServer.add_translation(translationObject)
	l("%s Translations Updated" % translationCount)

func installScriptExtension(path:String):
	var childPath:String = str(modPath + path)
	var childScript:Script = ResourceLoader.load(childPath)

	childScript.new()

	var parentScript:Script = childScript.get_base_script()
	var parentPath:String = parentScript.resource_path

	l("Installing script extension: %s <- %s" % [parentPath, childPath])

	childScript.take_over_path(parentPath)

func replaceScene(newPath:String, oldPath:String = ""):
	l("Updating scene: %s" % newPath)

	if oldPath.empty():
		oldPath = str("res://" + newPath)

	newPath = str(modPath + newPath)

	var scene := load(newPath)
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
	l("Finished updating: %s" % oldPath)

func replaceSceneForce(newPath:String, oldPath:String = ""):
	l("Updating scene: %s" % newPath)

	if oldPath.empty():
		oldPath = str("res://" + newPath)

	newPath = str(modPath + newPath)

	var scene := ResourceLoader.load(newPath,"",true)
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
	l("Finished updating: %s" % oldPath)

func loadDLC():
	l("Preloading DLC as workaround")
	var DLCLoader:Settings = preload("res://Settings.gd").new()
	DLCLoader.loadDLC()
	DLCLoader.queue_free()
	l("Finished loading DLC")

func l(msg:String, title:String = MOD_NAME, version:String = str(MOD_VERSION_MAJOR) + "." + str(MOD_VERSION_MINOR) + "." + str(MOD_VERSION_BUGFIX)):
	if not MOD_VERSION_METADATA == "":
		version = version + "-" + MOD_VERSION_METADATA
	Debug.l("[%s V%s]: %s" % [title, version, msg])

# Helper function that formats and appends the data provided to the variant
func addEquipmentItem(item_data: Dictionary):
	var Equipment = load("res://HevLib/pointers/Equipment.gd")
#	var equipment = Equipment.__make_equipment(item_data)
	ADD_EQUIPMENT_ITEMS.append(item_data)
