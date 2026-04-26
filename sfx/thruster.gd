extends "res://sfx/thruster.gd"

var VP_pointers


func vp_thrusterTempModeration_UV():
	if VP_pointers:
		var config = VP_pointers.ConfigDriver.__get_config("VelocityPlus").get("VP_SHIPS",{})
		adjust_thrust_to_temperature = config.get("adjust_thrust_to_temperature",false)
		adjust_thrust_multi = config.get("adjust_thrust_multi",1.0)

var adjust_thrust_to_temperature = false
var adjust_thrust_multi = 1.0

var temp = 0
var avgTarget = 0
var count = 0

var interruptObject
func a1(how):
	adjust_thrust_to_temperature = how
func a3(how):
	adjust_thrust_multi = how
func _ready():
	if ship.isPlayerControlled() and ship.isRealShip():
		VP_pointers = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
		VP_pointers.ConfigDriver.__subscribe_to_setting_change("a1",self,"VelocityPlus","VP_SHIPS","adjust_thrust_to_temperature")
		VP_pointers.ConfigDriver.__subscribe_to_setting_change("a3",self,"VelocityPlus","VP_SHIPS","adjust_thrust_multi")
		vp_thrusterTempModeration_UV()
		yield(CurrentGame.get_tree(),"idle_frame")
		interruptObject = load("res://VelocityPlus/sfx/ThrusterShipInterrupt.gd").new(VP_pointers,ship,self)
		ship = interruptObject

func _physics_process(delta):
	if adjust_thrust_to_temperature:
		count += 1
		if count > 5:
			count = 0
			temp = ship.sensorGet("reactor_temperature")
			var reactors = ship.reactors
			var rt = 0
			var rc = reactors.size()
			if rc:
				for i in reactors:
					rt += i.targetTemperature
				avgTarget = floor(float(rt) / float(rc))
			else:
				temp = 1
				avgTarget = 1

func getThrust(force = false):
	var outThrust = .getThrust(force)
	if adjust_thrust_to_temperature and not externalPower:
		if temp > 1000:
			var multi = (float(temp)/float(avgTarget))
			var s0 = multi - 1.0
			var s1 = s0 * adjust_thrust_multi
			var s2 = s1 + 1.0
			if multi != 1:
				var newthrust = max(outThrust * s2,outThrust * 0.1)
				return newthrust
	return outThrust
