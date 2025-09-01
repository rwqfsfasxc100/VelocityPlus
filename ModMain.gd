extends Node

# Set mod priority if you want it to load before/after other mods
# Mods are loaded from lowest to highest priority, default is 0
const MOD_PRIORITY = 0
# Name of the mod, used for writing to the logs
const MOD_NAME = "Velocity Plus"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 1
const MOD_VERSION_BUGFIX = 4
const MOD_VERSION_METADATA = ""
const MOD_IS_LIBRARY = false
var modPath:String = get_script().resource_path.get_base_dir() + "/"
var _savedObjects := []
var ADD_EQUIPMENT_ITEMS = []
var modConfig = {}
var check
func _init(modLoader = ModLoader):
	l("Initializing DLC")
	loadSettings()
	loadDLC()
	
	var mp = self.get_script().get_path()
	var md = mp.split(mp.split("/")[mp.split("/").size() - 1])[0]
	var mc = load(md + "mod_checker_script.tscn").instance()
	add_child(mc)
	
	installScriptExtension("enceladus/Upgrades.gd")
	
	var simulator_path = "res://enceladus/Simulator/SimulationLayer.tscn"
	match modConfig["enceladus"]["simulator_shader"]:
		0:
			pass
		1:
			replaceScene("enceladus/Simulator/background/SimulationLayer.tscn",simulator_path)
		2:
			replaceScene("enceladus/Simulator/nobackground/SimulationLayer.tscn",simulator_path)
		3:
			replaceScene("enceladus/Simulator/lumaedge/SimulationLayer.tscn",simulator_path)
	
	if modConfig["crew"]["hide_on_enceladus"]:
		replaceScene("enceladus/CrewFaceOnEnceladus.tscn")
	if modConfig["crew"]["hide_in_OMS"]:
		replaceScene("hud/OMS.tscn")
	
	
	if modConfig["ships"]["fix_voyager_MPU_in_OCP"]:
		replaceScene("ships/ocp-209.tscn")
	
	if Directory.new().file_exists("res://HevLib/ModMain.gd"):
		if modConfig["in_ring"]["broadcast_variations"]:
			installScriptExtension("comms/ConversationPlayer.gd")
	var weaponslot_path = "res://weapons/WeaponSlot.tscn"
	
	if modConfig["enceladus"]["hide_unrepairable_equipment"]:
		installScriptExtension("enceladus/SystemShipRepairUI.gd")
	
	if modConfig["enceladus"]["extra_tooltips"]:
		replaceScene("tooltips/SystemShipRepairUI.tscn","res://enceladus/SystemShipRepairUI.tscn")
		installScriptExtension("tooltips/DoTradeIn.gd")
	
	
	if modConfig["in_ring"]["display_negative_depth"]:
		installScriptExtension("ships/ship-ctrl-neg-depth.gd")
	
	if modConfig["in_ring"]["show_dive_time_in_OMS"]:
		installScriptExtension("hud/OMS.gd")
	
	if modConfig["ships"]["arm_focuses_to_targeted_object"]:
		installScriptExtension("ships/DockingArm.gd")
	
	installScriptExtension("ships/MPU.gd")
	
	if modConfig["enceladus"]["enable_achievements"]:
		installScriptExtension("AchievementAbstract.gd")




#	if modConfig["ships"]["disable_gimballed_weapons"]:
#		replaceScene("weapons/weaponslots/NoGimballedWeapons/WeaponSlot.tscn",weaponslot_path)
#	if modConfig["ships"]["disable_turrets_turning"]:
#		replaceScene("weapons/weaponslots/NoTurningTurrets/WeaponSlot.tscn",weaponslot_path)
	
	# Don't Change
	installScriptExtension("Hud.gd")
#	replaceScene("weapons/weaponslots/Cradles/WeaponSlot.tscn",weaponslot_path)
	installScriptExtension("ships/ship-ctrl.gd")
	installScriptExtension("hud/Escape Veloity.gd")
	installScriptExtension("hud/Leaving Rings.gd")
	installScriptExtension("weapons/PDT.gd")
	
	if modConfig["enceladus"]["mineral_market_show_total_value"]:
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
	
	
	
	if Directory.new().file_exists("res://HevLib/ModMain.gd"):
		if modConfig["enceladus"]["add_empty_cradle_equipment"]: # Implementation for issue #5133 ; https://git.kodera.pl/games/delta-v/-/issues/5133
			addEquipmentItem(cradle_left)
			addEquipmentItem(cradle_right)
		var WebTranslate = load("res://HevLib/pointers/WebTranslate.gd")
		var fallback = [
			modPath + "i18n/en_ends.txt",
			modPath + "i18n/en_base.txt",
			modPath + "i18n/en_60.txt",
			modPath + "i18n/en_45.txt",
			modPath + "i18n/en_30.txt",
			modPath + "i18n/en_1.txt",
			modPath + "i18n/en.txt",
		]
		WebTranslate.__webtranslate("https://github.com/rwqfsfasxc100/VelocityPlus",fallback, "res://VelocityPlus/ModMain.gd")
	else:
		updateTL("i18n/en.txt", "|")
	l("Ready")
	
func loadSettings():
	installScriptExtension("Settings.gd")
	l(MOD_NAME + ": Loading mod settings")
	var settings = load("res://Settings.gd").new()
	settings.load_VelocityPlus_FromFile()
	settings.save_VelocityPlus_ToFile()
	modConfig = settings.VelocityPlus
	l(MOD_NAME + ": Current settings: %s" % modConfig)
	settings.queue_free()
	l(MOD_NAME + ": Finished loading settings")

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
