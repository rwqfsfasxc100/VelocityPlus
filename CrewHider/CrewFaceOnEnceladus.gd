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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
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

extends "res://enceladus/CrewFaceOnEnceladus.gd"

var vac_tex
var vc
var pointersVP
func _enter_tree():
	pointersVP = ModLoader._savedObjects[0]
	pointersVP.ConfigDriver.__establish_connection("vp_enceladuscrewface_UV",self)
	yield(CurrentGame.get_tree(),"idle_frame")
	vac_tex = get_node_or_null("C/O/Face/Sprite").material.get_shader_param("mask")
	
	vc = StreamTexture.new()
	vc.load_path = "res://VelocityPlus/CrewHider/vaccover.stex"
	vp_enceladuscrewface_UV()

func vp_enceladuscrewface_UV():
	if pointersVP:
		var hideCrew = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_CREW","hide_on_enceladus")
		if hideCrew:
			visible = false
		else:
			var hideVac = pointersVP.ConfigDriver.__get_value("VelocityPlus","VP_CREW","hide_crew_suit")
			if hideVac:
				get_node_or_null("C/O").position = Vector2(120,100)
				get_node_or_null("C/O/Face/Sprite").z_index = 2
				get_node_or_null("C/O/Face/Sprite").material.set_shader_param("mask",vc)
				get_node_or_null("C/O/Vac").visible = false
				get_node_or_null("C/O/Screen2").texture_scale = 50
				get_node_or_null("C/O/Screen2").energy = 2.19
				get_node_or_null("C/O/Screen2").color = Color( "bebebe" )
				get_node_or_null("C/O/Screen3").energy = 0.0
				get_node_or_null("C/O/Screen3").visible = false
				
			else:
				get_node_or_null("C/O").position = Vector2(120,0)
				get_node_or_null("C/O/Face/Sprite").z_index = 1
				get_node_or_null("C/O/Face/Sprite").material.set_shader_param("mask",vac_tex)
				get_node_or_null("C/O/Vac").visible = true
				get_node_or_null("C/O/Screen2").texture_scale = 4.34
				get_node_or_null("C/O/Screen2").energy = 4.05
				get_node_or_null("C/O/Screen2").color = Color( "e1a023" )
				get_node_or_null("C/O/Screen3").energy = 5.9
				get_node_or_null("C/O/Screen3").visible = true
					
			visible = true
	else:
		visible = true
