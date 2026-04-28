extends "res://enceladus/Simulator/SimulationLayer.gd"

var bg_sprite_path = NodePath("MarginContainer/SimulateViewport/Paralax/ParallaxLayer/Sprite500m")

var sim_cover_basic_path = NodePath("MarginContainer/SimulateViewport/SimulationLayer/SimulationCoverBasic")
var sim_cover_premium_path = NodePath("MarginContainer/SimulateViewport/SimulationLayer/SimulationCoverPremium")
var pointersVP

func _enter_tree():
	pointersVP = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointersVP.ConfigDriver.__establish_connection("vp_sim_UV",self)
	vp_sim_UV()

var basic_shader = null
var premium_shader = null

var simulator_shader = 0
var old_shader = 0

func vp_sim_UV():
	if pointersVP:
		simulator_shader = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_ENCELADUS","simulator_shader")
	else:
		simulator_shader = 0
	if old_shader != simulator_shader:
		pass
	
		var bg_sprite = get_node_or_null(bg_sprite_path)
		var sim_cover_basic = get_node_or_null(sim_cover_basic_path)
		var sim_cover_premium = get_node_or_null(sim_cover_premium_path)
		if basic_shader == null:
			basic_shader = sim_cover_basic.material.duplicate(true)
		if premium_shader == null:
			premium_shader = sim_cover_premium.material.duplicate(true)
		
		
		match simulator_shader:
			0:
				bg_sprite.self_modulate = Color(1,1,1,1)
				sim_cover_basic.self_modulate = Color(1,1,1,1)
				sim_cover_premium.self_modulate = Color(1,1,1,1)
				if old_shader == 3:
					sim_cover_basic.material = basic_shader.duplicate(true)
					sim_cover_premium.material = premium_shader.duplicate(true)
			1:
				bg_sprite.self_modulate = Color(1,1,1,1)
				sim_cover_basic.self_modulate = Color(1,1,1,0)
				sim_cover_premium.self_modulate = Color(1,1,1,0)
				if old_shader == 3:
					sim_cover_basic.material = basic_shader.duplicate(true)
					sim_cover_premium.material = premium_shader.duplicate(true)
			2:
				bg_sprite.self_modulate = Color(1,1,1,0)
				sim_cover_basic.self_modulate = Color(1,1,1,0)
				sim_cover_premium.self_modulate = Color(1,1,1,0)
				if old_shader == 3:
					sim_cover_basic.material = basic_shader.duplicate(true)
					sim_cover_premium.material = premium_shader.duplicate(true)
			3:
				bg_sprite.self_modulate = Color(1,1,1,0)
				sim_cover_basic.self_modulate = Color(1,1,1,1)
				sim_cover_premium.self_modulate = Color(1,1,1,1)
				sim_cover_basic.material = load("res://shader/lumaedge.material")
				sim_cover_premium.material = load("res://shader/lumaedge.material")
		old_shader = simulator_shader
