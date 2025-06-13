extends Node

# Set mod priority if you want it to load before/after other mods
# Mods are loaded from lowest to highest priority, default is 0
const MOD_PRIORITY = 0
# Name of the mod, used for writing to the logs
const MOD_NAME = "Velocity+"
const MOD_VERSION = "1.0.0"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 0
const MOD_VERSION_BUGFIX = 0
const MOD_VERSION_METADATA = ""
const MOD_IS_LIBRARY = false
var modPath:String = get_script().resource_path.get_base_dir() + "/"
var _savedObjects := []
var ADD_EQUIPMENT_ITEMS = []
var check = preload("res://VelocityPlus/hevlib_check.gd")
var modConfig = {}
func _init(modLoader = ModLoader):
	l("Initializing DLC")
	loadSettings()
	loadDLC()
	var HevLib = check.__hevlib_check()
	
	replaceScene("weapons/WeaponSlot.tscn")
	
	replaceScene("enceladus/MineralMarket.tscn")
	if HevLib:
		addEquipmentItem(cradle_left)
		addEquipmentItem(cradle_right)
		var WebTranslate = preload("res://HevLib/pointers/WebTranslate.gd")
		WebTranslate.__webtranslate("https://github.com/rwqfsfasxc100/VelocityPlus",["i18n/en.txt"])
	else:
		updateTL("i18n/en.txt", "|")

var cradle_left = {
	"system":"SYSTEM_CRADLE-L",
	"name_override":"SYSTEM_CRADLE",
	"manual":"SYSTEM_CRADLE_MANUAL",
	"specs":"SYSTEM_CRADLE_SPECS",
	"price":50000,
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
	"price":50000,
	"alignment":"ALIGNMENT_RIGHT",
	"test_protocol":"detach",
	"equipment_type":"EQUIPMENT_CARGO_CONTAINER", 
	"slot_type":"HARDPOINT"
}

func _ready():
	l("Readying")
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

func l(msg:String, title:String = MOD_NAME, version:String = MOD_VERSION):
	Debug.l("[%s V%s]: %s" % [title, version, msg])

# Helper function that formats and appends the data provided to the variant
func addEquipmentItem(item_data: Dictionary):
	var Equipment = preload("res://HevLib/pointers/Equipment.gd")
#	var equipment = Equipment.__make_equipment(item_data)
	ADD_EQUIPMENT_ITEMS.append(item_data)
