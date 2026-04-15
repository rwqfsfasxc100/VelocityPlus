extends Node
var ship
var thrusterObject

var pointers

func _init(p,s,o):
	ship = s
	thrusterObject = o
	pointers = p
	pointers.ConfigDriver.__subscribe_to_setting_change("a1",self,"VelocityPlus","VP_SHIPS","adjust_thrust_to_temperature")
	pointers.ConfigDriver.__subscribe_to_setting_change("a2",self,"VelocityPlus","VP_SHIPS","adjust_thrust_nullify_thermal")
	updateValues()

func a1(how):
	adjust_thrust_to_temperature = how
func a2(how):
	adjust_thrust_nullify_thermal = how

func updateValues():
	if pointers:
		adjust_thrust_to_temperature = pointers.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","adjust_thrust_to_temperature")
		adjust_thrust_nullify_thermal = pointers.ConfigDriver.__get_value("VelocityPlus","VP_SHIPS","adjust_thrust_nullify_thermal")

var adjust_thrust_to_temperature = false
var adjust_thrust_nullify_thermal = false


var deltaTime = 0.0
func _physics_process(delta):
	if adjust_thrust_to_temperature and adjust_thrust_nullify_thermal:
		deltaTime = delta


func drawThermal(how,what):
	if adjust_thrust_to_temperature and adjust_thrust_nullify_thermal:
		var temp_current = thrusterObject.temp
		var temp_target = thrusterObject.avgTarget
		var inverse_multi = float(temp_target) / float(temp_current)
		
		var newThermal = how * inverse_multi
		return ship.drawThermal(newThermal,what)
	return ship.drawThermal(how,what)


func sensorGet(sensor):
	return ship.sensorGet(sensor)


var ageWithSeed = 0 setget _setAgeWithSeed , _getAgeWithSeed
var dummy = false setget _setDummy , _getDummy
var damageLimit = 0.35 setget _setDamageLimit , _getDamageLimit
var inside = 0 setget _setInside , _getInside
var setup = false setget _setSetup , _getSetup
var frozen = null setget _setFrozen , _getFrozen
var shock = 0.0 setget _setShock , _getShock
var physicsExclude = [] setget _setPhysicsExclude , _getPhysicsExclude
var escapeCutscene = false setget _setEscapeCutscene , _getEscapeCutscene
var faction = "civilian" setget _setFaction, _getFaction
var linear_velocity = Vector2.ZERO setget _setLV, _getLV
var reactors = [] setget _setReactors , _getReactors
var rotation = 0.0 setget _setRotation , _getRotation

func _setRotation(how):
	rotation = how
	ship.rotation = how
func _getRotation():
	if ship: rotation = ship.rotation
	else: rotation = 0.0
	return rotation

func _setReactors(how):
	reactors = how
	ship.reactors = how
func _getReactors():
	if ship: reactors = ship.reactors
	else: reactors = []
	return reactors

func _setLV(how):
	linear_velocity = how
	ship.linear_velocity = how
func _getLV():
	if ship: linear_velocity = ship.linear_velocity
	else: linear_velocity = Vector2.ZERO
	return linear_velocity

func _setFaction(how):
	faction = how
	ship.faction = how
func _getFaction():
	if ship: faction = ship.faction
	else: faction = "civilian"
	return faction

func _setEscapeCutscene(how):
	escapeCutscene = how
	ship.escapeCutscene = how
func _getEscapeCutscene():
	if ship: escapeCutscene = ship.escapeCutscene
	else: escapeCutscene = false
	return escapeCutscene

func _setPhysicsExclude(how):
	physicsExclude = how
	ship.physicsExclude = how
func _getPhysicsExclude():
	if ship: physicsExclude = ship.physicsExclude
	else: physicsExclude = []
	return physicsExclude

func _setShock(how):
	shock = how
	ship.shock = how
func _getShock():
	if ship: shock = ship.shock
	else: shock = 0.0
	return shock

func _getAgeWithSeed():
	if ship: ageWithSeed = ship.ageWithSeed
	else: ageWithSeed = 0
	return ageWithSeed
func _setAgeWithSeed(how:int):
	ageWithSeed = how
	ship.ageWithSeed = how

func _setDummy(how:bool):
	dummy = how
	ship.dummy = how
func _getDummy():
	if ship: dummy = ship.dummy
	else: dummy = false
	return dummy

func _setDamageLimit(how:float):
	damageLimit = how
	ship.damageLimit = how
func _getDamageLimit():
	if ship: damageLimit = ship.damageLimit
	else: damageLimit = 0.35
	return damageLimit

func _setSetup(how:bool):
	setup = how
	ship.setup = how
func _getSetup():
	if ship: setup = ship.setup
	else: setup = false
	return setup

func _setFrozen(how):
	frozen = how
	ship.frozen = how
func _getFrozen():
	if ship: frozen = ship.frozen
	else: frozen = null
	return frozen

func _setInside(how:int):
	inside = how
	ship.inside = how
func _getInside():
	if ship: inside = ship.inside
	else: inside = 0
	return inside


func getTunedValue(where,which,how):
	return ship.getTunedValue(where,which,how)

func getSystemDamage(where,which):
	return ship.getSystemDamage(where, which)

func getCrewAdjustedJuryRigFactorForSystem(where,which):
	return ship.getCrewAdjustedJuryRigFactorForSystem(where,which)

func changeSystemDamage(where,which,how,by):
	return ship.changeSystemDamage(where,which,how,by)

func has_method(what):
	return ship.has_method(what)

func get_parent():
	return ship.get_parent()

func connect(how: String,to: Object,out: String,params : Array = [], binds : int = 0) -> int:
	return ship.connect(how,to,out,params,binds)

func isPlayerControlled() -> bool:
	return ship.isPlayerControlled()

func getAgeYears():
	return ship.getAgeYears()

func takeProcessedCargo(which,what,how) : 
	return ship.takeProcessedCargo(which,what,how)

func get_world_2d():
	return ship.get_world_2d()

func drawEnergy(much):
	return ship.drawEnergy(much)

func drawReactiveMass(how):
	return ship.drawReactiveMass(how)

func isRealShip():
	return ship.isRealShip()

func apply_impulse(how,much):
	return ship.apply_impulse(how,much)
