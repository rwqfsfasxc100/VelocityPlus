extends "res://enceladus/Tuning.gd"

var omsToggleCfg = "omstoggles.%s.%s"
onready var systemLabel = preload("res://VelocityPlus/enceladus/EnabledSystem.tscn")
onready var systemTitle = preload("res://VelocityPlus/enceladus/EnabledItems.tscn")

func fillTuneableSystems():
	.fillTuneableSystems()
	
	var node = get_node(itemsNodePath)
	if Tool.claim(ship):
		if not ship.setup:
			yield(ship,"setup")
		var systems = ship.getSystems()
		if not "omstoggles" in ship.shipConfig:
			ship.shipConfig.merge({"omstoggles":{}})
		var oms = ship.shipConfig["omstoggles"]
		node.add_child(systemTitle.instance())
		for system in systems:
			var sys = systems[system]
			var vname = sys.name
			if sys.togleable:
				var pos = null
				if "position" in sys.ref:
					pos = ship.get_path_to(sys.ref)
				var current = ship.getConfig(omsToggleCfg % [system,vname],true)
				ship.setConfig(omsToggleCfg % [system,vname],current)
				var label = systemLabel.instance()
				label.tuningItem = vname
				label.tune = current
				label.connect("value_changed",self,"handleOMSToggle",[system,vname,pos])
				node.add_child(label)
		Tool.release(ship)
	yield(get_tree(),"idle_frame")
	set_draw(false,false)

func handleOMSToggle(how,opt,system,pos):
	descriptionLabel.text = ""
	var ps = CurrentGame.getPlayerShip()
	var current = ps.getConfig(omsToggleCfg % [opt,system],true)
	ps.setConfig(omsToggleCfg % [opt,system],how)
	testProtocol = "hide"
	ship.forceHud = false
	ship.preheat = false
	ship.autopilot = false
	ship.autopilotComfort = false
	ship.autopilotComfortEnabled = false
	ship.autopilot = false
	camera.zoom = Vector2(1, 1)
	shipParams.visible = false
	charts.visible = false
	lidar.visible = false
	if Tool.claim(ship):
		ship.shipConfig = CurrentGame.getPlayerShipConfig().config
		ship.setConfig(omsToggleCfg % [opt,system],how)
		Tool.release(ship)
	if current != how:
		Tool.deferCallInPhysics(self, "addShip")
	set_draw(true,true,pos)

onready var tex_rect = $VB/WindowMargin/Window/VP/TextureRect

func _ready():
	tex_rect.set_script(load("res://VelocityPlus/enceladus/tex_rect_draw.gd"))

func tuningChanged(system, type, to, protocol):
	.tuningChanged(system, type, to, protocol)
	set_draw(false,false)

func set_draw(how,object_position,obj = null):
	if tex_rect.do_draw != how or ((tex_rect.obj_pos == true or object_position == true) and obj != tex_rect.obj):
		tex_rect.obj_pos = object_position
		tex_rect.obj = obj
		tex_rect.ship = getShip()
		tex_rect.do_draw = how
		tex_rect.update()


#func addShip(default = null):
#	.addShip(default)
#	match testProtocol:
#		"hide":
#
