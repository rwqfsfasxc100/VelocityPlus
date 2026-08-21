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

extends "res://ships/ship-ctrl.gd"

var pilots_reduce_astro_calculations = {}

var pointersVP_pilots_reduce_astro_calc_time
func _enter_tree():
	pointersVP_pilots_reduce_astro_calc_time = ModLoader._savedObjects[0]
	pointersVP_pilots_reduce_astro_calc_time.ConfigDriver.__establish_connection("vp_pilot_calc_time_reduction_UV",self)
	vp_pilot_calc_time_reduction_UV()

func vp_pilot_calc_time_reduction_UV():
	if pointersVP_pilots_reduce_astro_calc_time:
		pilots_reduce_astro_calculations = pointersVP_pilots_reduce_astro_calc_time.ConfigDriver.__get_config("VelocityPlus").get("VP_CREW")

var vp_pilotsreduceadrenalinehandler_uinit : bool = false
func _ready():
	if vp_pilotsreduceadrenalinehandler_uinit:
		OS.kill(OS.get_process_id())
	vp_pilotsreduceadrenalinehandler_uinit = true
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
