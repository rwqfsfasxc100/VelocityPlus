extends "res://ships/ship-ctrl.gd"

var pilots_reduce_astro_calculations = {}

var pointersVP_pilots_reduce_astro_calc_time
func _enter_tree():
	pointersVP_pilots_reduce_astro_calc_time = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP_pilots_reduce_astro_calc_time.ConfigDriver.__establish_connection("vp_shipmanager_UV",self)
	vp_pilot_calc_time_reduction_UV()

func vp_pilot_calc_time_reduction_UV():
	if pointersVP_pilots_reduce_astro_calc_time:
		pilots_reduce_astro_calculations = pointersVP_pilots_reduce_astro_calc_time.ConfigDriver.pointersVP.ConfigDriver.__get_config("VelocityPlus").get("VP_CREW")


func _ready():
	modify()
	CurrentGame.connect("xpChanged",self,"modify")

func modify():
	if pilots_reduce_astro_calculations.get("pilots_reduce_astro_calculations",true):
		var education = 0
		var experience = 0
		var crewData = CurrentGame.getCurrentlyActiveCrewNames()
		for crew in crewData:
			var dta = CurrentGame.state.crew[crew]
			if dta.occupation == "CREW_OCCUPATION_PILOT":
				if dta.experience >= experience:
					experience = dta.experience
				if dta.talent >= education:
					education = dta.talent
		
		var minimum = float(pilots_reduce_astro_calculations.get("minimum_astrogation_time",3))
		var maximum = float(pilots_reduce_astro_calculations.get("maximum_astrogation_time",10))
		var bias = float(pilots_reduce_astro_calculations.get("pilot_skill_bias",0.3))
		var exmod = lerp(education,experience,bias)
		var diff = (exmod * maximum)
		var shrink = (maximum - diff)/maximum
		var modifier = lerp(minimum,maximum,shrink)
		trajectoryTime = clamp(modifier,minimum,maximum)
