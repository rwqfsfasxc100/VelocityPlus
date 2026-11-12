extends "res://menu/NewGamePlus.gd"

const unusable_ships = [
	["Hybrid","HYBRID"],
	["Obonto Habitat","OBONTO"],
	["MAD Cernunnos II","MADCERF"],
	["Racing Drone","DRONE"],
	["ATLAS Edge Runner","ATLAS"],
	["Tsukuyomi-Class Frigate","TSUKUYOMI"],
]

onready var opt_lists = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer

var available_ships:Array = [
	["SHIP_TRTL","TRTL"],
	["SHIP_TRTL_LCB","TRTL-LCB"],
	["SHIP_TRTL_R","TRTL-R"],
	["SHIP_TRTL_T","TRTL-T"],
	["SHIP_TRTL_K44","TRTL-44"],
	["SHIP_PROSPECTOR","PROSPECTOR"],
	["SHIP_PROSPECTOR_LUX","PROSPECTOR-LUX"],
	["SHIP_PROSPECTOR_VP","PROSPECTOR-VP"],
	["SHIP_PROSPECTOR_FAT","PROSPECTOR-FAT"],
	["SHIP_PROSPECTOR_BALD","PROSPECTOR-BALD"],
	["SHIP_EIME","EIME"],
	["SHIP_COTHON","COTHON"],
	["SHIP_COTHON_CHK","COTHON-CHK"],
	["SHIP_COTHON_LND","COTHON-LND"],
	["SHIP_COTHON_V","COTHON-V"],
	["SHIP_AT225","AT225"],
	["SHIP_AT225R","AT225-R"],
	["SHIP_AT225B","AT225-B"],
	["SHIP_OCP209","OCP209"],
	["SHIP_KITSUNE","KITSUNE"]
]

onready var starter_selector:VBoxContainer = ResourceLoader.load("res://VelocityPlus/ChooseStarterShip/SelectShip.tscn","PackedScene").instance()
onready var starter_selector_opts:OptionButton = starter_selector.get_node("OptionButton")

func _ready() -> void:
	var pointers:HevLibPointers = ModLoader._savedObjects[0]
	
	opt_lists.add_child(starter_selector)
	opt_lists.move_child(starter_selector,opt_lists.get_child_count() - 4)
	
	pointers.ConfigDriver.__subscribe_to_setting_change("vp_choosestarter_UV",self,"VelocityPlus","VP_SHIPS","choose_starter_ship")
	pointers.ConfigDriver.__subscribe_to_setting_change("vp_allowunob_UV",self,"VelocityPlus","VP_SHIPS","allow_start_with_inaccessible")
	vp_choosestarter_UV(pointers.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","choose_starter_ship"))
	
	for i in available_ships:
		starter_selector_opts.add_item(i[0])
	for ship_entry in pointers.Equipment.add_ships_store:
		if "path" in ship_entry.keys():
			var ship = load(ship_entry.path).instance()
			var display_name:String = ship.shipName
			available_ships.append([display_name,ship_entry.name])
			starter_selector_opts.add_item(display_name)
			Tool.remove(ship)
			yield(self,"tick")
			yield(self,"tick")
	vp_allowunob_UV(pointers.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","allow_start_with_inaccessible"))

func vp_choosestarter_UV(how:bool):
	starter_selector.visible = how

func vp_allowunob_UV(how:bool):
	var ass:int = available_ships.size()
	var uss:int = unusable_ships.size()
	if how:
		available_ships.resize(ass + uss)
		for i in uss:
			var ur:Array = unusable_ships[i]
			available_ships[ass + i] = ur
			starter_selector_opts.add_item(ur[0])
	else:
		available_ships.resize(ass - uss)
		for i in uss:
			starter_selector_opts.remove_item(ass)

func _about_to_show():
	._about_to_show()
	starter_selector_opts.select(0)

func _on_Ok_pressed():
	CurrentGame.vp_ship_override = available_ships[starter_selector_opts.selected][1]
	._on_Ok_pressed()

signal tick
func _physics_process(delta: float) -> void:
	emit_signal("tick")
