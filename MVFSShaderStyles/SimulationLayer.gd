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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends "res://enceladus/Simulator/SimulationLayer.gd"

var bg_sprite_path = NodePath("MarginContainer/SimulateViewport/Paralax/ParallaxLayer/Sprite500m")

var sim_cover_basic_path = NodePath("MarginContainer/SimulateViewport/SimulationLayer/SimulationCoverBasic")
var sim_cover_premium_path = NodePath("MarginContainer/SimulateViewport/SimulationLayer/SimulationCoverPremium")
var pointersVP

func _enter_tree():
	pointersVP = ModLoader._savedObjects[0]
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
